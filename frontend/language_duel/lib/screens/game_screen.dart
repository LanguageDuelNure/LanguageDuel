import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/game_models.dart';
import '../services/game_service.dart';
import '../utils/app_theme.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, game, _) {
        return switch (game.status) {
          GameStatus.idle => const SizedBox.shrink(),
          GameStatus.searching => const _SearchingView(),
          GameStatus.inGame => game.gameState == null
              ? const _SearchingView()
              : _GameView(state: game.gameState!),
          GameStatus.finished => game.gameResult == null
              ? const _SearchingView()
              : _ResultView(result: game.gameResult!),
        };
      },
    );
  }
}

// ─── Searching / Matchmaking overlay ─────────────────────────────────────────

class _SearchingView extends StatelessWidget {
  const _SearchingView();

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameService>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          Positioned.fill(child: _GameBg()),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pulsing arena icon
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppTheme.accent.withOpacity(0.2),
                              width: 1),
                        ),
                      ).animate(onPlay: (c) => c.repeat()).scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.3, 1.3),
                            duration: 1500.ms,
                            curve: Curves.easeInOut,
                          ).then().scale(
                            begin: const Offset(1.3, 1.3),
                            end: const Offset(1, 1),
                            duration: 1500.ms,
                          ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accent.withOpacity(0.1),
                          border: Border.all(
                              color: AppTheme.accent.withOpacity(0.4),
                              width: 1.5),
                        ),
                        child: const Icon(Icons.play_arrow,
                            color: AppTheme.accent, size: 36),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Finding opponent...',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: 800.ms).then().fadeOut(duration: 800.ms),
                const SizedBox(height: 10),
                const Text(
                  'Matching you with a player of similar skill',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 40),
                OutlinedButton(
                  onPressed: () => game.cancelSearch(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.danger,
                    side: const BorderSide(color: AppTheme.danger),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Active Game View ─────────────────────────────────────────────────────────

class _GameView extends StatefulWidget {
  final GameStateDto state;

  const _GameView({required this.state});

  @override
  State<_GameView> createState() => _GameViewState();
}

class _GameViewState extends State<_GameView> {
  String? _selectedAnswerId;

  @override
  void didUpdateWidget(_GameView old) {
    super.didUpdateWidget(old);
    // New question arrived — clear selection
    if (old.state.currentQuestion.id != widget.state.currentQuestion.id) {
      _selectedAnswerId = null;
    }
  }

  void _onAnswerTap(String answerId) {
    if (_selectedAnswerId != null) return; // already answered
    setState(() => _selectedAnswerId = answerId);
    context.read<GameService>().submitAnswer(answerId);
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameService>();
    final state = game.gameState ?? widget.state;
    final q = state.currentQuestion;
    final myUserId = game.userId; // handy reference

    // Split users into me and opponent
    final me = state.users.where((u) => u.id == myUserId).firstOrNull;
    final opponent =
        state.users.where((u) => u.id != myUserId).firstOrNull;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          Positioned.fill(child: _GameBg()),
          SafeArea(
            child: Column(
              children: [
                // ── HP bars + timer ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _HpBar(
                          name: me?.name ?? 'You',
                          hp: me?.hp ?? 100,
                          isMe: true,
                        ),
                      ),
                      _TimerBadge(seconds: state.timeRemainingInSeconds),
                      Expanded(
                        child: _HpBar(
                          name: opponent?.name ?? 'Opponent',
                          hp: opponent?.hp ?? 100,
                          isMe: false,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Question card ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      q.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate(key: ValueKey(q.id)).fadeIn(duration: 300.ms).slideY(begin: -0.05, end: 0),
                ),

                const SizedBox(height: 16),

                // ── Opponent answered indicator ──────────────────────────
                if (opponent != null && q.userAnswers.containsKey(opponent.id))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${opponent.name} answered',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(),
                  ),

                // ── Answer choices ───────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.separated(
                      itemCount: q.answers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final answer = q.answers[i];
                        final isSelected = _selectedAnswerId == answer.id ||
                            q.userAnswers[myUserId] == answer.id;

                        return GestureDetector(
                          onTap: () => _onAnswerTap(answer.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.accent.withOpacity(0.15)
                                  : AppTheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.accent
                                    : AppTheme.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Letter badge  A / B / C / D
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.accent.withOpacity(0.2)
                                        : AppTheme.surfaceElevated,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + i),
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppTheme.accent
                                            : AppTheme.textSecondary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    answer.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppTheme.textPrimary
                                          : AppTheme.textSecondary,
                                      fontSize: 15,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle,
                                      color: AppTheme.accent, size: 18),
                              ],
                            ),
                          ).animate(key: ValueKey('${q.id}_$i')).fadeIn(
                              delay: Duration(milliseconds: 60 * i),
                              duration: 250.ms),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HP Bar ───────────────────────────────────────────────────────────────────

class _HpBar extends StatelessWidget {
  final String name;
  final int hp;
  final bool isMe;

  const _HpBar({required this.name, required this.hp, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final fraction = (hp / 100).clamp(0.0, 1.0);
    final color = hp > 50
        ? AppTheme.accent
        : hp > 25
            ? Colors.orange
            : AppTheme.danger;

    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          name,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (!isMe) ...[
              Text('$hp',
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: 6,
                  child: LinearProgressIndicator(
                    value: fraction,
                    backgroundColor: AppTheme.border,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 6),
              Text('$hp',
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ],
        ),
      ],
    );
  }
}

// ─── Timer Badge ──────────────────────────────────────────────────────────────

class _TimerBadge extends StatelessWidget {
  final int seconds;

  const _TimerBadge({required this.seconds});

  @override
  Widget build(BuildContext context) {
    final isUrgent = seconds <= 5;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isUrgent
              ? AppTheme.danger.withOpacity(0.15)
              : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUrgent ? AppTheme.danger : AppTheme.border,
          ),
        ),
        child: Text(
          '$seconds',
          style: TextStyle(
            color: isUrgent ? AppTheme.danger : AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// ─── Result View ──────────────────────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  final GameResultDto result;

  const _ResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameService>();
    final didWin = result.winnerUserId == game.userId;
    final isDraw = result.winnerUserId == null;

    final ratingDelta = result.ratingChangeAfterWinOrLoss;
    final ratingText = ratingDelta >= 0 ? '+$ratingDelta' : '$ratingDelta';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          Positioned.fill(child: _GameBg()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Result icon
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isDraw
                              ? Colors.orange
                              : didWin
                                  ? AppTheme.accent
                                  : AppTheme.danger)
                          .withOpacity(0.15),
                      border: Border.all(
                        color: isDraw
                            ? Colors.orange
                            : didWin
                                ? AppTheme.accent
                                : AppTheme.danger,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isDraw
                          ? Icons.handshake_outlined
                          : didWin
                              ? Icons.emoji_events
                              : Icons.sentiment_dissatisfied_outlined,
                      color: isDraw
                          ? Colors.orange
                          : didWin
                              ? AppTheme.accent
                              : AppTheme.danger,
                      size: 44,
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 20),

                  Text(
                    isDraw
                        ? 'Draw!'
                        : didWin
                            ? 'Victory!'
                            : 'Defeat',
                    style: TextStyle(
                      color: isDraw
                          ? Colors.orange
                          : didWin
                              ? AppTheme.accent
                              : AppTheme.danger,
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

                  // Rating change
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: ratingDelta >= 0
                          ? AppTheme.accent.withOpacity(0.1)
                          : AppTheme.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ratingDelta >= 0
                            ? AppTheme.accent.withOpacity(0.3)
                            : AppTheme.danger.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star,
                            color: ratingDelta >= 0
                                ? AppTheme.accent
                                : AppTheme.danger,
                            size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '$ratingText rating',
                          style: TextStyle(
                            color: ratingDelta >= 0
                                ? AppTheme.accent
                                : AppTheme.danger,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 350.ms),

                  const SizedBox(height: 32),

                  // Questions review
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
                    final wasCorrect =
                        myAnswer != null && myAnswer.isCorrect;

                    return _QuestionReviewCard(
                      index: i,
                      question: q,
                      myAnswer: myAnswer,
                      correctAnswer: correctAnswer,
                      wasCorrect: wasCorrect,
                    ).animate().fadeIn(delay: Duration(milliseconds: 400 + i * 60));
                  }),

                  const SizedBox(height: 32),

                  // Play again button
                  ElevatedButton.icon(
                    onPressed: () async {
                      await game.leaveGame();
                    },
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

class _QuestionReviewCard extends StatelessWidget {
  final int index;
  final QuestionDto question;
  final AnswerDto? myAnswer;
  final AnswerDto? correctAnswer;
  final bool wasCorrect;

  const _QuestionReviewCard({
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

// ─── Shared background painter ────────────────────────────────────────────────

class _GameBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GameBgPainter());
}

class _GameBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.border.withOpacity(0.35)
      ..strokeWidth = 0.5;
    const s = 48.0;
    for (double x = 0; x < size.width; x += s) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += s) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.7,
      colors: [AppTheme.accent.withOpacity(0.05), Colors.transparent],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = gradient
            .createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}