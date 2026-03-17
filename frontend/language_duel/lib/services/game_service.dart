import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:signalr_netcore/signalr_client.dart';
import '../models/game_models.dart';

enum GameStatus { idle, searching, inGame, finished }

class GameService extends ChangeNotifier {
  final String baseUrl;
  final String token;
  final String userId;

  HubConnection? _hub;
  final http.Client _http = http.Client();

  GameStatus _status = GameStatus.idle;
  String? _selectedLanguageId;
  String? _gameId;
  GameStateDto? _gameState;
  GameResultDto? _gameResult;
  String? _error;
  bool _inviteHandled = false;
  String _selectedLanguageName = '';

  final Map<String, int> _languageRatings = {};
  final Map<String, String> _languageNames = {};

  GameStatus get status => _status;
  String? get gameId => _gameId;
  GameStateDto? get gameState => _gameState;
  GameResultDto? get gameResult => _gameResult;
  String? get error => _error;
  String get selectedLanguageName => _selectedLanguageName;

  int get currentRating =>
      _selectedLanguageId != null
          ? (_languageRatings[_selectedLanguageId!] ?? 0)
          : 0;

  int ratingForLanguage(String languageId) =>
      _languageRatings[languageId] ?? 0;

  String nameForLanguage(String languageId) =>
      _languageNames[languageId] ?? languageId;

  Map<String, int> get allLanguageRatings => Map.unmodifiable(_languageRatings);
  Map<String, String> get allLanguageNames => Map.unmodifiable(_languageNames);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  GameService({
    required this.baseUrl,
    required this.token,
    required this.userId,
  });

  Future<void> connect() async {
    _hub = HubConnectionBuilder()
        .withUrl(
          '$baseUrl/gameHub',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _hub!.on('ReceiveGameInvitation', (args) async {
      if (args == null || args.isEmpty) return;
      final dto = GameInvitationDto.fromJson(args[0] as Map<String, dynamic>);

      if (_inviteHandled ||
          (dto.inviterUserId == userId && dto.gameId == null)) {
        return;
      }
      _inviteHandled = true;

      _gameId = dto.gameId;
      await _hub!.invoke('StopSearchGameAsync',
          args: [userId, _selectedLanguageId!]);
      await _hub!.invoke('AddToGameAsync', args: [_gameId!]);

      _status = GameStatus.inGame;
      notifyListeners();
    });

    _hub!.on('GameStateChanged', (args) {
      if (args == null || args.isEmpty) return;
      _gameState = GameStateDto.fromJson(args[0] as Map<String, dynamic>);
      _status = GameStatus.inGame;
      notifyListeners();
    });

    _hub!.on('ReceiveGameResult', (args) async {
      if (args == null || args.isEmpty) return;
      _gameResult = GameResultDto.fromJson(args[0] as Map<String, dynamic>);
      _status = GameStatus.finished;
      await fetchLanguages();
      notifyListeners();
    });

    try {
      await _hub!.start();
      // After connecting, check if the user is already in an active game
      // (handles app restart / background kill while a game was in progress)
      await _rejoinActiveGameIfAny();
    } catch (e) {
      _error = 'Could not connect to game server: $e';
      notifyListeners();
    }
  }

  /// Checks GET /api/games/current. If a game exists, rejoins it via
  /// AddToGameAsync and fetches the current state immediately.
  Future<void> _rejoinActiveGameIfAny() async {
    try {
      final currentRes = await _http.get(
        Uri.parse('$baseUrl/api/games/current'),
        headers: _headers,
      );

      // 204 No Content or 404 means no active game
      if (currentRes.statusCode == 204 || currentRes.statusCode == 404) return;
      if (currentRes.statusCode != 200) return;

      final body = currentRes.body.trim();
      if (body.isEmpty || body == 'null') return;

      // Server returns a bare JSON Guid string e.g. "\"9ecb06bf-...\""
      final gameId = json.decode(body) as String;
      _gameId = gameId;

      // Rejoin the SignalR group for this game
      await _hub!.invoke('AddToGameAsync', args: [gameId]);

      // Fetch current game state immediately (don't wait for next question tick)
      final stateRes = await _http.get(
        Uri.parse('$baseUrl/api/games/state?gameId=$gameId'),
        headers: _headers,
      );

      if (stateRes.statusCode == 200) {
        _gameState = GameStateDto.fromJson(
            json.decode(stateRes.body) as Map<String, dynamic>);
        _status = GameStatus.inGame;
        notifyListeners();
      }
    } catch (_) {
      // Silently ignore — user simply has no active game
    }
  }

  Future<void> startSearch(String languageId,
      {String languageName = '', int rating = 0}) async {
    _error = null;
    _selectedLanguageId = languageId;
    _selectedLanguageName = languageName;
    _languageNames[languageId] = languageName;
    if (!_languageRatings.containsKey(languageId)) {
      _languageRatings[languageId] = rating;
    }
    _inviteHandled = false;
    _gameId = null;
    _gameState = null;
    _gameResult = null;
    _status = GameStatus.searching;
    notifyListeners();

    try {
      await _hub!.invoke('StartSearchGameAsync', args: [userId, languageId]);
      final response = await _http.post(
        Uri.parse('$baseUrl/api/games?languageId=$languageId'),
        headers: _headers,
        body: '{}',
      );
      if (response.statusCode >= 400) {
        throw Exception('Server error: ${response.body}');
      }
    } catch (e) {
      _error = e.toString();
      _status = GameStatus.idle;
      notifyListeners();
    }
  }

  Future<void> cancelSearch() async {
    if (_selectedLanguageId == null) return;
    try {
      await _hub!
          .invoke('StopSearchGameAsync', args: [userId, _selectedLanguageId!]);
      await _http.delete(
        Uri.parse('$baseUrl/api/games?languageId=$_selectedLanguageId'),
        headers: _headers,
      );
    } catch (_) {}
    _status = GameStatus.idle;
    _selectedLanguageId = null;
    notifyListeners();
  }

  Future<void> submitAnswer(String answerId) async {
    if (_gameId == null) return;
    try {
      await _http.post(
        Uri.parse(
            '$baseUrl/api/games/answer?gameId=$_gameId&answerId=$answerId'),
        headers: _headers,
        body: '{}',
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> leaveGame() async {
    if (_gameId != null) {
      try {
        await _hub!.invoke('LeaveGameAsync', args: [_gameId!]);
      } catch (_) {}
    }
    _status = GameStatus.idle;
    _gameId = null;
    _gameState = null;
    _gameResult = null;
    _selectedLanguageId = null;
    _inviteHandled = false;
    notifyListeners();
  }

  Future<List<LanguageDto>> fetchLanguages() async {
    try {
      final response = await _http.get(
        Uri.parse('$baseUrl/api/Languages'),
        headers: _headers,
      );
      if (response.statusCode != 200) return [];
      final list = json.decode(response.body) as List<dynamic>;
      final languages = list
          .map((e) => LanguageDto.fromJson(e as Map<String, dynamic>))
          .toList();

      for (final lang in languages) {
        _languageRatings[lang.id] = lang.rating;
        _languageNames[lang.id] = lang.name;
      }

      return languages;
    } catch (_) {
      return [];
    }
  }

  @override
  void dispose() {
    _hub?.stop();
    _http.close();
    super.dispose();
  }
}