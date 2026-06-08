import '../../domain/entities/dashboard_overview_entity.dart';

class DashboardOverviewModel {
  final String totalRevenue;
  final double revenueChangePercentage;
  final int totalOrders;
  final double ordersChangePercentage;
  final int activeShops;
  final int newShopsCount;
  final int lowStockCount;
  final List<RevenueTrendModel> revenueTrend;
  final List<SalesByCategoryModel> salesByCategory;

  DashboardOverviewModel({
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

  factory DashboardOverviewModel.fromJson(Map<String, dynamic> json) {
    return DashboardOverviewModel(
      totalRevenue: json['total_revenue'] as String? ?? '0.00',
      revenueChangePercentage: (json['revenue_change_percentage'] as num?)?.toDouble() ?? 0.0,
      totalOrders: json['total_orders'] as int? ?? 0,
      ordersChangePercentage: (json['orders_change_percentage'] as num?)?.toDouble() ?? 0.0,
      activeShops: json['active_shops'] as int? ?? 0,
      newShopsCount: json['new_shops_count'] as int? ?? 0,
      lowStockCount: json['low_stock_count'] as int? ?? 0,
      revenueTrend: (json['revenue_trend'] as List<dynamic>?)
              ?.map((e) => RevenueTrendModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      salesByCategory: (json['sales_by_category'] as List<dynamic>?)
              ?.map((e) => SalesByCategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  DashboardOverviewEntity toEntity() {
    return DashboardOverviewEntity(
      totalRevenue: totalRevenue,
      revenueChangePercentage: revenueChangePercentage,
      totalOrders: totalOrders,
      ordersChangePercentage: ordersChangePercentage,
      activeShops: activeShops,
      newShopsCount: newShopsCount,
      lowStockCount: lowStockCount,
      revenueTrend: revenueTrend.map((e) => e.toEntity()).toList(),
      salesByCategory: salesByCategory.map((e) => e.toEntity()).toList(),
    );
  }
}

class RevenueTrendModel {
  final String period;
  final double amount;

  RevenueTrendModel({
    required this.period,
    required this.amount,
  });

  factory RevenueTrendModel.fromJson(Map<String, dynamic> json) {
    return RevenueTrendModel(
      period: json['period'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  RevenueTrendEntity toEntity() {
    return RevenueTrendEntity(
      period: period,
      amount: amount,
    );
  }
}

class SalesByCategoryModel {
  final String categoryName;
  final double amount;
  final double percentage;

  SalesByCategoryModel({
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });

  factory SalesByCategoryModel.fromJson(Map<String, dynamic> json) {
    return SalesByCategoryModel(
      categoryName: json['category_name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  SalesByCategoryEntity toEntity() {
    return SalesByCategoryEntity(
      categoryName: categoryName,
      amount: amount,
      percentage: percentage,
    );
  }
}
