import 'package:btg_web/features/portfolio/domain/entities/fund.dart';

abstract class FundRepository {
  Future<List<Fund>> getAvailableFunds({FundCategory? category});
}
