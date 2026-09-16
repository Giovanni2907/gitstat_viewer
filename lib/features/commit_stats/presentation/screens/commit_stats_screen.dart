import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitstat_viewer/core/widgets/search_shorcuts.dart';
import 'package:gitstat_viewer/core/widgets/state_views.dart';
import 'package:gitstat_viewer/features/commit_stats/presentation/providers/commit_provider.dart';
import '../providers/commit_stats_provider.dart';
import '../widgets/commit_activity_chart.dart';
import '../widgets/commit_metrics_row.dart';
import '../widgets/repo_search_bar.dart';
import '../widgets/top_contributors_card.dart';

class CommitStatsScreen extends ConsumerStatefulWidget {
  const CommitStatsScreen({super.key});

  @override
  ConsumerState<CommitStatsScreen> createState() => _CommitStatsScreenState();
}

class _CommitStatsScreenState extends ConsumerState<CommitStatsScreen> {
  late final TextEditingController _ownerController;
  late final TextEditingController _repoController;
  final _ownerFocusNode = FocusNode();

  static const double _wideLayoutBreakpoint = 800;

  @override
  void initState() {
    super.initState();
    _ownerController = TextEditingController(text: 'Giovanni2907');
    _repoController = TextEditingController(text: 'gitstat_viewer');
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _repoController.dispose();
    _ownerFocusNode.dispose();
    super.dispose();
  }

  void _load() {
    ref.read(commitStatsProvider.notifier).load(
          owner: _ownerController.text.trim(),
          repo: _repoController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(commitStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistiques de commits',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'Rafraîchir', onPressed: _load),
        ],
      ),
      body: SearchShortcuts(
        searchFocusNode: _ownerFocusNode,
        child: Column(
          children: [
            RepoSearchBar(
              ownerController: _ownerController,
              repoController: _repoController,
              ownerFocusNode: _ownerFocusNode,
              onSubmit: _load,
            ),
            const Divider(height: 1),
            Expanded(child: _buildBody(context, state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CommitStatsState state) {
    return switch (state) {
      CommitStatsInitial() =>
        const EmptyView(icon: Icons.query_stats, message: 'Choisis un dépôt puis lance le chargement.'),
      CommitStatsLoading() => const LoadingView(),
      CommitStatsError(message: final message) => ErrorView(message: message, onRetry: _load),
      CommitStatsEmpty(owner: final owner, repo: final repo) =>
        EmptyView(message: 'Aucun commit trouvé dans $owner/$repo.'),
      CommitStatsLoaded(owner: final owner, repo: final repo, stats: final stats) =>
        _buildDashboard(context, owner, repo, stats),
    };
  }

  Widget _buildDashboard(BuildContext context, String owner, String repo, CommitStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _wideLayoutBreakpoint;
        final padding = isWide ? 14.0 : 12.0;
        final chart = CommitActivityChart(data: stats.dailyActivity);
        final authors = TopContributorsCard(stats: stats);

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Text('$owner / $repo',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    CommitMetricsRow(stats: stats, isWide: isWide),
                    const SizedBox(height: 12),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: chart),
                          const SizedBox(width: 12),
                          Expanded(flex: 4, child: authors),
                        ],
                      )
                    else ...[
                      chart,
                      const SizedBox(height: 12),
                      authors,
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        );
        
      },
    );
  }
}