import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_colors.dart';
import '../features/dashboard/presentation/controllers/dashboard_controller.dart';
import '../features/pet_owner/domain/entities/pet_booking_entity.dart';
import '../features/pet_owner/presentation/controllers/pet_owner_controller.dart';
import '../features/provider/domain/entities/provider_booking_entity.dart';
import '../features/provider/presentation/controllers/provider_controller.dart';
import '../features/shelter/domain/entities/shelter_operation_entity.dart';
import '../features/shelter/domain/entities/shelter_stat_entity.dart';
import '../features/shelter/presentation/controllers/shelter_controller.dart';
import '../features/volunteer/domain/entities/volunteer_shift_entity.dart';
import '../features/volunteer/presentation/controllers/volunteer_controller.dart';
import '../models/dashboard_models.dart';
import '../routes/app_routes.dart';

const kInk = AppColors.secondary;
const kPrimary = AppColors.primary;
const kPrimaryDark = AppColors.primaryDark;
const kPrimaryGlow = AppColors.primaryGlow;
const kAccentTeal = AppColors.accent;
const kAccentTealGlow = AppColors.accentGlow;
const kHighlight = AppColors.highlight;
const kHighlightGlow = Color(0xFFFEF6DC);
const kCoral = AppColors.coral;
const kCoralGlow = AppColors.errorLight;

RoleDashboardConfig buildRoleDashboardConfig({
  required BuildContext context,
  required String roleName,
  required String displayName,
}) {
  switch (dashboardConfigKeyForRole(roleName)) {
    case 'owner':
      return _ownerConfig(context, displayName);
    case 'volunteer':
      return _volunteerConfig(context, displayName);
    case 'shelter':
      return _shelterConfig(context);
    case 'shop':
      return _shopConfig(context, displayName);
    case 'provider':
      return _providerConfig(context, displayName);
    default:
      return _shopConfig(context, displayName);
  }
}

String dashboardConfigKeyForRole(String roleName) {
  switch (_roleKey(roleName)) {
    case 'petowner':
    case 'petcare':
    case 'animalowner':
    case 'marketplaceclient':
      return 'owner';
    case 'volunteer':
      return 'volunteer';
    case 'shelter':
    case 'shelterowner':
      return 'shelter';
    case 'provider':
    case 'serviceprovider':
      return 'provider';
    case 'shopowner':
      return 'shop';
    default:
      return 'shop';
  }
}

RoleDashboardConfig _ownerConfig(BuildContext context, String displayName) {
  final controller = Get.find<PetOwnerController>();
  final overview = controller.overview.value;
  final pets = overview?.pets ?? controller.pets;
  final bookings = overview?.bookings ?? controller.bookings;
  final activeBookings = bookings
      .where(
        (booking) =>
            booking.status == 'pending' || booking.status == 'confirmed',
      )
      .length;
  final completedBookings = bookings
      .where((booking) => booking.status == 'completed')
      .length;
  final pendingBookings = bookings
      .where((booking) => booking.status == 'pending')
      .length;

  return RoleDashboardConfig(
    title: 'My Zoovana',
    subtitle: 'Pet care dashboard',
    greeting: _timeGreeting(),
    name: _firstName(displayName),
    accent: kPrimary,
    accentDark: kPrimaryDark,
    accentGlow: kPrimaryGlow,
    heroGradient: const [
      Color(0xFF0B1E5B),
      Color(0xFF15347F),
      Color(0xFF1D4ED8),
    ],
    rings: [
      RingData(
        color: kAccentTeal,
        pct: _pct(pets.length, 3),
        label: 'Pet profiles',
      ),
      RingData(
        color: kHighlight,
        pct: _pct(activeBookings, bookings.isEmpty ? 1 : bookings.length),
        label: 'Active bookings',
      ),
      RingData(
        color: kCoral,
        pct: _pct(completedBookings, bookings.isEmpty ? 1 : bookings.length),
        label: 'Completed care',
      ),
    ],
    widgets: [
      WidgetCardData(
        bg: kPrimary,
        fg: CupertinoColors.white,
        title: 'Pets',
        value: '${pets.length}',
        sub: 'Active profiles',
      ),
      WidgetCardData(
        bg: CupertinoColors.white,
        fg: kInk,
        title: 'Next up',
        value: activeBookings == 0 ? 'Ready to book' : '$activeBookings active',
        sub: '${overview?.unreadMessages ?? 0} unread messages',
        solid: false,
      ),
    ],
    chartLabel: 'Booking overview',
    chartSub: 'Total bookings',
    datasets: _statusDatasets(
      total: '${bookings.length}',
      values: [pendingBookings, activeBookings, completedBookings],
    ),
    sectionTitle: 'Upcoming',
    cards: _petBookingCards(bookings),
    onRefresh: controller.loadOverview,
    onSeeAll: () => context.push(AppRoutes.petOwnerBookings),
    onOpenMessages: () => context.push(AppRoutes.chatInbox),
    onOpenSettings: () => context.push(AppRoutes.settings),
    onReschedule: (_) => context.push(AppRoutes.petOwnerBookings),
    onCancel: (_) => context.push(AppRoutes.petOwnerBookings),
    fabActions: [
      FabActionData(
        label: 'Add a pet',
        icon: CupertinoIcons.add,
        onTap: () => context.push(AppRoutes.petOwnerPets),
      ),
      FabActionData(
        label: 'Book a service',
        icon: CupertinoIcons.calendar,
        onTap: () => context.push(AppRoutes.petOwnerServices),
      ),
    ],
  );
}

