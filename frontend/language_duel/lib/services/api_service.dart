import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../utils/app_constants.dart';
import '../models/game_models.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? field;
  final DateTime? bannedUntil;
  final String? banReason;

  const ApiException({
    required this.message,
    this.statusCode,
    this.field,
    this.bannedUntil,
    this.banReason,
  });

  bool get isBanned => statusCode == 403 || statusCode == 401 || message.toLowerCase().contains('banned');

  @override
  String toString() =>
      'ApiException($statusCode): $message'
      '${field != null ? ' [field: $field]' : ''}'
      '${bannedUntil != null ? ' [bannedUntil: $bannedUntil]' : ''}'
      '${banReason != null ? ' [banReason: $banReason]' : ''}';
}

class ApiService {
  static String get serverUrl => AppConstants.serverUrl;
  static String get baseUrl => '${AppConstants.serverUrl}/api';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _buildHeaders({String? token}) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<Map<String, dynamic>> _parseResponse(http.Response response) async {
    final statusCode = response.statusCode;
    final isSuccess = statusCode >= 200 && statusCode < 300;

    if (isSuccess) {
      if (response.body.isEmpty) return {};
      return json.decode(response.body) as Map<String, dynamic>;
    }

    String errorMessage = 'Request failed with status $statusCode';
    String? field;
    DateTime? bannedUntil;
    String? banReason;

    try {
      final body = json.decode(response.body) as Map<String, dynamic>;
      
      if (body.containsKey('bannedUntil') && body['bannedUntil'] != null) {
        bannedUntil = DateTime.tryParse(body['bannedUntil'].toString());
      }

      final errors = body['errors'] as List<dynamic>?;

      if (errors != null && errors.isNotEmpty) {
        final firstError = errors.first as Map<String, dynamic>;
        errorMessage = firstError['message'] as String? ?? errorMessage;
        field = firstError['field'] as String?;
        
        if (firstError.containsKey('bannedUntil') && firstError['bannedUntil'] != null) {
          bannedUntil ??= DateTime.tryParse(firstError['bannedUntil'].toString());
        }

        // Parse Parameters dictionary for Reason and the newly added BannedUntil
        if (firstError.containsKey('parameters') && firstError['parameters'] != null) {
          final params = firstError['parameters'] as Map<String, dynamic>;
          banReason = params['Reason']?.toString() ?? params['reason']?.toString();
          
          final blockedUntilStr = params['BannedUntil']?.toString() ?? params['bannedUntil']?.toString();
          if (blockedUntilStr != null) {
            bannedUntil ??= DateTime.tryParse(blockedUntilStr);
          }
        }
      }
    } catch (_) {}

    throw ApiException(
      message: errorMessage,
      statusCode: statusCode,
      field: field,
      bannedUntil: bannedUntil,
      banReason: banReason,
    );
  }

