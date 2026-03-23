// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../models/game_models.dart';
import '../../services/game_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/grid_background.dart';

class ResultView extends StatelessWidget {
  final GameResultDto result;

  const ResultView({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameService>();
    final didWin = result.winnerUserId == game.userId;
    final isDraw = result.winnerUserId == null;

    // Server returns absolute magnitude. Apply sign by outcome:
    // win → +x, loss → -x, draw → 0 (server doesn't subtract for draw)
    final magnitude = result.ratingChangeAfterWinOrLoss.abs();
    final signedDelta = isDraw ? 0 : (didWin ? magnitude : -magnitude);
    final ratingText = signedDelta > 0
        ? '+$signedDelta'
        : '$signedDelta'; // shows "0" for draw, "-6" for loss
    final ratingAction = signedDelta > 0
        ? 'points gained'
        : signedDelta < 0
            ? 'points lost'
            : 'no change';
    final ratingBadgeColor = signedDelta > 0
        ? AppTheme.accent
        : signedDelta < 0
            ? AppTheme.danger
            : Colors.orange;

    final newRating = game.currentRating;

    final outcomeColor = isDraw
        ? Colors.orange
        : didWin
            ? AppTheme.accent
            : AppTheme.danger;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          const Positioned.fill(
            child: GridBackground(
              glowAlignment: Alignment.center,
              glowRadius: 0.7,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: outcomeColor.withOpacity(0.15),
                      border: Border.all(color: outcomeColor, width: 2),
                    ),
                    child: Icon(
                      isDraw
                          ? Icons.handshake_outlined
                          : didWin
                              ? Icons.emoji_events
                              : Icons.sentiment_dissatisfied_outlined,
                      color: outcomeColor,
                      size: 44,
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 20),

                  Text(
                    isDraw ? 'Draw!' : didWin ? 'Victory!' : 'Defeat',
                    style: TextStyle(
                      color: outcomeColor,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  if (!isDraw && result.winnerUserName != null)
                    Text(
                      didWin ? 'Well played!' : '${result.winnerUserName} wins',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 15),
                    ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RatingBadge(
                        label: ratingText,
                        sublabel: ratingAction,
                        color: ratingBadgeColor,
                      ),
                      const SizedBox(width: 12),
                      RatingBadge(
                        label: '$newRating',
                        sublabel: '${game.selectedLanguageName} rating',
                        color: AppTheme.accent,
                      ),
                    ],
                  ).animate().fadeIn(delay: 350.ms),

                  const SizedBox(height: 32),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Round Summary',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...result.questions.asMap().entries.map((entry) {
                    final i = entry.key;
                    final q = entry.value;
                    final myAnswerId = q.userAnswers[game.userId];
                    final correctAnswer =
                        q.answers.where((a) => a.isCorrect).firstOrNull;
                    final myAnswer =
                        q.answers.where((a) => a.id == myAnswerId).firstOrNull;
                    final wasCorrect = myAnswer != null && myAnswer.isCorrect;

                    return QuestionReviewCard(
                      index: i,
                      question: q,
                      myAnswer: myAnswer,
                      correctAnswer: correctAnswer,
                      wasCorrect: wasCorrect,
                    ).animate().fadeIn(
                        delay: Duration(milliseconds: 400 + i * 60));
                  }),

                  const SizedBox(height: 32),

                  ElevatedButton.icon(
                    onPressed: () async => game.leaveGame(),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Back to Lobby'),
                  ).animate().fadeIn(delay: 500.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RatingBadge extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;

  const RatingBadge({
    super.key,
    required this.label,
    required this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: color, size: 15),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class QuestionReviewCard extends StatelessWidget {
  final int index;
  final QuestionDto question;
  final AnswerDto? myAnswer;
  final AnswerDto? correctAnswer;
  final bool wasCorrect;

  const QuestionReviewCard({
    super.key,
    required this.index,
    required this.question,
    required this.myAnswer,
    required this.correctAnswer,
    required this.wasCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: wasCorrect
              ? AppTheme.accent.withOpacity(0.3)
              : AppTheme.danger.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                wasCorrect ? Icons.check_circle : Icons.cancel,
                color: wasCorrect ? AppTheme.accent : AppTheme.danger,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Q${index + 1}: ${question.name}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          if (myAnswer != null) ...[
            const SizedBox(height: 8),
            Text(
              'Your answer: ${myAnswer!.name}',
              style: TextStyle(
                color: wasCorrect ? AppTheme.accent : AppTheme.danger,
                fontSize: 12,
              ),
            ),
          ],
          if (!wasCorrect && correctAnswer != null) ...[
            const SizedBox(height: 4),
            Text(
              'Correct: ${correctAnswer!.name}',
              style: const TextStyle(color: AppTheme.accent, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}