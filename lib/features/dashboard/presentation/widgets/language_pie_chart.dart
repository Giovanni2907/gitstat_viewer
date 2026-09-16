import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gitstat_viewer/core/utils/language_colors.dart';
import '../../domain/entities/language_stat_entity.dart';

class LanguagePieChart extends StatelessWidget {
  final List<LanguageStatEntity> stats;

  const LanguagePieChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('Pas assez de données pour afficher les langages')),
      );
    }

    final top = stats.take(6).toList();
    final rest = stats.skip(6).fold<double>(0, (sum, s) => sum + s.percentage);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 160,
          width: 160,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 36,
              sections: [
                for (final s in top) _section(s.language, s.percentage),
                if (rest > 0) _section('Autres', rest, color: const Color(0xFF888888)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final s in top) _legendRow(s.language, languageColor(s.language)),
              if (rest > 0) _legendRow('Autres', const Color(0xFF888888)),
            ],
          ),
        ),
      ],
    );
  }

  PieChartSectionData _section(String language, double percentage, {Color? color}) {
    return PieChartSectionData(
      value: percentage,
      color: color ?? languageColor(language),
      title: '${percentage.toStringAsFixed(0)}%',
      radius: 46,
      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _legendRow(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}