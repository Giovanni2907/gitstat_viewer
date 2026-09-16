import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitstat_viewer/core/widgets/state_views.dart';

void main() {
  group('LoadingView', () {
    testWidgets('affiche un indicateur de progression', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingView())),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('ErrorView', () {
    testWidgets('affiche le message et déclenche onRetry au tap', (tester) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Erreur réseau',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Erreur réseau'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);

      await tester.tap(find.text('Réessayer'));
      await tester.pump();

      expect(retried, isTrue);
    });
  });

  group('EmptyView', () {
    testWidgets('affiche le message et l\'icône par défaut', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EmptyView(message: 'Rien à afficher')),
        ),
      );

      expect(find.text('Rien à afficher'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('accepte une icône personnalisée', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyView(
              icon: Icons.search_off_rounded,
              message: 'Aucun résultat',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
    });
  });
}