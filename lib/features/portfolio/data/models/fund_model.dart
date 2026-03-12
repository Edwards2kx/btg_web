class FundModel {
  final String id;
  final String name;
  final double minimumAmount;
  final String category;

  FundModel({
    required this.id,
    required this.name,
    required this.minimumAmount,
    required this.category,
  });

  factory FundModel.fromJson(Map<String, dynamic> json) {
    return FundModel(
      id: json['id'],
      name: json['name'],
      minimumAmount: (json['minimum_amount'] as num).toDouble(),
      category: json['category'],
    );
  }

  @override
  String toString() {
    return 'FundModel(id: $id, name: $name, minimumAmount: $minimumAmount, category: $category)';
  }
}
