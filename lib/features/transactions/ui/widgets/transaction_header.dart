import 'package:flutter/material.dart';

class TransactionColumnHeader extends StatelessWidget {
  const TransactionColumnHeader(this.title, {super.key, this.alignment = Alignment.centerLeft});

  final String title;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
