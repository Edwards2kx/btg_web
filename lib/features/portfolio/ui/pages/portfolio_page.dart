import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/di/user_injection.dart';
import '../../../auth/domain/entities/user.dart';

final userInfoFutureProvider = FutureProvider.autoDispose<User>((ref) {
  return ref.watch(getUserInfoUseCaseProvider).call();
});

class PortfolioPage extends ConsumerWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfoAsync = ref.watch(userInfoFutureProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Portfolio')),
      body: Center(
        child: userInfoAsync.when(
          data:
              (user) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Portfolio de ${user.firstName} ${user.lastName}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Saldo: \$${user.balance.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 20, color: Colors.green),
                  ),
                ],
              ),
          loading: () => const CircularProgressIndicator(),
          error:
              (error, stack) => Text(
                "Error al cargar usuario",
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
        ),
      ),
    );
  }
}
