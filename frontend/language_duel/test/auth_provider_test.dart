import 'package:flutter_test/flutter_test.dart';
import 'package:language_duel/services/auth_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:language_duel/services/api_service.dart';

import 'auth_provider_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockApiService mockApi;
  late AuthProvider auth;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockApi = MockApiService();
    auth = AuthProvider(api: mockApi);
  });

  group('AuthProvider — initial state', () {
    test('initial state — not authenticated, no token', () {
      expect(auth.isAuthenticated, isFalse);
      expect(auth.token, isNull);
      expect(auth.userId, isNull);
      expect(auth.userName, isNull);
      expect(auth.role, isNull);
      expect(auth.isLoading, isFalse);
    });
  });

  group('AuthProvider.login', () {
    test('login with confirmed email saves token and authenticates user',
        () async {
      when(mockApi.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const LoginResult(
            userId: '42',
            emailConfirmed: true,
            role: 'User',
            jwtToken: 'jwt_abc',
            isNewUser: false,
          ));

      when(mockApi.getUser(
        userId: anyNamed('userId'),
        token: anyNamed('token'),
      )).thenAnswer((_) async => const UserDto(id: '42', name: 'Alex'));

      final result = await auth.login(email: 'a@b.com', password: 'p');

      expect(result, isNull, reason: 'null означає успішний вхід без email-step');
      expect(auth.isAuthenticated, isTrue);
      expect(auth.token, equals('jwt_abc'));
      expect(auth.userId, equals('42'));
      expect(auth.userName, equals('Alex'));
      expect(auth.role, equals('User'));
    });

    test('login with unconfirmed email returns userId without authenticating',
        () async {
      when(mockApi.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const LoginResult(
            userId: '55',
            emailConfirmed: false,
            role: 'User',
            jwtToken: null,
            isNewUser: false,
          ));

      final result = await auth.login(email: 'new@b.com', password: 'p');

      expect(result, equals('55'),
          reason: 'повертається userId, щоб перейти на confirm-email');
      expect(auth.isAuthenticated, isFalse);
      expect(auth.token, isNull);
    });

    test('login persists token to SharedPreferences', () async {
      when(mockApi.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const LoginResult(
            userId: '42',
            emailConfirmed: true,
            role: 'User',
            jwtToken: 'saved_token',
            isNewUser: false,
          ));

      when(mockApi.getUser(
        userId: anyNamed('userId'),
        token: anyNamed('token'),
      )).thenAnswer((_) async => const UserDto(id: '42', name: 'Alex'));

      await auth.login(email: 'a@b.com', password: 'p');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('jwt_token'), equals('saved_token'));
      expect(prefs.getString('user_id'), equals('42'));
      expect(prefs.getString('user_role'), equals('User'));
      expect(prefs.getString('user_name'), equals('Alex'));
    });

    test('login throws ApiException on invalid credentials', () async {
      when(mockApi.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(const ApiException(
        message: 'Invalid credentials',
        statusCode: 401,
      ));

      expect(
        () => auth.login(email: 'a@b.com', password: 'wrong'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 401)),
      );
    });
  });

  group('AuthProvider.logout', () {
    test('logout clears all auth state', () async {
      when(mockApi.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const LoginResult(
            userId: '42',
            emailConfirmed: true,
            role: 'User',
            jwtToken: 'jwt_abc',
            isNewUser: false,
          ));

      when(mockApi.getUser(
        userId: anyNamed('userId'),
        token: anyNamed('token'),
      )).thenAnswer((_) async => const UserDto(id: '42', name: 'Alex'));

      // Спочатку входимо
      await auth.login(email: 'a@b.com', password: 'p');
      expect(auth.isAuthenticated, isTrue);

      // Виходимо
      await auth.logout();

      expect(auth.isAuthenticated, isFalse);
      expect(auth.token, isNull);
      expect(auth.userId, isNull);
      expect(auth.userName, isNull);
      expect(auth.role, isNull);
    });

    test('logout removes token from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'jwt_token': 'old_token',
        'user_id': '42',
        'user_name': 'Alex',
        'user_role': 'User',
      });

      await auth.logout();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('jwt_token'), isNull);
      expect(prefs.getString('user_id'), isNull);
      expect(prefs.getString('user_name'), isNull);
      expect(prefs.getString('user_role'), isNull);
    });

    test('logout calls notifyListeners', () async {
      var notified = false;
      auth.addListener(() => notified = true);

      await auth.logout();

      expect(notified, isTrue);
    });
  });

  group('AuthProvider.register', () {
    test('register returns userId on success', () async {
      when(mockApi.register(
        email: anyNamed('email'),
        password: anyNamed('password'),
        confirmPassword: anyNamed('confirmPassword'),
        name: anyNamed('name'),
      )).thenAnswer(
          (_) async => const RegisterResult(userId: 'new_user_99'));

      final userId = await auth.register(
        email: 'new@b.com',
        password: 'p',
        confirmPassword: 'p',
        name: 'New User',
      );

      expect(userId, equals('new_user_99'));
      // Реєстрація не аутентифікує користувача — потрібно ще підтвердити email
      expect(auth.isAuthenticated, isFalse);
    });
  });
}