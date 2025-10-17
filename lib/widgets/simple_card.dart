import 'package:flutter/material.dart';

class SimpleCard extends StatelessWidget {
  final Widget child;
  const SimpleCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = cs.surfaceContainer;
   return Material(
  color: bg,
  elevation: 8,
  shadowColor: Colors.black,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  clipBehavior: Clip.antiAlias,
  child: DecoratedBox(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.white),
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  ),
);
  }
}
