import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitstat_viewer/features/commit_stats/presentation/widgets/stat_card.dart';

void main() {
  testWidgets('affiche l\'icône, la valeur et le libellé', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatCard(
            icon: Icons.folder_rounded,
            label: 'Dépôts',
            value: '42',
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.folder_rounded), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('Dépôts'), findsOneWidget);
  });
}