  Future<RegisterResult> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/Users/register'),
      headers: _buildHeaders(),
      body: json.encode({
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'name': name,
      }),
    );

    final data = await _parseResponse(response);
    return RegisterResult.fromJson(data);
  }

  Future<ConfirmEmailResult> confirmEmail({
    required String userId,
    required String code,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/Users/confirm-email'),
      headers: _buildHeaders(),
      body: json.encode({'userId': userId, 'code': code}),
    );

    final data = await _parseResponse(response);
    return ConfirmEmailResult.fromJson(data);
  }

  Future<void> resendConfirmEmail({required String userId}) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/Users/resend-confirm-email'),
      headers: _buildHeaders(),
      body: json.encode({'userId': userId}),
    );

    await _parseResponse(response);
  }

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/Users/login'),
      headers: _buildHeaders(),
      body: json.encode({'email': email, 'password': password}),
    );

    final data = await _parseResponse(response);
    return LoginResult.fromJson(data);
  }

  Future<UserDto> getUser({
    required String userId,
    required String token,
  }) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/Users/$userId'),
      headers: _buildHeaders(token: token),
    );

    final data = await _parseResponse(response);
    return UserDto.fromJson(data);
  }

  Future<void> updateProfileWithAvatar({
    required String token,
    String? name,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/Users'));
    request.headers['Authorization'] = 'Bearer $token';

    if (name != null) request.fields['Name'] = name;

    if (imageBytes != null && imageName != null) {
      final ext = imageName.split('.').last.toLowerCase();
      final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
      request.files.add(http.MultipartFile.fromBytes(
        'Icon',
        imageBytes,
        filename: imageName,
        contentType: MediaType.parse(contentType),
      ));
    }

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 400) {
      throw const ApiException(
        message: 'Failed to update profile. Please try again.',
      );
    }
  }

  Future<void> updateProfile({
    required String token,
    required String name,
  }) async {
    await updateProfileWithAvatar(token: token, name: name);
  }

  Future<LoginResult> googleLogin(String idToken) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/Users/google-login'),
      headers: _buildHeaders(),
      body: json.encode({'idToken': idToken}),
    );

    final data = await _parseResponse(response);
    return LoginResult.fromJson(data);
  }

  Future<List<LeaderboardItemDto>> getLeaderboard({String? languageId}) async {
    final uri = Uri.parse('$baseUrl/Users/leaderboard').replace(
      queryParameters: languageId != null ? {'languageId': languageId} : null,
    );

    final response = await _client.get(uri, headers: _buildHeaders());
    final data = json.decode(response.body) as List<dynamic>;
    return data
        .map((e) => LeaderboardItemDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<UserAdminListItemDto>> getAllUsers({required String token}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/Users'),
      headers: _buildHeaders(token: token),
    );

    if (response.statusCode >= 400) {
      await _parseResponse(response);
    }

    final decoded = json.decode(response.body);
    if (decoded is List) {
      return decoded
          .map((e) => UserAdminListItemDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    final list = (decoded as Map<String, dynamic>)['users'] as List<dynamic>? ?? [];
    return list
        .map((e) => UserAdminListItemDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> banUser({
    required String token,
    required String userId,
    required int days,
    required String reason, // ADDED REASON
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/Users/$userId/ban'),
      headers: _buildHeaders(token: token),
      body: json.encode({'days': days, 'reason': reason}), // ADDED REASON
    );

    await _parseResponse(response);
  }

  Future<void> unbanUser({
    required String token,
    required String userId,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/Users/$userId/unban'),
      headers: _buildHeaders(token: token),
    );

    await _parseResponse(response);
  }

  // ─── GAME HISTORY ──────────────────────────────────────────────────────────

  Future<List<GameHistoryListItemDto>> getGamesHistory({required String token}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/Games/history'),
      headers: _buildHeaders(token: token),
    );
    
    // Check for errors first
    if (response.statusCode >= 400) {
      await _parseResponse(response); // let it throw the ApiException
    }
    
    // Parse directly as a list
    final decoded = json.decode(response.body);
    final list = decoded is List ? decoded : (decoded['value'] as List<dynamic>? ?? []);
    return list.map((e) => GameHistoryListItemDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<GameHistoryDetailDto> getGameHistory({required String token, required String gameId}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/Games/$gameId/history'),
      headers: _buildHeaders(token: token),
    );
    final data = await _parseResponse(response); // Objects (Maps) are fine here
    return GameHistoryDetailDto.fromJson(data['value'] ?? data);
  }

  // ─── TICKETS ───────────────────────────────────────────────────────────────

  Future<void> createTicket({required String token, required String message, String? ticketId}) async {
    // Only send ticketId if it exists to prevent C# null parsing errors
    final body = <String, dynamic>{'message': message};
    if (ticketId != null) {
      body['ticketId'] = ticketId;
    }
    
    final response = await _client.post(
      Uri.parse('$baseUrl/Tickets'),
      headers: _buildHeaders(token: token),
      body: json.encode(body),
    );
    await _parseResponse(response);
  }

  Future<List<TicketListItemDto>> getTicketsByUser({required String token}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/Tickets'),
      headers: _buildHeaders(token: token),
    );
    
    if (response.statusCode >= 400) {
      await _parseResponse(response); 
    }
    
    final decoded = json.decode(response.body);
    // Safely extract the list whether it is direct or wrapped in a 'value' object
    final list = decoded is List ? decoded : ((decoded as Map?)?['value'] as List<dynamic>? ?? []);
    
    final parsedTickets = <TicketListItemDto>[];
    for (var item in list) {
      try {
        // Map.from() is crucial here to prevent Flutter Web TypeError crashes
        parsedTickets.add(TicketListItemDto.fromJson(Map<String, dynamic>.from(item as Map)));
      } catch (e) {
        // If a single ticket fails, it will log it here instead of breaking the whole screen
        print('Failed to parse a ticket: $e');
        print('Problematic ticket data: $item');
      }
    }
    
    return parsedTickets;
  }

  Future<TicketDto> getTicket({required String token, required String ticketId}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/Tickets/$ticketId'),
      headers: _buildHeaders(token: token),
    );
    final data = await _parseResponse(response);
    return TicketDto.fromJson(data['value'] ?? data);
  }

  Future<List<TicketListItemDto>> getAdminTickets({required String token, required String status}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/Tickets/$status'),
      headers: _buildHeaders(token: token),
    );
    
    // Check for errors before parsing the list
    if (response.statusCode >= 400) {
      await _parseResponse(response); 
    }
    
    // Safe list parsing
    final decoded = json.decode(response.body);
    final list = decoded is List ? decoded : (decoded['value'] as List<dynamic>? ?? []);
    return list.map((e) => TicketListItemDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> replyToTicket({required String token, required String ticketId, required String message}) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/Tickets/reply'),
      headers: _buildHeaders(token: token),
      body: json.encode({'ticketId': ticketId, 'message': message}),
    );
    await _parseResponse(response);
  }

  // Used by regular users (including banned) to add a message to their own ticket
  Future<void> addUserMessage({required String token, required String ticketId, required String message}) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/Tickets/$ticketId/message'),
      headers: _buildHeaders(token: token),
      body: json.encode({'message': message}),
    );
    await _parseResponse(response);
  }

  Future<void> closeTicket({required String token, required String ticketId}) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/Tickets/$ticketId/close'),
      headers: _buildHeaders(token: token),
    );
    await _parseResponse(response);
  }
}

