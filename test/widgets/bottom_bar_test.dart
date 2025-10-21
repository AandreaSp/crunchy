import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crunchy/widgets/bottom_bar.dart';

void main() {
  testWidgets('cambiare tab aggiorna currentIndex', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CrunchyBottomBar()));
    await tester.pump(); // primo frame

    // Leggiamo lo stato iniziale
    var bar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    expect(bar.currentIndex, 0);

    // Cambiamo tab in modo programmatico (index=2)
    bar.onTap?.call(2);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    bar = tester.widget(find.byType(BottomNavigationBar));
    expect(bar.currentIndex, 2);
  });
}
