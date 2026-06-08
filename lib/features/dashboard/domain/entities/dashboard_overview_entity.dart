class DashboardOverviewEntity {
  final String totalRevenue;
  final double revenueChangePercentage;
  final int totalOrders;
  final double ordersChangePercentage;
  final int activeShops;
  final int newShopsCount;
  final int lowStockCount;
  final List<RevenueTrendEntity> revenueTrend;
  final List<SalesByCategoryEntity> salesByCategory;

  DashboardOverviewEntity({
    required this.totalRevenue,
    required this.revenueChangePercentage,
    required this.totalOrders,
    required this.ordersChangePercentage,
    required this.activeShops,
    required this.newShopsCount,
    required this.lowStockCount,
    required this.revenueTrend,
    required this.salesByCategory,
  });
}

class RevenueTrendEntity {
  final String period;
  final double amount;

  RevenueTrendEntity({
    required this.period,
    required this.amount,
  });
}

class SalesByCategoryEntity {
  final String categoryName;
  final double amount;
  final double percentage;

  SalesByCategoryEntity({
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });
}
