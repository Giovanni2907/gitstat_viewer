import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/language_stat_entity.dart';

class LanguagePieChart extends StatelessWidget {
  final List<LanguageStatEntity> stats;

  const LanguagePieChart({super.key, required this.stats});

  static const List<Color> _palette = [
    Color(0xFF4C9A2A), Color(0xFF3178C6), Color(0xFFF7DF1E),
    Color(0xFFE34C26), Color(0xFF563D7C), Color(0xFF00ADD8),
    Color(0xFFB07219), Color(0xFF178600), Color(0xFF701516),
    Color(0xFF555555),
  ];

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const Center(
        child: Text('Pas assez de données pour afficher les langages'),
      );
    }

    // On regroupe les langages au-delà du top 6 sous "Autres"
    final top = stats.take(6).toList();
    final rest = stats.skip(6).fold<double>(0, (sum, s) => sum + s.percentage);

    return Row(
      children: [
        SizedBox(
          height: 180,
          width: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                for (int i = 0; i < top.length; i++)
                  PieChartSectionData(
                    value: top[i].percentage,
                    color: _palette[i % _palette.length],
                    title: '${top[i].percentage.toStringAsFixed(0)}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                if (rest > 0)
                  PieChartSectionData(
                    value: rest,
                    color: _palette.last,
                    title: '${rest.toStringAsFixed(0)}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < top.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _palette[i % _palette.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(top[i].language)),
                    ],
                  ),
                ),
              if (rest > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _palette.last,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Autres'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}