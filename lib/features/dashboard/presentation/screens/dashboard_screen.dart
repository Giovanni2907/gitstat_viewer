import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitstat_viewer/core/providers/navigation_providers.dart';
import 'package:gitstat_viewer/core/widgets/gh_search_field.dart';
import 'package:gitstat_viewer/core/widgets/section_header.dart';
import 'package:gitstat_viewer/core/widgets/state_views.dart';
import 'package:gitstat_viewer/core/widgets/stat_card.dart';
import 'package:gitstat_viewer/features/commit_stats/presentation/widgets/stat_card.dart';
import '../../domain/entities/dashboard_commit_entity.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/entities/repo_entity.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/dashboard_commit_tile.dart';
import '../widgets/language_pie_chart.dart';
import '../widgets/repo_list_item.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _repoSearchController = TextEditingController();
  final _repoSearchFocusNode = FocusNode();
  String _repoQuery = '';

  final _commitSearchController = TextEditingController();
  String _commitQuery = '';

  static const double _wideLayoutBreakpoint = 800;

  @override
  void dispose() {
    _repoSearchController.dispose();
    _repoSearchFocusNode.dispose();
    _commitSearchController.dispose();
    super.dispose();
  }

  List<RepoEntity> _filterRepos(List<RepoEntity> repos) {
    if (_repoQuery.isEmpty) return repos;
    final q = _repoQuery.toLowerCase();
    return repos
        .where((r) =>
            r.name.toLowerCase().contains(q) ||
            (r.language?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  List<DashboardCommitEntity> _filterCommits(List<DashboardCommitEntity> commits) {
    if (_commitQuery.isEmpty) return commits;
    final q = _commitQuery.toLowerCase();
    return commits
        .where((c) =>
            c.message.toLowerCase().contains(q) ||
            c.authorName.toLowerCase().contains(q) ||
            c.repoName.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SearchShortcuts(
        searchFocusNode: _repoSearchFocusNode,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardStatsProvider);
            ref.invalidate(dashboardRecentCommitsProvider);
            await ref.read(dashboardStatsProvider.future);
          },
          child: statsAsync.when(
            loading: () => const LoadingView(),
            error: (error, _) => ErrorView(
              message: 'Erreur : $error',
              onRetry: () => ref.invalidate(dashboardStatsProvider),
            ),
            data: (stats) => _buildContent(context, stats),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardStatsEntity stats) {
    final filteredRepos = _filterRepos(stats.repos);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _wideLayoutBreakpoint;
        final languageCard = _buildLanguageCard(context, stats);
        final commitsCard = _buildCommitsCard(context);
        final repoSection = _buildRepoSearchCard(context, filteredRepos, stats.repos.length);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildMetricsGrid(context, stats, isWide),
            const SizedBox(height: 20),
            _buildDetailCta(context),
            const SizedBox(height: 20),
            if (isWide)
  Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            languageCard,
            const SizedBox(height: 16),
            commitsCard,
          ],
        ),
      ),
      const SizedBox(width: 12),
      Expanded(flex: 3, child: repoSection),
    ],
  )
            else ...[
              languageCard,
              const SizedBox(height: 16),
              commitsCard,
              const SizedBox(height: 16),
              repoSection,
            ],
          ],
        );
      },
    );
  }

  Widget _buildMetricsGrid(BuildContext context, DashboardStatsEntity stats, bool isWide) {
    final cards = [
      StatCard(icon: Icons.folder_rounded, label: 'Dépôts', value: '${stats.repoCount}'),
      StatCard(icon: Icons.commit_rounded, label: 'Commits', value: '${stats.totalCommits}'),
      StatCard(icon: Icons.group_rounded, label: 'Collaborateurs', value: '${stats.collaboratorsCount}'),
      StatCard(icon: Icons.code_rounded, label: 'Langages', value: '${stats.languageStats.length}'),
    ];

    if (isWide) {
      return Row(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            Expanded(child: cards[i]),
            if (i < cards.length - 1) const SizedBox(width: 12),
          ],
        ],
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: cards,
    );
  }

  Widget _buildDetailCta(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.insights_rounded, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Analyse l'activité de commits d'un dépôt précis : contributeurs, historique, tendance.",
              style: TextStyle(color: colors.onSurface, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.tonalIcon(
            onPressed: () => ref.read(currentTabIndexProvider.notifier).state = 1,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Statistiques'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, DashboardStatsEntity stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(icon: Icons.pie_chart_rounded, title: 'Langages'),
            const SizedBox(height: 16),
            LanguagePieChart(stats: stats.languageStats),
          ],
        ),
      ),
    );
  }

  /// Carte "Activité récente" : même habillage que la carte Dépôts
  /// (titre, barre de recherche, liste), placée juste sous le camembert.
  Widget _buildCommitsCard(BuildContext context) {
    final commitsAsync = ref.watch(dashboardRecentCommitsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            commitsAsync.when(
              loading: () => const SectionHeader(icon: Icons.history_rounded, title: 'Activité récente'),
              error: (_, __) => const SectionHeader(icon: Icons.history_rounded, title: 'Activité récente'),
              data: (commits) {
                final filtered = _filterCommits(commits);
                return SectionHeader(
                  icon: Icons.history_rounded,
                  title: 'Activité récente',
                  trailing: '${filtered.length}/${commits.length}',
                );
              },
            ),
            const SizedBox(height: 12),
            GhSearchField(
              controller: _commitSearchController,
              hintText: 'Filtrer par message, auteur ou dépôt...',
              onChanged: (value) => setState(() => _commitQuery = value),
            ),
            const SizedBox(height: 8),
            commitsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: LoadingView(),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ErrorView(
                  message: 'Impossible de charger l\'activité récente.',
                  onRetry: () => ref.invalidate(dashboardRecentCommitsProvider),
                ),
              ),
              data: (commits) {
                final filtered = _filterCommits(commits);
                if (filtered.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: EmptyView(
                      icon: Icons.commit_rounded,
                      message: 'Aucun commit récent ne correspond à cette recherche.',
                    ),
                  );
                }
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) => DashboardCommitTile(commit: filtered[index]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepoSearchCard(BuildContext context, List<RepoEntity> filtered, int total) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              icon: Icons.folder_open_rounded,
              title: 'Dépôts',
              trailing: '${filtered.length}/$total',
            ),
            const SizedBox(height: 12),
            GhSearchField(
              controller: _repoSearchController,
              focusNode: _repoSearchFocusNode,
              hintText: 'Filtrer par nom ou langage...',
              shortcutHint: '/',
              onChanged: (value) => setState(() => _repoQuery = value),
            ),
            const SizedBox(height: 8),
            if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: EmptyView(
                  icon: Icons.search_off_rounded,
                  message: 'Aucun dépôt ne correspond à cette recherche.',
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) => RepoListItem(repo: filtered[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}