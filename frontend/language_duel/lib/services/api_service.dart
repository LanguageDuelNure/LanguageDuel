import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? field;

  const ApiException({
    required this.message,
    this.statusCode,
    this.field,
  });

  @override
  String toString() => 'ApiException($statusCode): $message'
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
}

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

  const LoginResult({
    required this.userId,
    required this.emailConfirmed,
    required this.role,
    this.jwtToken,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) => LoginResult(
        userId: json['userId'] as String,
        emailConfirmed: json['emailConfirmed'] as bool,
        role: json['role'] as String,
        jwtToken: json['jwtToken'] as String?,
      );
}

class UserDto {
  final String id;
  final String name;

  const UserDto({required this.id, required this.name});

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json['id'] as String,
        name: json['name'] as String,
      );
}