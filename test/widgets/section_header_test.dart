import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitstat_viewer/core/widgets/section_header.dart';

void main() {
  testWidgets('affiche le titre et l\'icône, sans trailing par défaut',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SectionHeader(icon: Icons.folder_open_rounded, title: 'Dépôts'),
        ),
      ),
    );

    expect(find.text('Dépôts'), findsOneWidget);
    expect(find.byIcon(Icons.folder_open_rounded), findsOneWidget);
  });

  testWidgets('affiche le compteur trailing quand fourni', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SectionHeader(
            icon: Icons.history_rounded,
            title: 'Activité récente',
            trailing: '12/20',
          ),
        ),
      ),
    );

    expect(find.text('12/20'), findsOneWidget);
  });
}