/* ---- Bottom bar con 4 tab: gestione indice corrente, titolo dinamico e dialog di uscita su richiesta ---- */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../pages/home.dart';
import '../pages/menu.dart';
import '../pages/location.dart';
import '../pages/info.dart';

class CrunchyBottomBar extends StatefulWidget {
  const CrunchyBottomBar({super.key});

  @override
  State<CrunchyBottomBar> createState() => _CrunchyShellState();
}

class _CrunchyShellState extends State<CrunchyBottomBar> {
  /* ---- Indice della tab corrente ---- */
  int _currentIndex = 0;

  /* ---- Callback per aprire rapidamente le tab interne dalla Home ---- */
  void _openMenuTab() => setState(() => _currentIndex = 1);
  void _openLocationTab() => setState(() => _currentIndex = 2);

  /* ---- Pagine associate alle voci della bottom bar ---- */
  late final List<Widget> _pages = <Widget>[
    HomePage(onOpenMenu: _openMenuTab, onOpenLocation: _openLocationTab),
    const MenuPage(),
    const LocationPage(),
    const InfoPage(),
  ];

  /* ---- Titoli mostrati nell'AppBar per ciascuna tab ---- */
  final List<String> _titles = const ['Crunchy', 'Menu', 'Location', 'Info'];

  /* ---- Dialog di conferma per uscire dall'app (solo nella tab Info) ---- */
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
    /* ---- Scaffold principale: AppBar con titolo dinamico, body con pagina corrente e bottom navigation ---- */
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        /* ---- Mostro l'icona di logout (solo nella tab Info) ---- */
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
      /* ---- Contenuto della tab selezionata ---- */
      body: _pages[_currentIndex],

      /* ---- Navigazione inferiore: 4 voci fisse con label e tooltip ---- */
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