RoleDashboardConfig _volunteerConfig(BuildContext context, String displayName) {
  final controller = Get.find<VolunteerController>();
  final shifts = controller.shifts;
  final actionable = shifts
      .where((shift) => shift.canSignIn || shift.canSignOut)
      .length;
  final completed = shifts.where((shift) => shift.status == 'completed').length;

  return RoleDashboardConfig(
    title: 'Volunteer Hub',
    subtitle: 'Shifts & impact',
    greeting: 'Welcome back',
    name: _firstName(displayName),
    accent: kHighlight,
    accentDark: const Color(0xFFC9821A),
    accentGlow: kHighlightGlow,
    heroGradient: const [
      Color(0xFF0B1E5B),
      Color(0xFF40361B),
      Color(0xFF6B4E12),
    ],
    rings: [
      RingData(
        color: kHighlight,
        pct: _pct(controller.totalHours, 40),
        label: 'Monthly hours goal',
      ),
      RingData(
        color: kAccentTeal,
        pct: _pct(completed, shifts.isEmpty ? 1 : shifts.length),
        label: 'Completed shifts',
      ),
      RingData(
        color: kCoral,
        pct: _pct(actionable, shifts.isEmpty ? 1 : shifts.length),
        label: 'Needs action',
      ),
    ],
    widgets: [
      WidgetCardData(
        bg: kAccentTeal,
        fg: const Color(0xFF04372F),
        title: 'Hours served',
        value: '${controller.totalHours} hrs',
        sub: 'Across ${shifts.length} shifts',
      ),
      WidgetCardData(
        bg: CupertinoColors.white,
        fg: kInk,
        title: 'Action ready',
        value: '$actionable shifts',
        sub: 'Start or finish attendance',
        solid: false,
      ),
    ],
    chartLabel: 'Hours volunteered',
    chartSub: 'Total hours',
    datasets: _hourDatasets(shifts),
    sectionTitle: 'Upcoming shifts',
    cards: _shiftCards(shifts),
    onRefresh: () async {
      await controller.loadDashboard();
      await controller.loadShelters();
    },
    onSeeAll: () => context.push(AppRoutes.volunteerDashboard),
    onOpenMessages: () => context.push(AppRoutes.chatInbox),
    onOpenSettings: () => context.push(AppRoutes.settings),
    onReschedule: (_) => context.push(AppRoutes.volunteerDashboard),
    onCancel: (_) => context.push(AppRoutes.volunteerDashboard),
    fabActions: [
      FabActionData(
        label: 'Find a shift',
        icon: CupertinoIcons.search,
        onTap: () => context.push(AppRoutes.volunteerDashboard),
      ),
      FabActionData(
        label: 'Log hours',
        icon: CupertinoIcons.pencil,
        onTap: () => context.push(AppRoutes.volunteerDashboard),
      ),
    ],
  );
}

