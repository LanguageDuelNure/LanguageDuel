import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:signalr_netcore/signalr_client.dart';
import '../models/game_models.dart';

enum GameStatus { idle, searching, inGame, finished }

class GameService extends ChangeNotifier {
  final String baseUrl; // e.g. "http://localhost:5092"
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

  GameStatus get status => _status;
  String? get gameId => _gameId;
  GameStateDto? get gameState => _gameState;
  GameResultDto? get gameResult => _gameResult;
  String? get error => _error;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  GameService({
    required this.baseUrl,
    required this.token,
    required this.userId,
  });

  // ── Connect to SignalR hub ─────────────────────────────────────────────────

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

    // ReceiveGameInvitation  →  mirrors Program.cs logic exactly
    _hub!.on('ReceiveGameInvitation', (args) async {
      if (args == null || args.isEmpty) return;
      final dto = GameInvitationDto.fromJson(args[0] as Map<String, dynamic>);

      // Ignore the self-broadcast (inviterUserId == us AND gameId == null)
      if (_inviteHandled ||
          (dto.inviterUserId == userId && dto.gameId == null)) return;
      _inviteHandled = true;

      _gameId = dto.gameId;
      await _hub!.invoke('StopSearchGameAsync',
          args: [userId, _selectedLanguageId!]);
      await _hub!.invoke('AddToGameAsync', args: [_gameId!]);

      _status = GameStatus.inGame;
      notifyListeners();
    });

    // GameStateChanged
    _hub!.on('GameStateChanged', (args) {
      if (args == null || args.isEmpty) return;
      _gameState = GameStateDto.fromJson(args[0] as Map<String, dynamic>);
      _status = GameStatus.inGame;
      notifyListeners();
    });

    // ReceiveGameResult
    _hub!.on('ReceiveGameResult', (args) {
      if (args == null || args.isEmpty) return;
      _gameResult = GameResultDto.fromJson(args[0] as Map<String, dynamic>);
      _status = GameStatus.finished;
      notifyListeners();
    });

    try {
      await _hub!.start();
    } catch (e) {
      _error = 'Could not connect to game server: $e';
      notifyListeners();
    }
  }

  // ── Start searching ────────────────────────────────────────────────────────

  Future<void> startSearch(String languageId) async {
    _error = null;
    _selectedLanguageId = languageId;
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

  // ── Cancel searching ───────────────────────────────────────────────────────

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

  // ── Submit answer ──────────────────────────────────────────────────────────

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

  // ── Leave game after result ────────────────────────────────────────────────

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

  // ── Fetch available languages ──────────────────────────────────────────────

  Future<List<LanguageDto>> fetchLanguages() async {
    try {
      final response = await _http.get(
        Uri.parse('$baseUrl/api/Languages'),
        headers: _headers,
      );
      if (response.statusCode != 200) return [];
      final list = json.decode(response.body) as List<dynamic>;
      return list
          .map((e) => LanguageDto.fromJson(e as Map<String, dynamic>))
          .toList();
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