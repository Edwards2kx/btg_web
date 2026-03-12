import 'package:flutter/material.dart';

class TransactionFilterChip extends StatelessWidget {
  const TransactionFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
