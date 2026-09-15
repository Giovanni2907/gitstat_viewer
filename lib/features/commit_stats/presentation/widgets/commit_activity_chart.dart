import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/commit_stats_provider.dart';

/// Graphique en barres de l'activité de commits (30 derniers jours).
/// Dessiné avec CustomPainter : aucune dépendance externe.
class CommitActivityChart extends StatelessWidget {
  final List<DailyCommits> data;

  const CommitActivityChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: colors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Activité des 30 derniers jours',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: colors.onSurface),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              width: double.infinity,
              child: CustomPaint(
                painter: _ActivityBarsPainter(
                  data: data,
                  barColor: colors.primary,
                  axisColor: colors.outline,
                  labelColor: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityBarsPainter extends CustomPainter {
  final List<DailyCommits> data;
  final Color barColor;
  final Color axisColor;
  final Color labelColor;

  _ActivityBarsPainter({
    required this.data,
    required this.barColor,
    required this.axisColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const labelSpace = 24.0;
    final chartHeight = size.height - labelSpace;
    final chartWidth = size.width;

    final maxCount =
        data.map((d) => d.count).reduce((a, b) => a > b ? a : b).clamp(1, 1 << 31);

    // Ligne de base (axe horizontal)
    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, chartHeight),
      Offset(chartWidth, chartHeight),
      axisPaint,
    );

    // Barres
    final slotWidth = chartWidth / data.length;
    final barWidth = slotWidth * 0.7;
    final barPaint = Paint()..color = barColor;

    for (var i = 0; i < data.length; i++) {
      final barHeight =
          chartHeight * 0.85 * (data[i].count / maxCount);
      if (barHeight <= 0) continue;

      final left = i * slotWidth + (slotWidth - barWidth) / 2;
      final top = chartHeight - barHeight;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      );
      canvas.drawRRect(rect, barPaint);
    }

    // Libellés de dates (début / fin) et du maximum
    _drawLabel(
      canvas,
      DateFormat('dd/MM').format(data.first.day),
      Offset(0, chartHeight + 6),
    );
    _drawLabel(
      canvas,
      DateFormat('dd/MM').format(data.last.day),
      Offset(chartWidth - 46, chartHeight + 6),
    );
    _drawLabel(
      canvas,
      'max : $maxCount',
      const Offset(0, 0),
    );
  }

  void _drawLabel(Canvas canvas, String text, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: labelColor, fontSize: 11),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ActivityBarsPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.barColor != barColor;
  }
}
