/// Representa un fondo FPV o FIC disponible para suscripción.
class Fund {
  final String id;
  final String name;
  final double minimumAmount;
  final FundCategory category;

  const Fund({
    required this.id,
    required this.name,
    required this.minimumAmount,
    required this.category,
  });
}

/// Categorías posibles de un fondo según el negocio BTG.
enum FundCategory {
  /// Fondo de Pensiones Voluntarias
  fpv,

  /// Fondo de Inversión Colectiva
  fic,
}
