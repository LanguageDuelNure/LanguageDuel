import 'package:flutter_test/flutter_test.dart';

import 'package:language_duel/models/game_models.dart';
import 'package:language_duel/services/api_service.dart';

void main() {
  group('GameStateDto.fromJson', () {
    test('parses full payload with all fields', () {
      final json = {
        'currentQuestion': {
          'id': 'q-1',
          'name': 'What is "apple" in Spanish?',
          'answers': [
            {'id': 'a', 'name': 'manzana'},
            {'id': 'b', 'name': 'naranja'},
            {'id': 'c', 'name': 'pera'},
            {'id': 'd', 'name': 'uva'},
          ],
          'userAnswers': <String, dynamic>{},
        },
        'users': [
          {'id': '1', 'name': 'Alex', 'hp': 100, 'rating': 1500},
          {'id': '2', 'name': 'Bob', 'hp': 80, 'rating': 1480},
        ],
        'timeRemainingInSeconds': 12,
        'correctAnswerId': null,
      };

      final dto = GameStateDto.fromJson(json);

      expect(dto.timeRemainingInSeconds, 12);
      expect(dto.correctAnswerId, isNull);
      expect(dto.users.length, 2);
      expect(dto.users[0].hp, 100);
      expect(dto.users[0].name, 'Alex');
      expect(dto.users[1].hp, 80);
      expect(dto.currentQuestion, isNotNull);
      expect(dto.currentQuestion!.id, 'q-1');
      expect(dto.currentQuestion!.answers.length, 4);
      expect(dto.currentQuestion!.answers[0].name, 'manzana');
    });

    test('handles null correctAnswerId (question still in progress)', () {
      final json = {
        'currentQuestion': null,
        'users': [
          {'id': '1', 'name': 'Alex', 'hp': 60, 'rating': 1500},
          {'id': '2', 'name': 'Bob', 'hp': 40, 'rating': 1480},
        ],
        'timeRemainingInSeconds': 8,
        'correctAnswerId': null,
      };

      final dto = GameStateDto.fromJson(json);

      expect(dto.correctAnswerId, isNull);
      expect(dto.currentQuestion, isNull);
    });

    test('parses correctAnswerId when question is finished', () {
      final json = {
        'currentQuestion': null,
        'users': [
          {'id': '1', 'name': 'Alex', 'hp': 100, 'rating': 1500},
          {'id': '2', 'name': 'Bob', 'hp': 60, 'rating': 1480},
        ],
        'timeRemainingInSeconds': 0,
        'correctAnswerId': 'a',
      };

      final dto = GameStateDto.fromJson(json);

      expect(dto.correctAnswerId, equals('a'));
    });

    test('handles empty users array', () {
      final json = {
        'currentQuestion': null,
        'users': <dynamic>[],
        'timeRemainingInSeconds': 15,
        'correctAnswerId': null,
      };

      final dto = GameStateDto.fromJson(json);

      expect(dto.users, isEmpty);
    });
  });

  group('GameSessionUserDto.fromJson', () {
    test('parses full user with rating and imageUrl', () {
      final dto = GameSessionUserDto.fromJson({
        'id': '42',
        'name': 'Alex',
        'hp': 75,
        'rating': 1620,
        'imageUrl': 'https://cdn/avatar.png',
      });

      expect(dto.id, '42');
      expect(dto.name, 'Alex');
      expect(dto.hp, 75);
      expect(dto.rating, 1620);
      expect(dto.imageUrl, 'https://cdn/avatar.png');
    });

    test('uses default hp=100 when missing', () {
      final dto = GameSessionUserDto.fromJson({
        'id': '1',
        'name': 'Bob',
        'rating': 1500,
      });

      expect(dto.hp, 100);
      expect(dto.imageUrl, isNull);
    });
  });

  group('UserDto.fromJson', () {
    test('parses user with full statistics', () {
      final dto = UserDto.fromJson({
        'id': '42',
        'name': 'Alex',
        'imageUrl': 'https://cdn/avatar.png',
        'totalGames': 100,
        'totalWins': 65,
        'languageRatings': [],
        'isBanned': false,
      });

      expect(dto.id, '42');
      expect(dto.name, 'Alex');
      expect(dto.totalGames, 100);
      expect(dto.totalWins, 65);
      expect(dto.imageUrl, 'https://cdn/avatar.png');
      expect(dto.isBanned, isFalse);
      expect(dto.bannedUntil, isNull);
    });

    test('parses banned user with bannedUntil timestamp', () {
      final dto = UserDto.fromJson({
        'id': '99',
        'name': 'Mallory',
        'totalGames': 5,
        'totalWins': 1,
        'languageRatings': [],
        'isBanned': true,
        'bannedUntil': '2026-12-31T23:59:59Z',
      });

      expect(dto.isBanned, isTrue);
      expect(dto.bannedUntil, isNotNull);
      expect(dto.bannedUntil!.year, 2026);
    });

    test('parses user with multiple language ratings', () {
      final dto = UserDto.fromJson({
        'id': '7',
        'name': 'Anna',
        'totalGames': 50,
        'totalWins': 30,
        'languageRatings': [
          {
            'languageId': 'en',
            'rating': 1500,
            'maxRating': 1600,
            'totalGames': 30,
            'totalWins': 20,
          },
          {
            'languageId': 'es',
            'rating': 1200,
            'maxRating': 1300,
            'totalGames': 20,
            'totalWins': 10,
          },
        ],
        'isBanned': false,
      });

      expect(dto.languageRatings.length, 2);
      expect(dto.languageRatings[0].languageId, 'en');
      expect(dto.languageRatings[0].rating, 1500);
      expect(dto.languageRatings[1].languageId, 'es');
    });
  });

  group('LanguageDto.fromJson', () {
    test('parses language id, name and rating', () {
      final dto = LanguageDto.fromJson({
        'id': 'en',
        'name': 'English',
        'rating': 1500,
      });

      expect(dto.id, 'en');
      expect(dto.name, 'English');
      expect(dto.rating, 1500);
    });

    test('defaults rating to 0 when missing', () {
      final dto = LanguageDto.fromJson({'id': 'fr', 'name': 'French'});

      expect(dto.rating, 0);
    });
  });

  group('LeaderboardItemDto.fromJson', () {
    test('parses leaderboard entry with all fields', () {
      final dto = LeaderboardItemDto.fromJson({
        'id': '7',
        'name': 'Anna',
        'language': 'en',
        'imageUrl': 'https://cdn/anna.png',
        'totalWins': 30,
        'totalGames': 50,
        'rank': 1,
      });

      expect(dto.id, '7');
      expect(dto.name, 'Anna');
      expect(dto.language, 'en');
      expect(dto.imageUrl, 'https://cdn/anna.png');
      expect(dto.totalWins, 30);
      expect(dto.totalGames, 50);
      expect(dto.rank, 1);
    });

    test('uses default values for missing optional fields', () {
      final dto = LeaderboardItemDto.fromJson({
        'id': '7',
        'name': 'Anna',
      });

      expect(dto.language, '');
      expect(dto.imageUrl, isNull);
      expect(dto.totalWins, 0);
      expect(dto.totalGames, 0);
      expect(dto.rank, 0);
    });
  });
}