// ---------------------------------------------------------------------------
// Result / DTO models
// ---------------------------------------------------------------------------

class RegisterResult {
  final String userId;

  const RegisterResult({required this.userId});

  factory RegisterResult.fromJson(Map<String, dynamic> json) =>
      RegisterResult(userId: json['userId'] as String);
}

class ConfirmEmailResult {
  final String role;
  final String jwtToken;

  const ConfirmEmailResult({required this.role, required this.jwtToken});

  factory ConfirmEmailResult.fromJson(Map<String, dynamic> json) =>
      ConfirmEmailResult(
        role: json['role'] as String,
        jwtToken: json['jwtToken'] as String,
      );
}

class LoginResult {
  final String userId;
  final bool emailConfirmed;
  final String role;
  final String? jwtToken;
  final bool isNewUser;

  const LoginResult({
    required this.userId,
    required this.emailConfirmed,
    required this.role,
    this.jwtToken,
    this.isNewUser = false,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) => LoginResult(
    userId: json['userId'] as String,
    emailConfirmed: json['emailConfirmed'] as bool,
    role: json['role'] as String,
    jwtToken: json['jwtToken'] as String?,
    isNewUser: json['isNewUser'] as bool? ?? false,
  );
}

class UserLanguageDto {
  final String languageId;
  final int rating;
  final int maxRating;
  final int totalGames;
  final int totalWins;

  const UserLanguageDto({
    required this.languageId,
    required this.rating,
    required this.maxRating,
    required this.totalGames,
    required this.totalWins,
  });

  factory UserLanguageDto.fromJson(Map<String, dynamic> json) =>
      UserLanguageDto(
        languageId: (json['languageId'] as String?) ?? '',
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        maxRating: (json['maxRating'] as num?)?.toInt() ?? 0,
        totalGames: (json['totalGames'] as num?)?.toInt() ?? 0,
        totalWins: (json['totalWins'] as num?)?.toInt() ?? 0,
      );
}

class UserDto {
  final String id;
  final String name;
  final String? imageUrl;
  final int totalGames;
  final int totalWins;
  final List<UserLanguageDto> languageRatings;
  final bool isBanned;
  final DateTime? bannedUntil;

  const UserDto({
    required this.id,
    required this.name,
    this.imageUrl,
    this.totalGames = 0,
    this.totalWins = 0,
    this.languageRatings = const [],
    this.isBanned = false,
    this.bannedUntil,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['bannedUntil'] != null) {
      parsedDate = DateTime.tryParse(json['bannedUntil'].toString());
    }

    return UserDto(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      totalGames: (json['totalGames'] as num?)?.toInt() ?? 0,
      totalWins: (json['totalWins'] as num?)?.toInt() ?? 0,
      languageRatings: (json['languageRatings'] as List<dynamic>? ?? [])
          .map((e) => UserLanguageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      isBanned: json['isBanned'] as bool? ?? false,
      bannedUntil: parsedDate,
    );
  }
}

class LeaderboardItemDto {
  final String id;
  final String name;
  final String language;
  final String? imageUrl;
  final int totalWins;
  final int totalGames;
  final int rank;

  const LeaderboardItemDto({
    required this.id,
    required this.name,
    required this.language,
    this.imageUrl,
    required this.totalWins,
    required this.totalGames,
    required this.rank,
  });

  factory LeaderboardItemDto.fromJson(Map<String, dynamic> json) =>
      LeaderboardItemDto(
        id: json['id'] as String,
        name: json['name'] as String,
        language: json['language'] as String? ?? '',
        imageUrl: json['imageUrl'] as String?,
        totalWins: (json['totalWins'] as num?)?.toInt() ?? 0,
        totalGames: (json['totalGames'] as num?)?.toInt() ?? 0,
        rank: (json['rank'] as num?)?.toInt() ?? 0,
      );
}

class UserAdminListItemDto {
  final String id;
  final String name;
  final String? email;
  final String? imageUrl;
  final bool isBanned;
  final DateTime? bannedUntil;

