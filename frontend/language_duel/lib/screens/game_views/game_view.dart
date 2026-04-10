import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:language_duel/l10n/app_localizations.dart';
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
  int _displaySeconds = 0;
  Timer? _countdownTimer;
  final Map<String, int> _maxHp = {};

  @override
  void initState() {
    super.initState();
    _displaySeconds = widget.state.timeRemainingInSeconds ?? 0;
    _updateMaxHp(widget.state);
    if (widget.state.currentQuestion != null &&
        widget.state.correctAnswerId == null) {
      _startCountdown();
    }
  }

  @override
  void didUpdateWidget(GameView old) {
    super.didUpdateWidget(old);
    final state = widget.state;
    final oldState = old.state;

    final q = state.currentQuestion;
    final oldQ = oldState.currentQuestion;

    final questionChanged = q != null && (oldQ == null || oldQ.id != q.id);
    if (questionChanged) {
      _selectedAnswerId = null;
      _displaySeconds = state.timeRemainingInSeconds ?? 0;
      _restartCountdown();
    } else if (state.correctAnswerId != null &&
        oldState.correctAnswerId == null) {
      _countdownTimer?.cancel();
    } else if (q != null &&
        state.timeRemainingInSeconds != null &&
        state.timeRemainingInSeconds != oldState.timeRemainingInSeconds) {
      _displaySeconds = state.timeRemainingInSeconds!;
      _restartCountdown();
    }

    _updateMaxHp(state);
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

  Future<void> _confirmGiveUp(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.giveUpTitle,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          l10n.giveUpContent,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.cancelBtn,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: Text(l10n.giveUpBtn),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<GameService>().giveUp();
    }
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

  Widget _buildMatchFoundScreen(
    BuildContext context,
    GameSessionUserDto? me,
    GameSessionUserDto? opponent,
  ) {
    final l10n = AppLocalizations.of(context)!;
    
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.matchFoundTitle,
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ).animate().fadeIn(),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _PlayerChip(
                          name: me?.name ?? l10n.youPlayer,
                          rating: me?.rating ?? 0,
                          isMe: true,
                        ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            l10n.vsText,
                            style: TextStyle(
                              color: AppTheme.textSecondary.withOpacity(0.6),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                        _PlayerChip(
                          name: opponent?.name ?? l10n.unknownOpponent,
                          rating: opponent?.rating ?? 0,
                          isMe: false,
                        ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.2),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.accent,
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 14),
                    Text(
                      l10n.preparingFirstQuestion,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ).animate().fadeIn(delay: 350.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameService>();
    final state = game.gameState ?? widget.state;
    final myUserId = game.userId;
    final l10n = AppLocalizations.of(context)!;

    final me = state.users.where((u) => u.id == myUserId).firstOrNull;
    final opponent = state.users.where((u) => u.id != myUserId).firstOrNull;

    if (state.currentQuestion == null) {
      return _buildMatchFoundScreen(context, me, opponent);
    }

    final q = state.currentQuestion!;
    final correctAnswerId = state.correctAnswerId;
    final isRevealPhase = correctAnswerId != null;

    final myMaxHp = _maxHp[myUserId] ?? me?.hp ?? 100;
    final opponentMaxHp = opponent != null
        ? (_maxHp[opponent.id] ?? opponent.hp)
        : 100;

    final opponentAnswerId = opponent != null
        ? q.userAnswers[opponent.id]
        : null;
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                        const Icon(
                          Icons.star,
                          color: AppTheme.accent,
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${opponent.rating}',
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _confirmGiveUp(context),
                          icon: const Icon(
                            Icons.flag_outlined,
                            color: AppTheme.danger,
                            size: 20,
                          ),
                          tooltip: l10n.giveUpTitle,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: HpBar(
                          name: me?.name ?? l10n.youPlayer,
                          hp: me?.hp ?? 100,
                          maxHp: myMaxHp,
                          isMe: true,
                        ),
                      ),
                      TimerBadge(seconds: isRevealPhase ? 0 : _displaySeconds),
                      Expanded(
                        child: HpBar(
                          name: opponent?.name ?? l10n.unknownOpponent,
                          hp: opponent?.hp ?? 100,
                          maxHp: opponentMaxHp,
                          isMe: false,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:
                      Container(
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

                if (!isRevealPhase && opponentAnswerId != null)
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
                          l10n.opponentAnswered(opponent?.name ?? l10n.unknownOpponent),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(),
                  ),

                if (isRevealPhase)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: AppTheme.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.nextQuestionIncoming,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(),
                  ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.separated(
                      itemCount: q.answers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final answer = q.answers[i];
                        final isMyAnswer = effectiveMyAnswer == answer.id;
                        final isOpponentAnswer = opponentAnswerId == answer.id;
                        final isCorrect =
                            isRevealPhase && answer.id == correctAnswerId;
                        final isWrong =
                            isRevealPhase &&
                            answer.id != correctAnswerId &&
                            (isMyAnswer || isOpponentAnswer);

                        Color borderColor;
                        Color bgColor;
                        Color textColor;
                        Color letterBgColor;
                        Color letterTextColor;
                        Widget? trailingIcon;

                        if (isCorrect) {
                          bgColor = AppTheme.accent.withOpacity(0.1);
                          borderColor = AppTheme.accent.withOpacity(0.7);
                          textColor = AppTheme.accent;
                          letterBgColor = AppTheme.accent.withOpacity(0.2);
                          letterTextColor = AppTheme.accent;
                          trailingIcon = const Icon(
                            Icons.check_circle_outline,
                            color: AppTheme.accent,
                            size: 20,
                          );
                        } else if (isWrong) {
                          bgColor = AppTheme.danger.withOpacity(0.08);
                          borderColor = AppTheme.danger.withOpacity(0.5);
                          textColor = AppTheme.danger;
                          letterBgColor = AppTheme.danger.withOpacity(0.15);
                          letterTextColor = AppTheme.danger;
                          trailingIcon = Icon(
                            isMyAnswer && isOpponentAnswer
                                ? Icons.people
                                : isMyAnswer
                                ? Icons.cancel_outlined
                                : Icons.person,
                            color: AppTheme.danger,
                            size: 18,
                          );
                        } else if (isRevealPhase) {
                          bgColor = AppTheme.surface;
                          borderColor = AppTheme.border;
                          textColor = AppTheme.textSecondary.withOpacity(0.4);
                          letterBgColor = AppTheme.surfaceElevated;
                          letterTextColor = AppTheme.textSecondary.withOpacity(
                            0.3,
                          );
                          trailingIcon = null;
                        } else if (isMyAnswer && isOpponentAnswer) {
                          bgColor = AppTheme.danger.withOpacity(0.08);
                          borderColor = AppTheme.danger.withOpacity(0.5);
                          textColor = AppTheme.danger;
                          letterBgColor = AppTheme.danger.withOpacity(0.15);
                          letterTextColor = AppTheme.danger;
                          trailingIcon = const Icon(
                            Icons.people,
                            color: AppTheme.danger,
                            size: 16,
                          );
                        } else if (isMyAnswer) {
                          bgColor = AppTheme.danger.withOpacity(0.08);
                          borderColor = AppTheme.danger.withOpacity(0.5);
                          textColor = AppTheme.danger;
                          letterBgColor = AppTheme.danger.withOpacity(0.15);
                          letterTextColor = AppTheme.danger;
                          trailingIcon = const Icon(
                            Icons.cancel_outlined,
                            color: AppTheme.danger,
                            size: 18,
                          );
                        } else if (isOpponentAnswer) {
                          bgColor = AppTheme.danger.withOpacity(0.08);
                          borderColor = AppTheme.danger.withOpacity(0.5);
                          textColor = AppTheme.danger;
                          letterBgColor = AppTheme.danger.withOpacity(0.15);
                          letterTextColor = AppTheme.danger;
                          trailingIcon = const Icon(
                            Icons.person,
                            color: AppTheme.danger,
                            size: 16,
                          );
                        } else {
                          bgColor = AppTheme.surface;
                          borderColor = AppTheme.border;
                          textColor = iAnswered
                              ? AppTheme.textSecondary.withOpacity(0.5)
                              : AppTheme.textSecondary;
                          letterBgColor = AppTheme.surfaceElevated;
                          letterTextColor = iAnswered
                              ? AppTheme.textSecondary.withOpacity(0.4)
                              : AppTheme.textSecondary;
                          trailingIcon = null;
                        }

                        final isBlocked = iAnswered || isRevealPhase;

                        return GestureDetector(
                          onTap: (isBlocked || isOpponentAnswer)
                              ? null
                              : () => _onAnswerTap(answer.id),
                          child:
                              AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: borderColor,
                                        width:
                                            (isMyAnswer ||
                                                isOpponentAnswer ||
                                                isCorrect)
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                                                  fontWeight:
                                                      (isMyAnswer ||
                                                          isOpponentAnswer ||
                                                          isCorrect)
                                                      ? FontWeight.w600
                                                      : FontWeight.w400,
                                                ),
                                              ),
                                              if (!isRevealPhase) ...[
                                                if (isOpponentAnswer &&
                                                    !isMyAnswer)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 2,
                                                        ),
                                                    child: Text(
                                                      l10n.opponentsAnswer(opponent?.name ?? l10n.unknownOpponent),
                                                      style: TextStyle(
                                                        color: AppTheme.danger
                                                            .withOpacity(0.7),
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ),
                                                if (isMyAnswer &&
                                                    isOpponentAnswer)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 2,
                                                        ),
                                                    child: Text(
                                                      l10n.bothPickedThis,
                                                      style: TextStyle(
                                                        color: AppTheme.danger
                                                            .withOpacity(0.7),
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        if (trailingIcon != null) trailingIcon,
                                      ],
                                    ),
                                  )
                                  .animate(key: ValueKey('${q.id}_$i'))
                                  .fadeIn(
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

class _PlayerChip extends StatelessWidget {
  final String name;
  final int rating;
  final bool isMe;

  const _PlayerChip({
    required this.name,
    required this.rating,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isMe
                  ? [
                      AppTheme.accent.withOpacity(0.3),
                      AppTheme.accentDim.withOpacity(0.2),
                    ]
                  : [AppTheme.surfaceElevated, AppTheme.surface],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: isMe ? AppTheme.accent.withOpacity(0.5) : AppTheme.border,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: isMe ? AppTheme.accent : AppTheme.textSecondary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            color: isMe ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: AppTheme.accent.withOpacity(0.7), size: 11),
            const SizedBox(width: 3),
            Text(
              '$rating',
              style: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}