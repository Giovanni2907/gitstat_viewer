import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitstat_viewer/core/widgets/gh_search_field.dart';

void main() {
  testWidgets('déclenche onChanged à la saisie', (tester) async {
    final controller = TextEditingController();
    String? lastValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GhSearchField(
            controller: controller,
            hintText: 'Rechercher...',
            onChanged: (value) => lastValue = value,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'flutter');
    expect(lastValue, 'flutter');
    expect(controller.text, 'flutter');
  });

  testWidgets('déclenche onSubmitted à la validation', (tester) async {
    final controller = TextEditingController();
    var submitted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GhSearchField(
            controller: controller,
            hintText: 'Rechercher...',
            onSubmitted: (_) => submitted = true,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'test');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(submitted, isTrue);
  });

  testWidgets('affiche le badge de raccourci quand shortcutHint est fourni',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GhSearchField(
            controller: TextEditingController(),
            hintText: 'Rechercher...',
            shortcutHint: '/',
          ),
        ),
      ),
    );

    expect(find.text('/'), findsOneWidget);
  });

  testWidgets('n\'affiche aucun badge sans shortcutHint', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GhSearchField(
            controller: TextEditingController(),
            hintText: 'Rechercher...',
          ),
        ),
      ),
    );

    expect(find.text('/'), findsNothing);
  });
}