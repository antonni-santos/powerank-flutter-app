import 'package:flutter/material.dart';

class RankDivisionStyle {
  final String name;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const RankDivisionStyle({
    required this.name,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}

class _PositionBadgeStyle {
  final Color background;
  final Color foreground;
  final Color border;

  const _PositionBadgeStyle({
    required this.background,
    required this.foreground,
    required this.border,
  });
}

const List<RankDivisionStyle> _divisionStyles = [
  RankDivisionStyle(
    name: 'Champion',
    icon: Icons.workspace_premium_rounded,
    color: Color(0xFFFFD54F),
    backgroundColor: Color(0xFF3B2B00),
  ),
  RankDivisionStyle(
    name: 'Diamond',
    icon: Icons.diamond_rounded,
    color: Color(0xFF65D6FF),
    backgroundColor: Color(0xFF072C3A),
  ),
  RankDivisionStyle(
    name: 'Platinum',
    icon: Icons.military_tech_rounded,
    color: Color(0xFF76E4D7),
    backgroundColor: Color(0xFF0F3030),
  ),
  RankDivisionStyle(
    name: 'Gold',
    icon: Icons.emoji_events_rounded,
    color: Color(0xFFFFC247),
    backgroundColor: Color(0xFF382300),
  ),
  RankDivisionStyle(
    name: 'Silver',
    icon: Icons.verified_rounded,
    color: Color(0xFFD4DCE2),
    backgroundColor: Color(0xFF25313A),
  ),
  RankDivisionStyle(
    name: 'Bronze',
    icon: Icons.shield_rounded,
    color: Color(0xFFD58B57),
    backgroundColor: Color(0xFF382012),
  ),
  RankDivisionStyle(
    name: 'Iron',
    icon: Icons.hexagon_rounded,
    color: Color(0xFF90A4AE),
    backgroundColor: Color(0xFF1F2A31),
  ),
];

RankDivisionStyle rankDivisionForPoints(int points) {
  if (points >= 150000) return _divisionStyles[0];
  if (points >= 70000) return _divisionStyles[1];
  if (points >= 35000) return _divisionStyles[2];
  if (points >= 15000) return _divisionStyles[3];
  if (points >= 5000) return _divisionStyles[4];
  if (points >= 1000) return _divisionStyles[5];
  return _divisionStyles[6];
}

RankDivisionStyle rankDivisionForName(String name) {
  return _divisionStyles.firstWhere(
    (style) => style.name == name,
    orElse: () => _divisionStyles.last,
  );
}

Widget buildRankDivisionPill({
  required RankDivisionStyle style,
  bool compact = false,
}) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 8 : 10,
      vertical: compact ? 4 : 6,
    ),
    decoration: BoxDecoration(
      color: style.backgroundColor,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: style.color.withValues(alpha: 0.35)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(style.icon, size: compact ? 14 : 16, color: style.color),
        SizedBox(width: compact ? 4 : 6),
        Text(
          style.name,
          style: TextStyle(
            color: style.color,
            fontSize: compact ? 11 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

Widget buildRankAvatar({
  required String username,
  required RankDivisionStyle style,
}) {
  return Stack(
    clipBehavior: Clip.none,
    children: [
      CircleAvatar(
        radius: 22,
        backgroundColor: style.color.withValues(alpha: 0.16),
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: TextStyle(
            color: style.color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      Positioned(
        right: -3,
        bottom: -3,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: style.backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: style.color.withValues(alpha: 0.55)),
            boxShadow: [
              BoxShadow(
                color: style.color.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(style.icon, size: 12, color: style.color),
        ),
      ),
    ],
  );
}

Widget buildPositionBadge(int position) {
  final style = _positionBadgeStyle(position);
  final isTopThree = position <= 3;

  return Container(
    width: isTopThree ? 42 : 48,
    height: 42,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: style.background,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: style.border),
      boxShadow: isTopThree
          ? [
              BoxShadow(
                color: style.foreground.withValues(alpha: 0.16),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ]
          : null,
    ),
    child: Text(
      isTopThree ? '$position' : '#$position',
      style: TextStyle(
        color: style.foreground,
        fontWeight: FontWeight.bold,
        fontSize: isTopThree ? 18 : 13,
      ),
    ),
  );
}

_PositionBadgeStyle _positionBadgeStyle(int position) {
  switch (position) {
    case 1:
      return const _PositionBadgeStyle(
        background: Color(0xFF3B2B00),
        foreground: Color(0xFFFFD54F),
        border: Color(0x80FFD54F),
      );
    case 2:
      return const _PositionBadgeStyle(
        background: Color(0xFF263238),
        foreground: Color(0xFFD7E0E7),
        border: Color(0x80D7E0E7),
      );
    case 3:
      return const _PositionBadgeStyle(
        background: Color(0xFF352012),
        foreground: Color(0xFFD58B57),
        border: Color(0x80D58B57),
      );
    default:
      return const _PositionBadgeStyle(
        background: Color(0xFF151A21),
        foreground: Color(0xFF8A97A4),
        border: Color(0xFF202833),
      );
  }
}
