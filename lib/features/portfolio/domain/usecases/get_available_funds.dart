import 'package:btg_web/features/portfolio/domain/entities/fund.dart';
import 'package:btg_web/features/portfolio/domain/repositories/fund_repository.dart';

class GetAvailableFundsUseCase {
  GetAvailableFundsUseCase({required this.repository});

  final FundRepository repository;

  Future<List<Fund>> call({FundCategory? category}) async {
    return repository.getAvailableFunds(category: category);
  }
}
