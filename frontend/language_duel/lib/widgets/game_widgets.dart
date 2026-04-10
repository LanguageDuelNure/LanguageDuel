// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class HpBar extends StatelessWidget {
  final String name;
  final int hp;
  final int maxHp;
  final bool isMe;
  // NEW: optional avatar URL
  final String? imageUrl;

  const HpBar({
    super.key,
    required this.name,
    required this.hp,
    required this.maxHp,
    required this.isMe,
    this.imageUrl, // NEW
  });

  @override
  Widget build(BuildContext context) {
    final fraction = maxHp > 0 ? (hp / maxHp).clamp(0.0, 1.0) : 0.0;
    final hpColor = fraction > 0.5
        ? AppTheme.accent
        : fraction > 0.25
            ? Colors.orange
            : AppTheme.danger;

    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    Widget avatar;
    if (hasImage) {
      avatar = CircleAvatar(
        radius: 14,
        backgroundImage: NetworkImage(imageUrl!),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    } else {
      avatar = CircleAvatar(
        radius: 14,
        backgroundColor: isMe
            ? AppTheme.accent.withOpacity(0.2)
            : AppTheme.surfaceElevated,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: isMe ? AppTheme.accent : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: isMe
              ? [
                  avatar,
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ]
              : [
                  Flexible(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  avatar,
                ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: AppTheme.border,
            valueColor: AlwaysStoppedAnimation(hpColor),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$hp / $maxHp',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
class TimerBadge extends StatelessWidget {
  final int seconds;

  const TimerBadge({super.key, required this.seconds});

  Color get _color {
    if (seconds > 10) return AppTheme.accent;
    if (seconds > 5) return Colors.orange;
    return AppTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _color.withOpacity(0.1),
        border: Border.all(color: _color.withOpacity(0.4), width: 1.5),
      ),
      child: Center(
        child: Text(
          '$seconds',
          style: TextStyle(
            color: _color,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}