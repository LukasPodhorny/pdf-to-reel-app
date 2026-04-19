import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reel_models.dart';
import '../ui_providers.dart';

class _TagStyle {
  final IconData icon;
  final Color color;
  final String label;
  const _TagStyle({
    required this.icon,
    required this.color,
    required this.label,
  });
}

const Map<String, _TagStyle> _tagStyles = {
  'manim': _TagStyle(
    icon: Icons.functions,
    color: Color(0xFF7C5CFF),
    label: 'Manim',
  ),
  'question': _TagStyle(
    icon: Icons.quiz_outlined,
    color: Color(0xFFFFA726),
    label: 'Quiz',
  ),
};

_TagStyle _styleFor(String assetType) {
  return _tagStyles[assetType] ??
      _TagStyle(
        icon: Icons.auto_awesome,
        color: const Color(0xFF4FC3F7),
        label: _titleCase(assetType),
      );
}

String _titleCase(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

class TemplateTagPills extends ConsumerWidget {
  final VideoTemplate template;
  final double scale;

  const TemplateTagPills({super.key, required this.template, this.scale = 1.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (template.tags.isEmpty) return const SizedBox.shrink();

    final map = ref.watch(enabledTagsByTemplateProvider);
    final enabled =
        map[template.name] ??
        {
          for (final t in template.tags)
            if (t.defaultEnabled) t.assetType,
        };

    return Wrap(
      spacing: 8 * scale,
      runSpacing: 8 * scale,
      children: [
        for (final tag in template.tags)
          _Pill(
            style: _styleFor(tag.assetType),
            enabled: enabled.contains(tag.assetType),
            scale: scale,
            onTap: () {
              final current = {
                ...(ref.read(enabledTagsByTemplateProvider)[template.name] ??
                    {
                      for (final t in template.tags)
                        if (t.defaultEnabled) t.assetType,
                    }),
              };
              if (current.contains(tag.assetType)) {
                current.remove(tag.assetType);
              } else {
                current.add(tag.assetType);
              }
              ref.read(enabledTagsByTemplateProvider.notifier).update((state) {
                return {...state, template.name: current};
              });
            },
          ),
      ],
    );
  }
}

class _Pill extends StatefulWidget {
  final _TagStyle style;
  final bool enabled;
  final double scale;
  final VoidCallback onTap;

  const _Pill({
    required this.style,
    required this.enabled,
    required this.scale,
    required this.onTap,
  });

  @override
  State<_Pill> createState() => _PillState();
}

class _PillState extends State<_Pill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final darkBorder = Color.lerp(widget.style.color, Colors.black, 0.2)!;
    Color fillColor = widget.enabled
        ? widget.style.color
        : widget.style.color.withValues(alpha: 0.35);

    if (_isHovered) {
      fillColor = Color.lerp(fillColor, Colors.white, 0.2)!;
    }

    final fg = widget.enabled
        ? Colors.white
        : Colors.white.withValues(alpha: 0.8);

    final radius = 999.0;
    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 6 * scale,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.style.icon, size: 16 * scale, color: fg),
          SizedBox(width: 6 * scale),
          Text(
            widget.style.label,
            style: TextStyle(
              color: fg,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
          ),
        ],
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: CustomPaint(
          painter: _PillBorderPainter(
            color: darkBorder,
            fill: fillColor,
            radius: radius,
            dashed: !widget.enabled,
            strokeWidth: 1.5,
          ),
          child: content,
        ),
      ),
    );
  }

  double get scale => widget.scale;
}

class _PillBorderPainter extends CustomPainter {
  final Color color;
  final Color fill;
  final double radius;
  final bool dashed;
  final double strokeWidth;

  _PillBorderPainter({
    required this.color,
    required this.fill,
    required this.radius,
    required this.dashed,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );

    // Fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      Paint()..color = fill,
    );

    // Border
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    if (!dashed) {
      canvas.drawRRect(rrect, borderPaint);
      return;
    }

    // Dashed outline along the rounded-rect perimeter.
    final path = Path()..addRRect(rrect);
    const dashLen = 4.0;
    const gapLen = 3.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dashLen, metric.length);
        final segment = metric.extractPath(distance, next);
        canvas.drawPath(segment, borderPaint);
        distance = next + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PillBorderPainter old) {
    return old.color != color ||
        old.fill != fill ||
        old.radius != radius ||
        old.dashed != dashed ||
        old.strokeWidth != strokeWidth;
  }
}
