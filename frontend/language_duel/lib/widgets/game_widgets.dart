// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class HpBar extends StatelessWidget {
  final String name;
  final int hp;
  final int maxHp;
  final bool isMe;

  const HpBar({
    super.key,
    required this.name,
    required this.hp,
    required this.maxHp,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMax = maxHp > 0 ? maxHp : 100;
    final fraction = (hp / effectiveMax).clamp(0.0, 1.0);
    final color = fraction > 0.5
        ? AppTheme.accent
        : fraction > 0.25
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
              Text(
                '$hp',
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 6,
                  backgroundColor: AppTheme.border,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 6),
              Text(
                '$hp',
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class TimerBadge extends StatelessWidget {
  final int seconds;

  const TimerBadge({super.key, required this.seconds});

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