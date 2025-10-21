import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:crunchy/widgets/bottom_bar.dart'; 
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cambiare tab aggiorna currentIndex (integrazione)', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CrunchyBottomBar()));
    await tester.pump(); // primo frame

    // Stato iniziale
    var bar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(bar.currentIndex, 0);

    // Cambia tab programmaticamente a Menu (index 1) come nel widget test
    bar.onTap?.call(1);

    // Un paio di frame per riflettere lo setState
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    bar = tester.widget(find.byType(BottomNavigationBar));
    expect(bar.currentIndex, 1);
  });
}
