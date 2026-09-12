import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitstat_viewer/features/commit_stats/data/datasources/commit_remote_data_source.dart';
import 'package:gitstat_viewer/features/commit_stats/data/models/commit_model.dart';

import 'commit_stats_provider.dart';

// --- États possibles de l'écran des statistiques de commits ---
sealed class CommitStatsState {
  const CommitStatsState();
}

class CommitStatsInitial extends CommitStatsState {
  const CommitStatsInitial();
}

class CommitStatsLoading extends CommitStatsState {
  const CommitStatsLoading();
}

class CommitStatsLoaded extends CommitStatsState {
  final String owner;
  final String repo;
  final CommitStats stats;

  const CommitStatsLoaded({
    required this.owner,
    required this.repo,
    required this.stats,
  });
}

class CommitStatsEmpty extends CommitStatsState {
  final String owner;
  final String repo;

  const CommitStatsEmpty({required this.owner, required this.repo});
}

class CommitStatsError extends CommitStatsState {
  final String message;

  const CommitStatsError({required this.message});
}

// --- Provider principal (à écouter dans l'écran) ---
final commitStatsProvider =
    StateNotifierProvider<CommitStatsNotifier, CommitStatsState>((ref) {
  return CommitStatsNotifier(ref.watch(commitRemoteDataSourceProvider));
});

class CommitStatsNotifier extends StateNotifier<CommitStatsState> {
  final CommitRemoteDataSource _dataSource;

  CommitStatsNotifier(this._dataSource) : super(const CommitStatsInitial());

  /// Pagination : on récupère au maximum 3 pages de 100 commits (300).
  /// Suffisant pour des statistiques représentatives sans abuser de l'API.
  static const int _maxPages = 3;
  static const int _perPage = 100;

  /// Charge les commits d'un dépôt puis calcule les statistiques.
  Future<void> load({required String owner, required String repo}) async {
    if (owner.trim().isEmpty || repo.trim().isEmpty) {
      state = const CommitStatsError(
        message: 'Renseigne le propriétaire (owner) et le nom du dépôt.',
      );
      return;
    }

    state = const CommitStatsLoading();

    try {
      final commits = <CommitModel>[];
      for (var page = 1; page <= _maxPages; page++) {
        final batch = await _dataSource.fetchCommits(
          owner: owner,
          repo: repo,
          page: page,
          perPage: _perPage,
        );
        commits.addAll(batch);
        // Page partiellement remplie = dernière page, on s'arrête.
        if (batch.length < _perPage) break;
      }

      if (commits.isEmpty) {
        state = CommitStatsEmpty(owner: owner, repo: repo);
      } else {
        state = CommitStatsLoaded(
          owner: owner,
          repo: repo,
          stats: CommitStats.fromCommits(commits),
        );
      }
    } on DioException catch (e) {
      state = CommitStatsError(message: _errorMessage(e));
    } catch (e) {
      state = const CommitStatsError(
        message: 'Erreur inattendue. Réessaie.',
      );
    }
  }

  /// Transforme les erreurs Dio en messages compréhensibles.
  String _errorMessage(DioException e) {
    final status = e.response?.statusCode;
    switch (status) {
      case 404:
        return 'Dépôt introuvable : vérifie le propriétaire et le nom du dépôt.';
      case 403:
      case 429:
        return 'Limite de l\'API GitHub atteinte (60 requêtes/h sans connexion). '
            'Connecte-toi ou réessaie plus tard.';
      default:
        return 'Erreur réseau : vérifie ta connexion internet.';
    }
  }
}
