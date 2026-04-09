import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? field;

  const ApiException({required this.message, this.statusCode, this.field});

  @override
  String toString() =>
      'ApiException($statusCode): $message'
      '${field != null ? ' [field: $field]' : ''}';
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

    try {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final errors = body['errors'] as List<dynamic>?;

      if (errors != null && errors.isNotEmpty) {
        final firstError = errors.first as Map<String, dynamic>;
        errorMessage = firstError['message'] as String? ?? errorMessage;
        field = firstError['field'] as String?;
      }
    } catch (_) {}

    throw ApiException(
      message: errorMessage,
      statusCode: statusCode,
      field: field,
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

  Future<void> updateProfile({
    required String token,
    required String name,
  }) async {
    final request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/Users'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['Name'] = name;

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 400) {
      throw const ApiException(
        message: 'Failed to save name. Please try again.',
      );
    }
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

  /// Fetch leaderboard. Pass [languageId] to filter by language, or null for global.
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

  const UserDto({
    required this.id,
    required this.name,
    this.imageUrl,
    this.totalGames = 0,
    this.totalWins = 0,
    this.languageRatings = const [],
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
    id: json['id'] as String,
    name: json['name'] as String,
    imageUrl: json['imageUrl'] as String?,
    totalGames: (json['totalGames'] as num?)?.toInt() ?? 0,
    totalWins: (json['totalWins'] as num?)?.toInt() ?? 0,
    languageRatings: (json['languageRatings'] as List<dynamic>? ?? [])
        .map((e) => UserLanguageDto.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
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