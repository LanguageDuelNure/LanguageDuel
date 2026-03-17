// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../models/game_models.dart';
import '../../services/game_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/grid_background.dart';
import '../../widgets/game_widgets.dart';

class GameView extends StatefulWidget {
  final GameStateDto state;

  const GameView({super.key, required this.state});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  String? _selectedAnswerId;
  late int _displaySeconds;
  Timer? _countdownTimer;
  final Map<String, int> _maxHp = {};

  @override
  void initState() {
    super.initState();
    _displaySeconds = widget.state.timeRemainingInSeconds;
    _updateMaxHp(widget.state);
    _startCountdown();
  }

  @override
  void didUpdateWidget(GameView old) {
    super.didUpdateWidget(old);
    final q = widget.state.currentQuestion;
    final oldQ = old.state.currentQuestion;
    final questionChanged = oldQ.id != q.id;

    if (questionChanged) {
      _selectedAnswerId = null;
      _displaySeconds = widget.state.timeRemainingInSeconds;
      _restartCountdown();
    } else if (widget.state.timeRemainingInSeconds !=
        old.state.timeRemainingInSeconds) {
      _displaySeconds = widget.state.timeRemainingInSeconds;
      _restartCountdown();
    }

    _updateMaxHp(widget.state);
  }

  void _updateMaxHp(GameStateDto state) {
    for (final user in state.users) {
      final prev = _maxHp[user.id] ?? 0;
      if (user.hp > prev) _maxHp[user.id] = user.hp;
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_displaySeconds > 0) _displaySeconds--;
      });
    });
  }

  void _restartCountdown() {
    _countdownTimer?.cancel();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _onAnswerTap(String answerId) {
    if (_selectedAnswerId != null) return;
    setState(() => _selectedAnswerId = answerId);
    context.read<GameService>().submitAnswer(answerId);
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameService>();
    final state = game.gameState ?? widget.state;
    final q = state.currentQuestion;
    final myUserId = game.userId;

    final me = state.users.where((u) => u.id == myUserId).firstOrNull;
    final opponent = state.users.where((u) => u.id != myUserId).firstOrNull;

    final myMaxHp = _maxHp[myUserId] ?? me?.hp ?? 100;
    final opponentMaxHp =
        opponent != null ? (_maxHp[opponent.id] ?? opponent.hp) : 100;

    final opponentAnswerId =
        opponent != null ? q.userAnswers[opponent.id] : null;
    final myServerAnswerId = q.userAnswers[myUserId];
    final effectiveMyAnswer = _selectedAnswerId ?? myServerAnswerId;
    final iAnswered = effectiveMyAnswer != null;

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
            child: Column(
              children: [
                // ── Header: ★ myRating · Language · opponentName ★ oppRating
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // My rating
                      const Icon(Icons.star, color: AppTheme.accent, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        '${game.currentRating}',
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),

                      // Language name separator
                      if (game.selectedLanguageName.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: AppTheme.border,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          game.selectedLanguageName,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],

                      // Opponent rating
                      if (opponent != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: AppTheme.border,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star,
                            color: AppTheme.accent, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          '${opponent.rating}',
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── HP bars + timer ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: HpBar(
                          name: me?.name ?? 'You',
                          hp: me?.hp ?? 100,
                          maxHp: myMaxHp,
                          isMe: true,
                        ),
                      ),
                      TimerBadge(seconds: _displaySeconds),
                      Expanded(
                        child: HpBar(
                          name: opponent?.name ?? 'Opponent',
                          hp: opponent?.hp ?? 100,
                          maxHp: opponentMaxHp,
                          isMe: false,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Question card ─────────────────────────────────────────
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
                  )
                      .animate(key: ValueKey(q.id))
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: -0.05, end: 0),
                ),

                const SizedBox(height: 12),

                // ── Opponent answered indicator ───────────────────────────
                if (opponentAnswerId != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
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
                          '${opponent?.name ?? 'Opponent'} answered',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(),
                  ),

                // ── Answer choices ────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.separated(
                      itemCount: q.answers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final answer = q.answers[i];
                        final isMyAnswer = effectiveMyAnswer == answer.id;
                        final isOpponentAnswer = opponentAnswerId == answer.id;
                        final isBlocked = iAnswered;

                        // We don't know correctness during the round, so we
                        // style our own pick the same as the opponent's pick:
                        // red — "you committed, awaiting result". This avoids
                        // ever showing a false green checkmark.
                        Color borderColor;
                        Color bgColor;
                        Color textColor;
                        Color letterBgColor;
                        Color letterTextColor;
                        Widget? trailingIcon;

                        if (isMyAnswer && isOpponentAnswer) {
                          // Both picked the same answer
                          bgColor = AppTheme.danger.withOpacity(0.08);
                          borderColor = AppTheme.danger.withOpacity(0.5);
                          textColor = AppTheme.danger;
                          letterBgColor = AppTheme.danger.withOpacity(0.15);
                          letterTextColor = AppTheme.danger;
                          trailingIcon = const Icon(Icons.people,
                              color: AppTheme.danger, size: 16);
                        } else if (isMyAnswer) {
                          // My pick — same red style as opponent's so we
                          // never show a misleading green checkmark
                          bgColor = AppTheme.danger.withOpacity(0.08);
                          borderColor = AppTheme.danger.withOpacity(0.5);
                          textColor = AppTheme.danger;
                          letterBgColor = AppTheme.danger.withOpacity(0.15);
                          letterTextColor = AppTheme.danger;
                          trailingIcon = const Icon(Icons.cancel_outlined,
                              color: AppTheme.danger, size: 18);
                        } else if (isOpponentAnswer) {
                          // Opponent's pick
                          bgColor = AppTheme.danger.withOpacity(0.08);
                          borderColor = AppTheme.danger.withOpacity(0.5);
                          textColor = AppTheme.danger;
                          letterBgColor = AppTheme.danger.withOpacity(0.15);
                          letterTextColor = AppTheme.danger;
                          trailingIcon = const Icon(Icons.person,
                              color: AppTheme.danger, size: 16);
                        } else {
                          bgColor = AppTheme.surface;
                          borderColor = AppTheme.border;
                          textColor = isBlocked
                              ? AppTheme.textSecondary.withOpacity(0.5)
                              : AppTheme.textSecondary;
                          letterBgColor = AppTheme.surfaceElevated;
                          letterTextColor = isBlocked
                              ? AppTheme.textSecondary.withOpacity(0.4)
                              : AppTheme.textSecondary;
                          trailingIcon = null;
                        }

                        return GestureDetector(
                          onTap: (isBlocked || isOpponentAnswer)
                              ? null
                              : () => _onAnswerTap(answer.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: borderColor,
                                width: (isMyAnswer || isOpponentAnswer)
                                    ? 1.5
                                    : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: letterBgColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + i),
                                      style: TextStyle(
                                        color: letterTextColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        answer.name,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 15,
                                          fontWeight: (isMyAnswer ||
                                                  isOpponentAnswer)
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                      if (isOpponentAnswer && !isMyAnswer)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2),
                                          child: Text(
                                            '${opponent?.name ?? 'Opponent'}\'s answer',
                                            style: TextStyle(
                                              color: AppTheme.danger
                                                  .withOpacity(0.7),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      if (isMyAnswer && isOpponentAnswer)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2),
                                          child: Text(
                                            'Both picked this',
                                            style: TextStyle(
                                              color: AppTheme.danger
                                                  .withOpacity(0.7),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                ?trailingIcon,
                              ],
                            ),
                          ).animate(key: ValueKey('${q.id}_$i')).fadeIn(
                                delay: Duration(milliseconds: 60 * i),
                                duration: 250.ms,
                              ),
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