import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitstat_viewer/core/network/dio_client.dart';
import 'package:gitstat_viewer/features/commit_stats/data/models/commit_model.dart';

final commitRemoteDataSourceProvider = Provider<CommitRemoteDataSource>((ref) {
  return CommitRemoteDataSource(ref.watch(dioProvider));
});

/// Source distante : interroge l'API GitHub pour les commits d'un dépôt.
class CommitRemoteDataSource {
  final Dio _dio;

  CommitRemoteDataSource(this._dio);

  /// GET /repos/{owner}/{repo}/commits
  /// [page] et [perPage] gèrent la pagination (max 100 par page).
  Future<List<CommitModel>> fetchCommits({
    required String owner,
    required String repo,
    String? branch,
    int page = 1,
    int perPage = 30,
  }) async {
    final response = await _dio.get(
      '/repos/$owner/$repo/commits',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (branch != null && branch.isNotEmpty) 'sha': branch,
      },
    );

    final data = response.data as List<dynamic>;
    return data
        .map((item) => CommitModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
