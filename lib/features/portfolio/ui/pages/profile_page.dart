import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/di/user_injection.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../transactions/di/transaction_providers.dart';

final _profileUserProvider = FutureProvider.autoDispose<User>((ref) {
  return ref.watch(getUserInfoUseCaseProvider).call();
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(_profileUserProvider);
    final balanceAsync = ref.watch(availableBalanceProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              const Text('Error al cargar perfil'),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(_profileUserProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (user) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Avatar
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      '${user.firstName[0]}${user.lastName[0]}',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Full name
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${user.id}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Balance card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.account_balance_wallet,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Saldo disponible',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                balanceAsync.when(
                                  loading: () => const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(),
                                  ),
                                  error: (_, __) => Text(
                                    'Error',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.error,
                                    ),
                                  ),
                                  data: (balance) => Text(
                                    '\$${balance.toStringAsFixed(2)}',
                                    style: theme.textTheme.titleLarge?.copyWith(
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

