import 'package:dio/dio.dart';
import '../models/github_user_model.dart';
import '../models/repo_model.dart';
import '../models/dashboard_commit_model.dart';

class DashboardRemoteDataSource {
  final Dio _dio;

  DashboardRemoteDataSource(this._dio);

  /// GET /user — infos du profil connecté
  Future<GithubUserModel> getCurrentUser() async {
    final response = await _dio.get('/user');
    return GithubUserModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /user/repos — pagine jusqu'à récupérer tous les dépôts
  Future<List<RepoModel>> getUserRepos() async {
    final List<RepoModel> allRepos = [];
    int page = 1;
    const perPage = 100;

    while (true) {
      final response = await _dio.get(
        '/user/repos',
        queryParameters: {
          'per_page': perPage,
          'page': page,
          'affiliation': 'owner,collaborator',
        },
      );

      final List data = response.data as List;
      if (data.isEmpty) break;

      allRepos.addAll(
        data.map((json) => RepoModel.fromJson(json as Map<String, dynamic>)),
      );

      if (data.length < perPage) break;
      page++;
    }

    return allRepos;
  }

  /// Compte les commits d'un utilisateur sur un dépôt donné via le header "Link".
  Future<int> getCommitCount({
    required String owner,
    required String repo,
    required String author,
  }) async {
    try {
      final response = await _dio.get(
        '/repos/$owner/$repo/commits',
        queryParameters: {'author': author, 'per_page': 1},
      );

      final linkHeader = response.headers.value('link');

      if (linkHeader == null) {
        return (response.data as List).length;
      }

      final match = RegExp(r'page=(\d+)>; rel="last"').firstMatch(linkHeader);
      if (match != null) {
        return int.parse(match.group(1)!);
      }

      return (response.data as List).length;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409 || e.response?.statusCode == 404) {
        return 0;
      }
      rethrow;
    }
  }

  /// GET /repos/{owner}/{repo}/commits — derniers commits d'un auteur sur
  /// un dépôt donné, utilisés pour le flux d'activité récente du Dashboard.
  Future<List<DashboardCommitModel>> getRepoCommits({
    required String owner,
    required String repo,
    required String author,
    int perPage = 5,
  }) async {
    try {
      final response = await _dio.get(
        '/repos/$owner/$repo/commits',
        queryParameters: {'author': author, 'per_page': perPage},
      );

      final List data = response.data as List;
      return data
          .map((json) => DashboardCommitModel.fromJson(
                json as Map<String, dynamic>,
                repoName: repo,
              ))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 409 || e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }

  /// GET /repos/{owner}/{repo}/collaborators
  Future<List<String>> getCollaborators({
    required String owner,
    required String repo,
  }) async {
    try {
      final response = await _dio.get('/repos/$owner/$repo/collaborators');
      final List data = response.data as List;
      return data.map((c) => c['login'] as String).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 || e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }
}