RoleDashboardConfig _shelterConfig(BuildContext context) {
  final controller = Get.find<ShelterController>();
  final overview = controller.overview.value;
  final stats = overview?.stats ?? const <ShelterStatEntity>[];
  final activity = overview?.recentActivity ?? const <ShelterOperationEntity>[];
  final totalAnimals = _statNumber(stats, 'animal');
  final available = _statNumber(stats, 'available');
  final medical =
      _statNumber(stats, 'treatment') + _statNumber(stats, 'medical');
  final vaccinations = _statNumber(stats, 'vaccination');

  return RoleDashboardConfig(
    title: 'Shelter Operations',
    subtitle: 'Care, housing & intake',
    greeting: _timeGreeting(),
    name: 'Team dashboard',
    accent: kAccentTeal,
    accentDark: const Color(0xFF0D9488),
    accentGlow: kAccentTealGlow,
    heroGradient: const [
      Color(0xFF0B1E5B),
      Color(0xFF0F3A46),
      Color(0xFF0D6E63),
    ],
    rings: [
      RingData(
        color: kAccentTeal,
        pct: _pct(
          totalAnimals - available,
          totalAnimals == 0 ? 1 : totalAnimals,
        ),
        label: 'Capacity in use',
      ),
      RingData(
        color: kHighlight,
        pct: _pct(available, totalAnimals == 0 ? 1 : totalAnimals),
        label: 'Available animals',
      ),
      RingData(
        color: kCoral,
        pct: _pct(medical + vaccinations, totalAnimals == 0 ? 1 : totalAnimals),
        label: 'Care attention',
      ),
    ],
    widgets: [
      WidgetCardData(
        bg: kCoral,
        fg: const Color(0xFF4A0A0A),
        title: 'Care queue',
        value: '${medical + vaccinations}',
        sub: 'Medical and vaccination items',
      ),
      WidgetCardData(
        bg: CupertinoColors.white,
        fg: kInk,
        title: 'Animals',
        value: '$totalAnimals total',
        sub: '$available available',
        solid: false,
      ),
    ],
    chartLabel: 'Shelter activity',
    chartSub: 'Open records',
    datasets: _statusDatasets(
      total: '${activity.length}',
      values: [totalAnimals, available, medical, vaccinations],
    ),
    sectionTitle: 'Needs attention',
    cards: _shelterCards(activity),
    onRefresh: controller.loadOverview,
    onSeeAll: () => context.push(AppRoutes.shelterAnimals),
    onOpenMessages: () => context.push(AppRoutes.chatInbox),
    onOpenSettings: () => context.push(AppRoutes.shelterSettings),
    onReschedule: (_) => context.push(AppRoutes.shelterAnimals),
    onCancel: (_) => context.push(AppRoutes.shelterAnimals),
    fabActions: [
      FabActionData(
        label: 'Add animal',
        icon: CupertinoIcons.add,
        onTap: () => context.push(AppRoutes.shelterAnimals),
      ),
      FabActionData(
        label: 'New task',
        icon: CupertinoIcons.list_bullet,
        onTap: () => context.push(AppRoutes.shelterAnimalCare),
      ),
    ],
  );
}

