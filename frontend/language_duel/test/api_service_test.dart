import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;

import 'package:language_duel/services/api_service.dart';

import 'api_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  late ApiService api;

  setUp(() {
    mockClient = MockClient();
    api = ApiService(client: mockClient);
  });

  group('ApiService.getLeaderboard', () {
    test('returns parsed list on 200 OK', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(
          '[{"id":"u-1","name":"Alex","language":"en",'
          '"totalWins":15,"totalGames":20,"rank":1},'
          '{"id":"u-2","name":"Bob","language":"en",'
          '"totalWins":10,"totalGames":18,"rank":2}]',
          200,
        ),
      );

      final result = await api.getLeaderboard(languageId: 'en');

      expect(result.length, 2);
      expect(result[0].name, 'Alex');
      expect(result[0].rank, 1);
      expect(result[0].totalWins, 15);
      expect(result[1].name, 'Bob');
    });

    test('returns empty list when server returns []', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response('[]', 200),
      );

      final result = await api.getLeaderboard(languageId: 'en');

      expect(result, isEmpty);
    });

    test('appends languageId as query parameter when provided', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response('[]', 200),
      );

      await api.getLeaderboard(languageId: 'en');

      final captured =
          verify(mockClient.get(captureAny, headers: anyNamed('headers')))
              .captured;
      final uri = captured.first as Uri;

      expect(uri.queryParameters['languageId'], equals('en'));
      expect(uri.path, contains('/Users/leaderboard'));
    });

    test('sends request without query parameters when languageId is null',
        () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response('[]', 200),
      );

      await api.getLeaderboard();

      final captured =
          verify(mockClient.get(captureAny, headers: anyNamed('headers')))
              .captured;
      final uri = captured.first as Uri;

      expect(uri.queryParameters['languageId'], isNull);
    });

    test('parses items with default values for missing optional fields',
        () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(
          '[{"id":"u-3","name":"Charlie","language":"es","rank":3}]',
          200,
        ),
      );

      final result = await api.getLeaderboard(languageId: 'es');

      expect(result.length, 1);
      expect(result[0].name, 'Charlie');
      expect(result[0].totalWins, 0);
      expect(result[0].totalGames, 0);
      expect(result[0].imageUrl, isNull);
    });
  });

  group('ApiService.login error handling', () {
    test('throws ApiException with statusCode 401 on Unauthorized', () async {
      when(
        mockClient.post(any,
            headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer(
        (_) async => http.Response(
          '{"errors":[{"message":"Invalid credentials"}]}',
          401,
        ),
      );

      expect(
        () => api.login(email: 'a@b.com', password: 'wrong'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 401)),
      );
    });

    test('throws ApiException with parsed error message on 400', () async {
      when(
        mockClient.post(any,
            headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer(
        (_) async => http.Response(
          '{"errors":[{"message":"Email is required","field":"email"}]}',
          400,
        ),
      );

      try {
        await api.login(email: '', password: 'p');
        fail('Expected ApiException');
      } on ApiException catch (e) {
        expect(e.message, equals('Email is required'));
        expect(e.field, equals('email'));
        expect(e.statusCode, 400);
      }
    });

    test('throws ApiException on 500 Internal Server Error', () async {
      when(
        mockClient.post(any,
            headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer(
        (_) async => http.Response('Internal error', 500),
      );

      expect(
        () => api.login(email: 'a@b.com', password: 'p'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 500)),
      );
    });
  });

  group('ApiService.getUser', () {
    test('sends Authorization header with Bearer token', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(
          '{"id":"42","name":"Alex","totalGames":10,"totalWins":7,'
          '"languageRatings":[],"isBanned":false}',
          200,
        ),
      );

      await api.getUser(userId: '42', token: 'jwt_test_token');

      final captured = verify(
        mockClient.get(any, headers: captureAnyNamed('headers')),
      ).captured;
      final headers = captured.first as Map<String, String>;

      expect(headers['Authorization'], equals('Bearer jwt_test_token'));
      expect(headers['Content-Type'], equals('application/json'));
    });

    test('parses UserDto correctly from response', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(
          '{"id":"42","name":"Alex","imageUrl":"https://cdn/a.png",'
          '"totalGames":50,"totalWins":30,'
          '"languageRatings":[],"isBanned":false}',
          200,
        ),
      );

      final user = await api.getUser(userId: '42', token: 't');

      expect(user.id, '42');
      expect(user.name, 'Alex');
      expect(user.imageUrl, 'https://cdn/a.png');
      expect(user.totalGames, 50);
      expect(user.totalWins, 30);
      expect(user.isBanned, isFalse);
    });
  });
}