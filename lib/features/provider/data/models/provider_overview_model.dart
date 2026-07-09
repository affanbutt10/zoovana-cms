import '../../domain/entities/provider_overview_entity.dart';
import '../../domain/entities/provider_booking_entity.dart';
import '../../domain/entities/provider_profile_entity.dart';
import '../../domain/entities/provider_service_entity.dart';

class ProviderOverviewModel {
  const ProviderOverviewModel({
    required this.currency,
    required this.monthlyRevenue,
    required this.monthlyRevenueChangePercent,
    required this.totalBookings,
    required this.pendingBookings,
    required this.profileRating,
    required this.totalReviews,
    required this.responseRate,
    required this.responseLabel,
    required this.completedJobs,
    required this.completedThisWeek,
    required this.earningsTrend,
    required this.servicesPerformance,
  });

  final String currency;
  final double monthlyRevenue;
  final double monthlyRevenueChangePercent;
  final int totalBookings;
  final int pendingBookings;
  final double profileRating;
  final int totalReviews;
  final double responseRate;
  final String responseLabel;
  final int completedJobs;
  final int completedThisWeek;
  final List<ProviderEarningPoint> earningsTrend;
  final List<ProviderServicePerformance> servicesPerformance;

  factory ProviderOverviewModel.fromJson(Map<String, dynamic> json) {
    final trend = json['earnings_trend'];
    final performance = json['services_performance'];
    return ProviderOverviewModel(
      currency: json['currency']?.toString() ?? 'SAR',
      monthlyRevenue: _double(json['monthly_revenue']),
      monthlyRevenueChangePercent: _double(
        json['monthly_revenue_change_percent'],
      ),
      totalBookings: _int(json['total_bookings']),
      pendingBookings: _int(json['pending_bookings']),
      profileRating: _double(json['profile_rating']),
      totalReviews: _int(json['total_reviews']),
      responseRate: _double(json['response_rate']),
      responseLabel: json['response_label']?.toString() ?? '',
      completedJobs: _int(json['completed_jobs']),
      completedThisWeek: _int(json['completed_this_week']),
      earningsTrend: trend is List
          ? trend.whereType<Map<String, dynamic>>().map((item) {
              return ProviderEarningPoint(
                month: item['month']?.toString() ?? '',
                amount: _double(item['amount']),
              );
            }).toList()
          : const [],
      servicesPerformance: performance is List
          ? performance.whereType<Map<String, dynamic>>().map((item) {
              return ProviderServicePerformance(
                name: (item['service_name'] ?? item['title'] ?? 'Service')
                    .toString(),
                bookings: _int(item['bookings'] ?? item['total_bookings']),
                revenue: _double(item['revenue']),
              );
            }).toList()
          : const [],
    );
  }

  ProviderOverviewEntity toEntity({
    required ProviderProfileEntity? profile,
    required List<ProviderServiceEntity> services,
    required List<ProviderBookingEntity> bookings,
  }) {
    return ProviderOverviewEntity(
      profile: profile,
      services: services,
      bookings: bookings,
      currency: currency,
      monthlyRevenue: monthlyRevenue,
      monthlyRevenueChangePercent: monthlyRevenueChangePercent,
      totalBookings: totalBookings,
      pendingBookings: pendingBookings,
      rating: profileRating,
      totalReviews: totalReviews,
      responseRate: responseRate,
      responseLabel: responseLabel,
      completedJobs: completedJobs,
      completedThisWeek: completedThisWeek,
      earningsTrend: earningsTrend,
      servicesPerformance: servicesPerformance,
    );
  }

  static double _double(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  static int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}