RoleDashboardConfig _shopConfig(BuildContext context, String displayName) {
  final controller = Get.find<DashboardController>();
  final overview = controller.overview.value;
  final revenue =
      double.tryParse(overview?.totalRevenue.replaceAll(',', '') ?? '') ?? 0;
  final lowStock = overview?.lowStockCount ?? 0;
  final orders = overview?.totalOrders ?? 0;
  final trend = overview?.revenueTrend ?? const [];

  return RoleDashboardConfig(
    title: 'Shop Owner',
    subtitle: 'Commerce & inventory',
    greeting: _timeGreeting(),
    name: displayName.isEmpty ? 'Zoovana Store' : displayName,
    accent: const Color(0xFF6C8EF5),
    accentDark: const Color(0xFF3B5BD9),
    accentGlow: const Color(0xFFE7ECFB),
    heroGradient: const [
      Color(0xFF0B1E5B),
      Color(0xFF122A6E),
      Color(0xFF1E3A8A),
    ],
    rings: [
      RingData(
        color: kAccentTeal,
        pct: _pct(revenue, revenue == 0 ? 1 : revenue * 1.2),
        label: 'Revenue progress',
      ),
      RingData(
        color: kHighlight,
        pct: (100 - _pct(lowStock, lowStock + 20)).clamp(0, 100).toDouble(),
        label: 'Inventory health',
      ),
      RingData(
        color: kCoral,
        pct: _pct(orders, orders == 0 ? 1 : orders + lowStock),
        label: 'Order flow',
      ),
    ],
    widgets: [
      WidgetCardData(
        bg: kHighlight,
        fg: const Color(0xFF5C3D06),
        title: 'Low stock',
        value: '$lowStock items',
        sub: 'Needs attention',
      ),
      WidgetCardData(
        bg: CupertinoColors.white,
        fg: kInk,
        title: 'Orders',
        value: '$orders total',
        sub: '${overview?.activeShops ?? 0} active shops',
        solid: false,
      ),
    ],
    chartLabel: 'Revenue overview',
    chartSub: 'Total revenue',
    datasets: _trendDatasets(
      total: 'SAR ${overview?.totalRevenue ?? '0'}',
      values: trend.map((point) => point.amount).toList(),
      labels: trend.map((point) => point.period).toList(),
    ),
    sectionTitle: 'Recent orders',
    cards: [
      UpcomingCardData(
        tag: lowStock > 0 ? 'LOW STOCK' : 'READY',
        icon: '!',
        title: lowStock > 0
            ? '$lowStock products need restock'
            : 'Inventory is healthy',
        subtitle: 'Review product availability',
      ),
      UpcomingCardData(
        tag: 'ORDERS',
        icon: '#',
        title: '$orders marketplace orders',
        subtitle: 'Open order management',
      ),
    ],
    onRefresh: controller.refresh,
    onSeeAll: () => context.push(AppRoutes.moduleOrders),
    onOpenMessages: () => context.push(AppRoutes.chatInbox),
    onOpenSettings: () => context.push(AppRoutes.settings),
    onReschedule: (_) => context.push(AppRoutes.moduleOrders),
    onCancel: (_) => context.push(AppRoutes.moduleOrders),
    fabActions: [
      FabActionData(
        label: 'Add product',
        icon: CupertinoIcons.tag,
        onTap: () => context.push(AppRoutes.products),
      ),
      FabActionData(
        label: 'New order',
        icon: CupertinoIcons.doc_text,
        onTap: () => context.push(AppRoutes.moduleOrders),
      ),
    ],
  );
}

RoleDashboardConfig _providerConfig(BuildContext context, String displayName) {
  final controller = Get.find<ProviderController>();
  final overview = controller.overview.value;
  final bookings = overview?.bookings ?? controller.bookings;
  final pending =
      overview?.pendingBookingCount ??
      bookings.where((booking) => booking.status == 'pending').length;
  final completed =
      overview?.completedJobs ??
      bookings.where((booking) => booking.status == 'completed').length;

  return RoleDashboardConfig(
    title: 'Service Provider',
    subtitle: 'Bookings & earnings',
    greeting: _timeGreeting(),
    name: overview?.profile?.businessName ?? _firstName(displayName),
    accent: kCoral,
    accentDark: const Color(0xFFE14848),
    accentGlow: kCoralGlow,
    heroGradient: const [
      Color(0xFF0B1E5B),
      Color(0xFF3E1B2E),
      Color(0xFF7A1F2B),
    ],
    rings: [
      RingData(
        color: kHighlight,
        pct: _pct((overview?.rating ?? 0) * 20, 100),
        label: 'Client rating',
      ),
      RingData(
        color: kAccentTeal,
        pct: (overview?.responseRate ?? 0).clamp(0, 100).toDouble(),
        label: 'Response rate',
      ),
      RingData(
        color: kCoral,
        pct: _pct(completed, bookings.isEmpty ? 1 : bookings.length),
        label: 'Completed jobs',
      ),
    ],
    widgets: [
      WidgetCardData(
        bg: kAccentTeal,
        fg: const Color(0xFF04372F),
        title: 'Revenue',
        value: overview?.monthlyRevenueLabel ?? 'SAR 0',
        sub:
            '+${overview?.monthlyRevenueChangePercent.toStringAsFixed(0) ?? '0'}%',
      ),
      WidgetCardData(
        bg: CupertinoColors.white,
        fg: kInk,
        title: 'Pending',
        value: '$pending bookings',
        sub:
            '${overview?.activeServiceCount ?? controller.services.length} active services',
        solid: false,
      ),
    ],
    chartLabel: 'Earnings overview',
    chartSub: 'Total earned',
    datasets: _trendDatasets(
      total: overview?.monthlyRevenueLabel ?? 'SAR 0',
      values:
          overview?.earningsTrend.map((point) => point.amount).toList() ??
          const [],
      labels:
          overview?.earningsTrend.map((point) => point.month).toList() ??
          const [],
    ),
    sectionTitle: 'Upcoming bookings',
    cards: _providerBookingCards(bookings),
    onRefresh: controller.loadOverview,
    onSeeAll: () => context.push(AppRoutes.providerBookings),
    onOpenMessages: () => context.push(AppRoutes.chatInbox),
    onOpenSettings: () => context.push(AppRoutes.providerSettings),
    onReschedule: (_) => context.push(AppRoutes.providerBookings),
    onCancel: (card) {
      final booking = bookings.firstWhereOrNull((item) => item.id == card.id);
      if (booking == null) {
        context.push(AppRoutes.providerBookings);
        return;
      }
      controller.updateBooking(booking: booking, action: 'cancel');
    },
    fabActions: [
      FabActionData(
        label: 'New service',
        icon: CupertinoIcons.wrench,
        onTap: () => context.push(AppRoutes.providerServices),
      ),
      FabActionData(
        label: 'Availability',
        icon: CupertinoIcons.calendar,
        onTap: () => context.push(AppRoutes.providerBookings),
      ),
    ],
  );
}

