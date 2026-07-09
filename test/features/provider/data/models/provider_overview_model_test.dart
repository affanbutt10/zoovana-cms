import 'package:flutter_test/flutter_test.dart';
import 'package:zoovana_cms/features/provider/data/models/provider_overview_model.dart';

void main() {
  test('parses the provider dashboard API response', () {
    final model = ProviderOverviewModel.fromJson({
      'currency': 'SAR',
      'monthly_revenue': '1250.50',
      'monthly_revenue_change_percent': 12.5,
      'total_bookings': 8,
      'pending_bookings': 2,
      'profile_rating': 4.8,
      'total_reviews': 10,
      'response_rate': 96.0,
      'response_label': 'Excellent',
      'completed_jobs': 6,
      'completed_this_week': 2,
      'earnings_trend': [
        {'month': 'Jul', 'amount': '500.00'},
      ],
      'services_performance': [],
    });

    expect(model.monthlyRevenue, 1250.5);
    expect(model.pendingBookings, 2);
    expect(model.earningsTrend.single.month, 'Jul');
    expect(model.earningsTrend.single.amount, 500);
  });
}
