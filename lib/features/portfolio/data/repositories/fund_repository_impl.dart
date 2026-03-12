import 'package:flutter/rendering.dart';

import '../../domain/entities/fund.dart';
import '../../domain/repositories/fund_repository.dart';
import '../datasources/funds_local_datasource.dart';
import '../mappers/fund_mapper.dart';

class FundRepositoryImpl implements FundRepository {
  FundRepositoryImpl({required this.localDataSource});

  final FundsLocalDataSource localDataSource;

  @override
  Future<List<Fund>> getAvailableFunds({FundCategory? category}) async {
    final models = await localDataSource.getAvailableFunds(category: category);

    final List<Fund> funds = [];
    for (final model in models) {
      try {
        final fund = FundMapper.toEntity(model);
        funds.add(fund);
      } catch (e) {
        debugPrint(
          'Error: data corrupta, no se pudo procesar el fondo. Elemento: $model. Excepción: $e',
        );
      }
    }

    return funds;
  }
}
