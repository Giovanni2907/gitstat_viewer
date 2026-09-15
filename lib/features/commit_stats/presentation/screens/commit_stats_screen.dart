import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/commit_provider.dart';
import '../providers/commit_stats_provider.dart';
import '../widgets/commit_activity_chart.dart';
import '../widgets/commit_list_tile.dart';
import '../widgets/stat_card.dart';

/// Tableau de bord : statistiques d'activité + historique des commits.
/// Responsive : colonne unique sur mobile, disposition multi-colonnes sur web.
class CommitStatsScreen extends ConsumerStatefulWidget {
  const CommitStatsScreen({super.key});

  @override
  ConsumerState<CommitStatsScreen> createState() => _CommitStatsScreenState();
}

class _CommitStatsScreenState extends ConsumerState<CommitStatsScreen> {
  late final TextEditingController _ownerController;
  late final TextEditingController _repoController;

  /// Seuil de largeur : en dessous, disposition mobile (1 colonne).
  static const double _wideLayoutBreakpoint = 800;

  @override
  void initState() {
    super.initState();
    _ownerController = TextEditingController(text: 'Giovanni2907');
    _repoController = TextEditingController(text: 'gitstat_viewer');
    // Premier chargement automatique dès l'ouverture de l'écran.
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _repoController.dispose();
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
    final colors = theme.colorScheme;
    final state = ref.watch(commitStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Statistiques de commits',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colors.onSurface),
            tooltip: 'Rafraîchir (Entrée dans un champ)',
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(theme, colors),
          Divider(height: 1, color: colors.outline),
          Expanded(child: _buildBody(context, state)),
        ],
      ),
    );
  }

  /// Barre de recherche owner / repo. Entrée clavier = charger
  /// (navigation au clavier et Tab conservés par les champs natifs).
  Widget _buildSearchBar(ThemeData theme, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ownerController,
              decoration: const InputDecoration(
                labelText: 'Propriétaire (owner)',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _load(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _repoController,
              decoration: const InputDecoration(
                labelText: 'Dépôt (repo)',
                prefixIcon: Icon(Icons.folder_outlined),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _load(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.search),
            label: const Text('Charger'),
          ),
        ],
      ),
    );
  }

  /// Aiguillage des états : initial / loading / erreur / vide / données.
  Widget _buildBody(BuildContext context, CommitStatsState state) {
    switch (state) {
      case CommitStatsInitial():
        return _buildHint(context);
      case CommitStatsLoading():
        return const Center(child: CircularProgressIndicator());
      case CommitStatsError(message: final message):
        return _buildError(context, message);
      case CommitStatsEmpty(owner: final owner, repo: final repo):
        return _buildEmpty(context, owner, repo);
      case CommitStatsLoaded(owner: final owner, repo: final repo, stats: final stats):
        return _buildDashboard(context, owner, repo, stats);
    }
  }

  Widget _buildHint(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.query_stats, size: 48, color: colors.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            'Choisis un dépôt puis lance le chargement.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, String owner, String repo) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Text(
        'Aucun commit trouvé dans $owner/$repo.',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: colors.onSurfaceVariant),
      ),
    );
  }

  /// Tableau de bord : cartes de stats, graphique, top auteurs, historique.
  /// LayoutBuilder : 1 colonne en mobile, 2 colonnes en web/large.
  Widget _buildDashboard(
    BuildContext context,
    String owner,
    String repo,
    CommitStats stats,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _wideLayoutBreakpoint;
        final horizontalPadding = isWide ? 24.0 : 12.0;

        final metricsRow = _buildMetricsCards(context, stats, isWide);
        final chart = CommitActivityChart(data: stats.dailyActivity);
        final authors = _buildTopAuthors(context, stats);
        final history = _buildHistory(context, stats);

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      '$owner / $repo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    metricsRow,
                    const SizedBox(height: 12),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: chart),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: authors),
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
            // Historique : liste scrollable sur l'espace restant.
            Expanded(
              flex: 2,
              child: history,
            ),
          ],
        );
      },
    );
  }

  /// Cartes de chiffres clés : grille adaptée à la largeur.
  Widget _buildMetricsCards(
    BuildContext context,
    CommitStats stats,
    bool isWide,
  ) {
    final cards = [
      StatCard(
        icon: Icons.commit,
        value: '${stats.totalCommits}',
        label: 'Commits analysés',
      ),
      StatCard(
        icon: Icons.people_alt_outlined,
        value: '${stats.topAuthors.length}',
        label: 'Top contributeurs',
      ),
      StatCard(
        icon: Icons.schedule,
        value: stats.newestCommitDate == null
            ? '-'
            : DateFormat('dd/MM HH:mm').format(stats.newestCommitDate!.toLocal()),
        label: 'Dernier commit',
      ),
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
    // Mobile : cartes empilées en 2 colonnes compactes.
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: cards,
    );
  }

  /// Top contributeurs sous forme de barres proportionnelles.
  Widget _buildTopAuthors(BuildContext context, CommitStats stats) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final maxCount = stats.topAuthors.isEmpty
        ? 1
        : stats.topAuthors.first.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.leaderboard, color: colors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Top contributeurs',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: colors.onSurface),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final author in stats.topAuthors)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        author.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: colors.onSurface),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Stack(
                        children: [
                          // Piste de fond
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          // Barre proportionnelle
                          FractionallySizedBox(
                            widthFactor: author.value / maxCount,
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${author.value}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Historique des commits, du plus récent au plus ancien.
  Widget _buildHistory(BuildContext context, CommitStats stats) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(Icons.history, color: colors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Historique des commits (${stats.commits.length})',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: colors.onSurface),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: stats.commits.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: colors.outline),
              itemBuilder: (context, index) =>
                  CommitListTile(commit: stats.commits[index]),
            ),
          ),
        ],
      ),
    );
  }
}