Map<String, ChartDataset> _statusDatasets({
  required String total,
  required List<num> values,
}) {
  final normalized = _normalize(values);
  return {
    'week': ChartDataset(
      total: total,
      values: normalized,
      labels: const [
        'P',
        'A',
        'C',
        'D',
        'E',
        'F',
        'G',
      ].take(normalized.length).toList(),
    ),
    'month': ChartDataset(
      total: total,
      values: _spread(normalized, 7),
      labels: const ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'],
    ),
    'year': ChartDataset(
      total: total,
      values: _spread(normalized, 7).reversed.toList(),
      labels: const ['J', 'F', 'M', 'A', 'M', 'J', 'J'],
    ),
  };
}

Map<String, ChartDataset> _trendDatasets({
  required String total,
  required List<num> values,
  required List<String> labels,
}) {
  final normalized = _normalize(
    values.isEmpty ? const [0, 0, 0, 0, 0, 0, 0] : values,
  );
  final chartLabels = labels.isEmpty
      ? const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
      : labels
            .map((label) => label.length > 3 ? label.substring(0, 3) : label)
            .toList();
  return {
    'week': ChartDataset(
      total: total,
      values: _spread(normalized, 7),
      labels: _spreadLabels(chartLabels, 7),
    ),
    'month': ChartDataset(
      total: total,
      values: _spread(normalized, 7),
      labels: const ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'],
    ),
    'year': ChartDataset(
      total: total,
      values: _spread(normalized, 7).reversed.toList(),
      labels: const ['J', 'F', 'M', 'A', 'M', 'J', 'J'],
    ),
  };
}

Map<String, ChartDataset> _hourDatasets(List<VolunteerShiftEntity> shifts) {
  final values = shifts.map((shift) => shift.hoursWorked ?? 0).toList();
  final total = values.fold<double>(0, (sum, value) => sum + value).round();
  return _trendDatasets(
    total: '$total hrs',
    values: values,
    labels: shifts.map((shift) => _shortDate(shift.startsAt)).toList(),
  );
}

List<double> _normalize(List<num> values) {
  final safe = values.isEmpty ? const [0] : values;
  final maxValue = safe.fold<num>(0, (max, value) => value > max ? value : max);
  if (maxValue <= 0) return safe.map((_) => 8.0).toList();
  return safe
      .map((value) => ((value / maxValue) * 100).clamp(8, 100).toDouble())
      .toList();
}

List<double> _spread(List<double> values, int count) {
  if (values.isEmpty) return List.filled(count, 8);
  return List.generate(count, (index) => values[index % values.length]);
}