  const UserAdminListItemDto({
    required this.id,
    required this.name,
    this.email,
    this.imageUrl,
    required this.isBanned,
    this.bannedUntil,
  });

  factory UserAdminListItemDto.fromJson(Map<String, dynamic> json) {
    DateTime? bannedUntil;
    final raw = json['bannedUntil'] as String?;
    if (raw != null) bannedUntil = DateTime.tryParse(raw);

    return UserAdminListItemDto(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isBanned: json['isBanned'] as bool? ?? false,
      bannedUntil: bannedUntil,
    );
  }
}

// Handles both ISO 8601 and the API's "M/d/yyyy h:mm:ss AM/PM" format safely
DateTime _parseDate(String? raw) {
  if (raw == null || raw.isEmpty) return DateTime.now();
  final iso = DateTime.tryParse(raw);
  if (iso != null) return iso;
  try {
    final parts = raw.split(' ');
    if (parts.length >= 2) {
      final d = parts[0].split('/');
      final t = parts[1].split(':');
      if (d.length == 3 && t.length == 3) {
        int month = int.parse(d[0]);
        int day   = int.parse(d[1]);
        int year  = int.parse(d[2]);
        int hour  = int.parse(t[0]);
        int min   = int.parse(t[1]);
        int sec   = int.parse(t[2]);
        final ampm = parts.length == 3 ? parts[2].toUpperCase() : '';
        if (ampm == 'PM' && hour != 12) hour += 12;
        if (ampm == 'AM' && hour == 12) hour = 0;
        return DateTime(year, month, day, hour, min, sec);
      }
    }
  } catch (_) {}
  return DateTime.now();
}

class GameHistoryListItemDto {
  final String id;
  final DateTime createdAt;
  final bool isVictory;
  final String yourName;
  final String opponentName;
  final String languageName;
  final String difficultyLevelName;

  GameHistoryListItemDto.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        createdAt = _parseDate(json['createdAt']?.toString()),
        isVictory = json['isVictory'] ?? false,
        yourName = json['yourName'] ?? '',
        opponentName = json['opponentName'] ?? '',
        languageName = json['languageName'] ?? '',
        difficultyLevelName = json['difficultyLevelName'] ?? '';
}

class GameHistoryDetailDto {
  final bool isVictory;
  final DateTime createdAt;
  final String yourName;
  final String opponentName;
  final String languageName;
  final String difficultyLevelName;
  final List<QuestionDto> questions;

  GameHistoryDetailDto.fromJson(Map<String, dynamic> json)
      : isVictory = json['isVictory'] ?? false,
        createdAt = _parseDate(json['createdAt']?.toString()),
        yourName = json['yourName'] ?? '',
        opponentName = json['opponentName'] ?? '',
        languageName = json['languageName'] ?? '',
        difficultyLevelName = json['difficultyLevelName'] ?? '',
        questions = (json['questions'] as List<dynamic>? ?? [])
            .map((q) => QuestionDto.fromJson(q))
            .toList();
}

class TicketListItemDto {
  final String id;
  final String? userId;
  final String userName;
  final String? lastMessage;
  final String status;
  final DateTime createdAt;

  TicketListItemDto.fromJson(Map<String, dynamic> json)
      : id = json['id']?.toString() ?? '000000',
        userId = json['userId']?.toString(),
        userName = json['userName']?.toString() ?? 'User',
        lastMessage = json['lastMessage']?.toString(),
        status = json['status']?.toString() ?? 'Open',
        createdAt = _parseDate(json['createdAt']?.toString());
}

class TicketMessageDto {
  final String id;
  final String message;
  final DateTime createdAt;
  final bool isMine;
  final String? userId;

  TicketMessageDto.fromJson(Map<String, dynamic> json)
      : id = json['id']?.toString() ?? '',
        message = json['message']?.toString() ?? '',
        createdAt = _parseDate(json['createdAt']?.toString()),
        isMine = json['isMine'] ?? false,
        userId = json['userId']?.toString();
}

class TicketDto {
  final String id;
  final String userName;
  final String status;
  final DateTime createdAt;
  final String? userId;
  final List<TicketMessageDto> messages;

  TicketDto.fromJson(Map<String, dynamic> json)
      : id = json['id']?.toString() ?? '',
        userName = json['userName']?.toString() ?? '',
        status = json['status']?.toString() ?? 'Open',
        createdAt = _parseDate(json['createdAt']?.toString()),
        userId = json['userId']?.toString(),
        messages = (json['messages'] as List<dynamic>? ?? [])
            .map((m) => TicketMessageDto.fromJson(m as Map<String, dynamic>))
            .toList();
}