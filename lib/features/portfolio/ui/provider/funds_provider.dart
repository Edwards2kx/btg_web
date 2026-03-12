import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di/fund_injection.dart';
import '../../domain/entities/fund.dart';

part 'funds_provider.g.dart';

/// Notifier que carga la lista de fondos disponibles.
/// El parámetro [category] permite filtrar por FPV, FIC o null (todos).
@riverpod
class AvailableFunds extends _$AvailableFunds {
  @override
  Future<List<Fund>> build({FundCategory? category}) async {
    final useCase = ref.watch(getAvailableFundsUseCaseProvider);
    return useCase.call(category: category);
  }
}
