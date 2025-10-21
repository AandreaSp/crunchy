import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // per SystemNavigator.pop()
import '../pages/home.dart';
import '../pages/menu.dart';
import '../pages/location.dart';
import '../pages/info.dart';

// Vero in CI quando lanci i test con: --dart-define=CI=true
const bool _kCi = bool.fromEnvironment('CI', defaultValue: false);

// Pagina “leggera” per la CI: nessun plugin/sensore/rete
class _StubPage extends StatelessWidget {
  final String label;
  const _StubPage(this.label);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Stub $label'));
  }
}

class CrunchyBottomBar extends StatefulWidget {
  const CrunchyBottomBar({super.key});

  @override
  State<CrunchyBottomBar> createState() => _CrunchyShellState();
}

class _CrunchyShellState extends State<CrunchyBottomBar> {
  int _currentIndex = 0;

  void _openMenuTab() => setState(() => _currentIndex = 1);
  void _openLocationTab() => setState(() => _currentIndex = 2);

  // usato in CI per evitare crash/flaky dovuti a plugin.
  late final List<Widget> _pages = _kCi
      ? const <Widget>[
          _StubPage('Home'),
          _StubPage('Menu'),
          _StubPage('Ristorante'),
          _StubPage('Info'),
        ]
      : <Widget>[
          HomePage(onOpenMenu: _openMenuTab, onOpenLocation: _openLocationTab),
          const MenuPage(),
          const LocationPage(),
          const InfoPage(), // senza AppBar
        ];

  final List<String> _titles = const ['Crunchy', 'Menu', 'Location', 'Info'];

  Future<void> _tryCloseApp() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
          contentTextStyle: Theme.of(context).textTheme.bodyMedium,
          title: const Text("Confermi l'uscita?"),
          content: const Text("Vuoi davvero chiudere l'app?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annulla'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.logout),
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              label: const Text('Esci'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        // icona logout solo nella tab Info
        actions: _currentIndex == 3
            ? [
                IconButton(
                  tooltip: 'Chiudi app',
                  icon: const Icon(Icons.logout),
                  onPressed: _tryCloseApp,
                ),
              ]
            : null,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            tooltip: 'Vai alla Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
            tooltip: 'Guarda il menù',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.place),
            label: 'Ristorante',
            tooltip: 'Trova ristorante',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
            tooltip: 'Informazioni',
          ),
        ],
      ),
    );
  }
}