List<String> _spreadLabels(List<String> values, int count) {
  if (values.isEmpty) return const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  return List.generate(count, (index) => values[index % values.length]);
}

List<UpcomingCardData> _petBookingCards(List<PetBookingEntity> bookings) {
  final cards = bookings.take(5).map((booking) {
    return UpcomingCardData(
      id: booking.id,
      tag: _dateTag(
        booking.scheduledAt,
        fallback: booking.status.toUpperCase(),
      ),
      icon: '•',
      title: booking.serviceTitle,
      subtitle:
          '${booking.providerName}${booking.petName == null ? '' : ' · ${booking.petName}'}',
    );
  }).toList();
  if (cards.isNotEmpty) return cards;
  return const [
    UpcomingCardData(
      tag: 'READY',
      icon: '+',
      title: 'Book your first service',
      subtitle: 'Trusted providers are ready when you are',
    ),
  ];
}

List<UpcomingCardData> _providerBookingCards(
  List<ProviderBookingEntity> bookings,
) {
  final cards = bookings.take(5).map((booking) {
    return UpcomingCardData(
      id: booking.id,
      tag: _dateTag(
        booking.scheduledAt,
        fallback: booking.status.toUpperCase(),
      ),
      icon: '•',
      title: booking.serviceTitle,
      subtitle:
          '${booking.petOwnerName}${booking.petName == null ? '' : ' · ${booking.petName}'}',
    );
  }).toList();
  if (cards.isNotEmpty) return cards;
  return const [
    UpcomingCardData(
      tag: 'READY',
      icon: '+',
      title: 'Publish a service',
      subtitle: 'New bookings will appear here',
    ),
  ];
}

List<UpcomingCardData> _shiftCards(List<VolunteerShiftEntity> shifts) {
  final cards = shifts.take(5).map((shift) {
    return UpcomingCardData(
      id: shift.id,
      tag: _dateTag(shift.startsAt, fallback: shift.status.toUpperCase()),
      icon: '•',
      title: shift.role,
      subtitle: shift.shelterName ?? shift.notes ?? 'Volunteer shift',
    );
  }).toList();
  if (cards.isNotEmpty) return cards;
  return const [
    UpcomingCardData(
      tag: 'OPEN',
      icon: '+',
      title: 'No shifts scheduled',
      subtitle: 'Apply to shelters accepting volunteer help',
    ),
  ];
}

List<UpcomingCardData> _shelterCards(List<ShelterOperationEntity> activity) {
  final cards = activity.take(5).map((item) {
    return UpcomingCardData(
      id: item.id,
      tag: item.status.toUpperCase(),
      icon: '•',
      title: item.title,
      subtitle: item.subtitle,
    );
  }).toList();
  if (cards.isNotEmpty) return cards;
  return const [
    UpcomingCardData(
      tag: 'READY',
      icon: '+',
      title: 'No recent activity',
      subtitle: 'Animal intake and updates will appear here',
    ),
  ];
}

double _pct(num value, num max) {
  if (max <= 0) return 0;
  return ((value / max) * 100).clamp(0, 100).toDouble();
}

int _statNumber(List<ShelterStatEntity> stats, String key) {
  for (final stat in stats) {
    if (stat.label.toLowerCase().contains(key.toLowerCase())) {
      return int.tryParse(stat.value.replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
    }
  }
  return 0;
}

String _dateTag(DateTime? date, {required String fallback}) {
  if (date == null) return fallback.isEmpty ? 'UPCOMING' : fallback;
  final now = DateTime.now();
  final sameDay =
      date.year == now.year && date.month == now.month && date.day == now.day;
  if (sameDay) return 'TODAY';
  final tomorrow = now.add(const Duration(days: 1));
  if (date.year == tomorrow.year &&
      date.month == tomorrow.month &&
      date.day == tomorrow.day) {
    return 'TOMORROW';
  }
  return _shortDate(date).toUpperCase();
}

String _shortDate(DateTime? date) {
  if (date == null) return 'TBD';
  const months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  return '${months[date.month - 1]} ${date.day}';
}

String _timeGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

String _firstName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return 'Zoovana';
  return trimmed.split(RegExp(r'\s+')).first;
}

String _roleKey(String roleName) {
  return roleName.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
}
