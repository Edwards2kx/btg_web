import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/utils/currency_formatter.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../transactions/di/transaction_providers.dart';
import 'package:btg_web/features/portfolio/ui/provider/funds_provider.dart';

class BalanceCard extends ConsumerWidget {
  const BalanceCard({
    super.key,
    required this.userAsync,
    required this.isMobile,
  });

  final AsyncValue<User> userAsync;
  final bool isMobile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final balanceAsync = ref.watch(availableBalanceProvider);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo Total de la Cuenta',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.primary.withValues(alpha: 0.75),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          balanceAsync.when(
            loading:
                () => SizedBox(
                  height: 44,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
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
            data:
                (balance) => Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      CurrencyFormatter.format(balance),
                      style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w800, // ExtraBold
                        color: colorScheme.primary,
                        height: 1,
                        letterSpacing: -0.9,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'COP',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: colorScheme.primary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
          ),
          // const SizedBox(height: 24),
          if (!isMobile) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: [
                      Text(
                        'Fondos Disponibles',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.primary.withValues(alpha: 0.65),
                        ),
                      ),
                      const SizedBox(height: 4),
                      ref
                          .watch(availableFundsProvider())
                          .when(
                            data:
                                (funds) => Text(
                                  '${funds.length}',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                            loading:
                                () => SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: colorScheme.primary,
                                    strokeWidth: 2,
                                  ),
                                ),
                            error:
                                (_, __) => Text(
                                  '-- Fondos',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
