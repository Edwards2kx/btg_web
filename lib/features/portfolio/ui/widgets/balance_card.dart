import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/utils/currency_formatter.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../transactions/di/transaction_providers.dart';
import 'package:btg_web/features/portfolio/ui/provider/funds_provider.dart';

class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key, required this.userAsync});

  final AsyncValue<User> userAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final balanceAsync = ref.watch(availableBalanceProvider);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo Total de la Cuenta',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          balanceAsync.when(
            loading:
                () => const SizedBox(
                  height: 44,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
            error:
                (_, __) => Text(
                  '\$0.00 COP (Error)',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.redAccent,
                  ),
                ),
            data: (balance) => Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      CurrencyFormatter.format(balance),
                      style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w800, // ExtraBold
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'COP',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crecimiento Semanal',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '+2.4%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4ADE80), // Vibrant green for growth
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fondos Disponibles',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                      const SizedBox(height: 4),
                      ref.watch(availableFundsProvider()).when(
                            data: (funds) => Text(
                              '${funds.length} Fondos',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            loading: () => const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            error: (_, __) => const Text(
                              '-- Fondos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
