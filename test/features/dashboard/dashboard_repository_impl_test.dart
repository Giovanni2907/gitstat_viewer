import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gitstat_viewer/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
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

  List<RepoModel> buildRepos() => [
        const RepoModel(
          id: 1,
          name: 'repo-dart',
          fullName: '$username/repo-dart',
          ownerLogin: username,
          language: 'Dart',
          isPrivate: false,
          htmlUrl: 'https://github.com/$username/repo-dart',
        ),
        const RepoModel(
          id: 2,
          name: 'repo-python',
          fullName: '$username/repo-python',
          ownerLogin: username,
          language: 'Python',
          isPrivate: false,
          htmlUrl: 'https://github.com/$username/repo-python',
        ),
        const RepoModel(
          id: 3,
          name: 'repo-dart-2',
          fullName: '$username/repo-dart-2',
          ownerLogin: username,
          language: 'Dart',
          isPrivate: true,
          htmlUrl: 'https://github.com/$username/repo-dart-2',
        ),
        // Dépôt sans langage déclaré : ne doit pas fausser les pourcentages.
        const RepoModel(
          id: 4,
          name: 'repo-empty',
          fullName: '$username/repo-empty',
          ownerLogin: username,
          language: null,
          isPrivate: false,
          htmlUrl: 'https://github.com/$username/repo-empty',
        ),
        // Dépôt d'un autre owner (fork/collab) : compte dans repoCount
        // mais pas dans les commits/collaborateurs agrégés.
        const RepoModel(
          id: 5,
          name: 'external-repo',
          fullName: 'someoneelse/external-repo',
          ownerLogin: 'someoneelse',
          language: 'JavaScript',
          isPrivate: false,
          htmlUrl: 'https://github.com/someoneelse/external-repo',
        ),
      ];

  test('calcule correctement repoCount, commits et pourcentages de langages',
      () async {
    final repos = buildRepos();
    when(() => dataSource.getUserRepos()).thenAnswer((_) async => repos);

    // Seuls les 3 dépôts owned par "giovanni" doivent déclencher ces appels.
    when(() => dataSource.getCommitCount(
          owner: any(named: 'owner'),
          repo: any(named: 'repo'),
          author: any(named: 'author'),
        )).thenAnswer((invocation) async {
      final repoName = invocation.namedArguments[#repo] as String;
      return switch (repoName) {
        'repo-dart' => 10,
        'repo-python' => 5,
        'repo-dart-2' => 3,
        _ => 0,
      };
    });

    when(() => dataSource.getCollaborators(
          owner: any(named: 'owner'),
          repo: any(named: 'repo'),
        )).thenAnswer((invocation) async {
      final repoName = invocation.namedArguments[#repo] as String;
      return switch (repoName) {
        'repo-dart' => ['alice', 'bob'],
        'repo-python' => ['bob'], // doublon volontaire avec repo-dart
        'repo-dart-2' => <String>[],
        _ => <String>[],
      };
    });

    final stats = await repository.getDashboardStats(username);

    expect(stats.repoCount, 5);
    expect(stats.totalCommits, 18); // 10 + 5 + 3
    expect(stats.collaboratorsCount, 2); // alice + bob, sans doublon

    // 4 dépôts avec langage déclaré : Dart x2, Python x1, JavaScript x1.
    final dart = stats.languageStats.firstWhere((s) => s.language == 'Dart');
    final python = stats.languageStats.firstWhere((s) => s.language == 'Python');
    final js = stats.languageStats.firstWhere((s) => s.language == 'JavaScript');

    expect(dart.percentage, closeTo(50.0, 0.01)); // 2/4
    expect(python.percentage, closeTo(25.0, 0.01)); // 1/4
    expect(js.percentage, closeTo(25.0, 0.01)); // 1/4

    // Trié par pourcentage décroissant : Dart en tête.
    expect(stats.languageStats.first.language, 'Dart');

    // Le dépôt sans langage ne doit apparaître dans aucune stat.
    expect(stats.languageStats.any((s) => s.language.isEmpty), isFalse);
  });

  test('ignore proprement les échecs individuels de commit/collaborateurs',
      () async {
    final repos = buildRepos();
    when(() => dataSource.getUserRepos()).thenAnswer((_) async => repos);

    when(() => dataSource.getCommitCount(
          owner: any(named: 'owner'),
          repo: any(named: 'repo'),
          author: any(named: 'author'),
        )).thenThrow(Exception('rate limited'));

    when(() => dataSource.getCollaborators(
          owner: any(named: 'owner'),
          repo: any(named: 'repo'),
        )).thenThrow(Exception('403 forbidden'));

    final stats = await repository.getDashboardStats(username);

    // Aucune exception ne doit remonter : le dashboard reste affichable
    // avec des totaux à zéro plutôt qu'un crash.
    expect(stats.totalCommits, 0);
    expect(stats.collaboratorsCount, 0);
    expect(stats.repoCount, 5);
  });

  test('retourne une liste de langages vide si aucun dépôt n\'a de langage',
      () async {
    final repos = [
      const RepoModel(
        id: 1,
        name: 'repo',
        fullName: '$username/repo',
        ownerLogin: username,
        language: null,
        isPrivate: false,
        htmlUrl: 'https://github.com/$username/repo',
      ),
    ];
    when(() => dataSource.getUserRepos()).thenAnswer((_) async => repos);
    when(() => dataSource.getCommitCount(
          owner: any(named: 'owner'),
          repo: any(named: 'repo'),
          author: any(named: 'author'),
        )).thenAnswer((_) async => 0);
    when(() => dataSource.getCollaborators(
          owner: any(named: 'owner'),
          repo: any(named: 'repo'),
        )).thenAnswer((_) async => <String>[]);

    final stats = await repository.getDashboardStats(username);

    expect(stats.languageStats, isEmpty);
  });
}