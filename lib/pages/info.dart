import 'package:flutter/material.dart';
import '../widgets/simple_card.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final hours = const <({String day, String time})>[
      (day: 'Lun - Ven', time: '19:00 - 00:00'),
      (day: 'Sabato', time: '11:00 - 2:00'),
      (day: 'Domenica', time: 'Chiuso'),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cs.surface, cs.surfaceContainerHighest],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Giorni e orari
            SimpleCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.calendar_month, color: cs.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Giorni e orari di apertura:',
                            style: tt.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Table(
                            columnWidths: const {
                              0: IntrinsicColumnWidth(),
                              1: FlexColumnWidth(),
                            },
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: [
                              for (final h in hours) _hoursRow(tt, h.day, h.time),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // testo centrale
            SimpleCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ristorante Crunchy', style: tt.titleMedium),
                    const SizedBox(height: 12),
                    Text(
                      'Tutti i nostri prodotti sono fatti con cura e tanto amore, '
                      'usando solo ingrendienti di nostra produzione, per garantire la miglior esperienza culinaria possibile.',
                      style: tt.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contatti
            SimpleCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Contatti', style: tt.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.email, color: cs.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('info@crunchy.com', style: tt.bodyLarge),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.phone, color: cs.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('+39 0123456789', style: tt.bodyLarge),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _hoursRow(TextTheme tt, String day, String time) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(day, style: tt.bodyLarge),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
          child: Text(time, style: tt.bodyLarge),
        ),
      ],
    );
  }
}
