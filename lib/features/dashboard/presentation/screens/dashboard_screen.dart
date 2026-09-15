import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/stat_card.dart';
import '../widgets/language_pie_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          await ref.read(dashboardStatsProvider.future);
        },
        child: statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            children: [
              const SizedBox(height: 100),
              Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48),
              const SizedBox(height: 12),
              Center(child: Text('Erreur : ${error.toString()}')),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(dashboardStatsProvider),
                  child: const Text('Réessayer'),
                ),
              ),
            ],
          ),
          data: (stats) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 7,
                crossAxisSpacing: 8,
                childAspectRatio: 1.4,
                children: [
                  StatCard(
                    icon: Icons.folder_rounded,
                    label: 'Dépôts',
                    value: '${stats.repoCount}',
                  ),
                  StatCard(
                    icon: Icons.commit_rounded,
                    label: 'Commits',
                    value: '${stats.totalCommits}',
                  ),
                  StatCard(
                    icon: Icons.group_rounded,
                    label: 'Collaborateurs',
                    value: '${stats.collaboratorsCount}',
                  ),
                  StatCard(
                    icon: Icons.code_rounded,
                    label: 'Langages',
                    value: '${stats.languageStats.length}',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Répartition des langages',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              LanguagePieChart(stats: stats.languageStats),
            ],
          ),
        ),
      ),
    );
  }
}