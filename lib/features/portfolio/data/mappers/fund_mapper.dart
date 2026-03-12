import '../models/fund_model.dart';
import '../../domain/entities/fund.dart';

class FundMapper {
  static FundCategory _parseCategory(String category) {
    switch (category.toUpperCase()) {
      case 'FPV':
        return FundCategory.fpv;
      case 'FIC':
        return FundCategory.fic;
      default:
        throw Exception('Unknown fund category: $category');
    }
  }

  static Fund toEntity(FundModel model) {
    return Fund(
      id: model.id,
      name: model.name,
      minimumAmount: model.minimumAmount,
      category: _parseCategory(model.category),
    );
  }
}
