import '../../domain/entities/fund.dart';
import '../models/fund_model.dart';

class FundsLocalDataSource {
  Future<List<FundModel>> getAvailableFunds({FundCategory? category}) async {
    await Future.delayed(const Duration(seconds: 1)); // mock delay

    final List<Map<String, dynamic>> jsonList = [
      {
        'id': '1',
        'name': 'FPV_BTG_PACTUAL_RECAUDADORA',
        'minimum_amount': 75000.0,
        'category': 'FPV',
      },
      {
        'id': '2',
        'name': 'FPV_BTG_PACTUAL_ECOPETROL',
        'minimum_amount': 125000.0,
        'category': 'FPV',
      },
      {
        'id': '3',
        'name': 'DEUDAPRIVADA',
        'minimum_amount': 50000.0,
        'category': 'FIC',
      },
      {
        'id': '4',
        'name': 'FDO-ACCIONES',
        'minimum_amount': 250000.0,
        'category': 'FIC',
      },
      {
        'id': '5',
        'name': 'FPV_BTG_PACTUAL_DINAMICA',
        'minimum_amount': 100000.0,
        'category': 'FPV',
      },
    ];

    var models = jsonList.map((json) => FundModel.fromJson(json)).toList();
    if (category != null) {
      models = models.where((model) => model.category == category.name.toUpperCase()).toList();
    }
    return models;
  }
}
