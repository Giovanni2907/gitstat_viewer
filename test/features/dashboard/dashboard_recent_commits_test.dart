import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gitstat_viewer/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:gitstat_viewer/features/dashboard/data/models/dashboard_commit_model.dart';
import 'package:gitstat_viewer/features/dashboard/data/models/repo_model.dart';
import 'package:gitstat_viewer/features/dashboard/data/repositories/dashboard_repository_impl.dart';

class MockDashboardRemoteDataSource extends Mock
    implements DashboardRemoteDataSource {}

void main() {
  late MockDashboardRemoteDataSource dataSource;
  late DashboardRepositoryImpl repository;

  const username = 'giovanni';

  setUp(() {
    dataSource = MockDashboardRemoteDataSource();
    repository = DashboardRepositoryImpl(dataSource);
  });

  test('trie les commits récents par date décroissante, tous dépôts confondus',
      () async {
    final oldRepo = RepoModel(
      id: 1,
      name: 'old-repo',
      fullName: '$username/old-repo',
      ownerLogin: username,
      language: 'Dart',
      isPrivate: false,
      htmlUrl: 'https://github.com/$username/old-repo',
      pushedAt: DateTime(2026, 1, 1),
    );
    final recentRepo = RepoModel(
      id: 2,
      name: 'recent-repo',
      fullName: '$username/recent-repo',
      ownerLogin: username,
      language: 'Python',
      isPrivate: false,
      htmlUrl: 'https://github.com/$username/recent-repo',
      pushedAt: DateTime(2026, 9, 1),
    );

    when(() => dataSource.getRepoCommits(
          owner: username,
          repo: 'recent-repo',
          author: username,
          perPage: any(named: 'perPage'),
        )).thenAnswer((_) async => [
          DashboardCommitModel(
            sha: 'aaa1111',
            message: 'fix: bug récent',
            authorName: username,
            date: DateTime(2026, 9, 10),
            repoName: 'recent-repo',
          ),
        ]);

    when(() => dataSource.getRepoCommits(
          owner: username,
          repo: 'old-repo',
          author: username,
          perPage: any(named: 'perPage'),
        )).thenAnswer((_) async => [
          DashboardCommitModel(
            sha: 'bbb2222',
            message: 'feat: ancien commit',
            authorName: username,
            date: DateTime(2026, 1, 5),
            repoName: 'old-repo',
          ),
        ]);

    final commits = await repository.getRecentCommits(
      [oldRepo, recentRepo],
      username,
    );

    expect(commits, hasLength(2));
    expect(commits.first.sha, 'aaa1111'); // le plus récent en premier
    expect(commits.last.sha, 'bbb2222');
  });

  test('ignore les dépôts dont le fetch échoue sans faire planter le total',
      () async {
    final repo = RepoModel(
      id: 1,
      name: 'broken-repo',
      fullName: '$username/broken-repo',
      ownerLogin: username,
      language: 'Dart',
      isPrivate: false,
      htmlUrl: 'https://github.com/$username/broken-repo',
      pushedAt: DateTime(2026, 9, 1),
    );

    when(() => dataSource.getRepoCommits(
          owner: any(named: 'owner'),
          repo: any(named: 'repo'),
          author: any(named: 'author'),
          perPage: any(named: 'perPage'),
        )).thenThrow(Exception('404'));

    final commits = await repository.getRecentCommits([repo], username);

    expect(commits, isEmpty);
  });

  test('exclut les dépôts qui ne sont pas owned par l\'utilisateur', () async {
    final foreignRepo = RepoModel(
      id: 1,
      name: 'not-mine',
      fullName: 'someoneelse/not-mine',
      ownerLogin: 'someoneelse',
      language: 'Go',
      isPrivate: false,
      htmlUrl: 'https://github.com/someoneelse/not-mine',
      pushedAt: DateTime(2026, 9, 1),
    );

    final commits = await repository.getRecentCommits([foreignRepo], username);

    expect(commits, isEmpty);
    verifyNever(() => dataSource.getRepoCommits(
          owner: any(named: 'owner'),
          repo: any(named: 'repo'),
          author: any(named: 'author'),
          perPage: any(named: 'perPage'),
        ));
  });
}