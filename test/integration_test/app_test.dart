import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:crunchy/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('avvio app -> cambiare tab aggiorna currentIndex', (tester) async {
    // Avvia l’app come in produzione
    app.main();

    // Qualche frame per permettere il primo build
    await tester.pump();                                   // primo frame
    await tester.pump(const Duration(milliseconds: 100));  // tick extra

    // 1) Stato iniziale della BottomNavigationBar (Home = index 0)
    var bar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(bar.currentIndex, 0);

    // 2) Cambia tab programmaticamente a "Menu" (index 1 — adegua se diverso)
    bar.onTap?.call(1);

    // Brevi pump per riflettere lo setState
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // 3) Verifica indice aggiornato
    bar = tester.widget(find.byType(BottomNavigationBar));
    expect(bar.currentIndex, 1);
  });
}
