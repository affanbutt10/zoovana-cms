import 'provider_booking_entity.dart';
import 'provider_profile_entity.dart';
import 'provider_service_entity.dart';

class ProviderOverviewEntity {
  const ProviderOverviewEntity({
    required this.profile,
    required this.services,
    required this.bookings,
    this.currency = 'SAR',
    this.monthlyRevenue = 0,
    this.monthlyRevenueChangePercent = 0,
    this.totalBookings = 0,
    this.pendingBookings = 0,
    this.rating,
    this.totalReviews = 0,
    this.responseRate = 0,
    this.responseLabel = '',
    this.completedJobs = 0,
    this.completedThisWeek = 0,
    this.earningsTrend = const [],
    this.servicesPerformance = const [],
  });

  final ProviderProfileEntity? profile;
  final List<ProviderServiceEntity> services;
  final List<ProviderBookingEntity> bookings;
  final String currency;
  final double monthlyRevenue;
  final double monthlyRevenueChangePercent;
  final int totalBookings;
  final int pendingBookings;
  final double? rating;
  final int totalReviews;
  final double responseRate;
  final String responseLabel;
  final int completedJobs;
  final int completedThisWeek;
  final List<ProviderEarningPoint> earningsTrend;
  final List<ProviderServicePerformance> servicesPerformance;

  String get monthlyRevenueLabel =>
      '$currency ${monthlyRevenue.toStringAsFixed(monthlyRevenue % 1 == 0 ? 0 : 2)}';

  int get activeServiceCount =>
      services.where((service) => service.isActive).length;

  int get pendingBookingCount => pendingBookings != 0
      ? pendingBookings
      : bookings.where((booking) => booking.status == 'pending').length;
}

class ProviderEarningPoint {
  const ProviderEarningPoint({required this.month, required this.amount});

  final String month;
  final double amount;
}

class ProviderServicePerformance {
  const ProviderServicePerformance({
    required this.name,
    required this.bookings,
    required this.revenue,
  });

  final String name;
  final int bookings;
  final double revenue;
}
