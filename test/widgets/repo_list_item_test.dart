import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitstat_viewer/features/dashboard/domain/entities/repo_entity.dart';
import 'package:gitstat_viewer/features/dashboard/presentation/widgets/repo_list_item.dart';

void main() {
  testWidgets('affiche le nom complet et le langage d\'un dépôt public',
      (tester) async {
    const repo = RepoEntity(
      id: 1,
      name: 'gitstat_viewer',
      fullName: 'giovanni/gitstat_viewer',
      ownerLogin: 'giovanni',
      language: 'Dart',
      isPrivate: false,
      htmlUrl: 'https://github.com/giovanni/gitstat_viewer',
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RepoListItem(repo: repo))),
    );

    expect(find.text('giovanni/gitstat_viewer'), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);
    expect(find.byIcon(Icons.book_outlined), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsNothing);
  });

  testWidgets('affiche l\'icône verrou pour un dépôt privé', (tester) async {
    const repo = RepoEntity(
      id: 2,
      name: 'secret-repo',
      fullName: 'giovanni/secret-repo',
      ownerLogin: 'giovanni',
      language: null,
      isPrivate: true,
      htmlUrl: 'https://github.com/giovanni/secret-repo',
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RepoListItem(repo: repo))),
    );

    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    // Aucun pastille de langage si language est null.
    expect(find.byType(Container), findsNothing);
  });
}