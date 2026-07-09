import 'package:flutter/cupertino.dart';
import '../models/dashboard_models.dart';

// Brand palette — keep these as your single source of truth for color.
const kInk = Color(0xFF0B1E5B);
const kPrimary = Color(0xFF3B82F6);
const kPrimaryDark = Color(0xFF2563EB);
const kPrimaryGlow = Color(0xFFDBEAFE);
const kAccentTeal = Color(0xFF4ECDC4);
const kAccentTealGlow = Color(0xFFE0F7F5);
const kHighlight = Color(0xFFF5C842);
const kHighlightGlow = Color(0xFFFEF6DC);
const kCoral = Color(0xFFFF6B6B);
const kCoralGlow = Color(0xFFFEE2E2);

final Map<String, RoleDashboardConfig> roleConfigs = {
  'owner': RoleDashboardConfig(
    title: 'My Zoovana',
    subtitle: 'Pet care dashboard',
    greeting: 'Good morning',
    name: 'Affan 👋',
    accent: kPrimary,
    accentDark: kPrimaryDark,
    accentGlow: kPrimaryGlow,
    heroGradient: const [Color(0xFF0B1E5B), Color(0xFF15347F), Color(0xFF1D4ED8)],
    rings: const [
      RingData(color: kAccentTeal, pct: 78, label: 'Wellness score'),
      RingData(color: kHighlight, pct: 45, label: 'Monthly bookings goal'),
      RingData(color: kCoral, pct: 92, label: 'Care streak'),
    ],
    widgets: const [
      WidgetCardData(bg: kHighlight, fg: Color(0xFF5C3D06), title: 'Care streak', value: '12 days 🔥', sub: 'Personal best: 18'),
      WidgetCardData(bg: CupertinoColors.white, fg: kInk, title: 'Next up', value: 'Vet visit', sub: 'Tomorrow, 4:30 PM', solid: false),
    ],
    chartLabel: 'Spending overview',
    chartSub: 'Total spent',
    datasets: const {
      'week': ChartDataset(total: 'SAR 640', values: [30, 55, 40, 80, 60, 95, 45], labels: ['M', 'T', 'W', 'T', 'F', 'S', 'S']),
      'month': ChartDataset(total: 'SAR 2,410', values: [45, 60, 50, 90, 70, 40, 85], labels: ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7']),
      'year': ChartDataset(total: 'SAR 18,900', values: [40, 50, 45, 70, 60, 80, 90], labels: ['J', 'F', 'M', 'A', 'M', 'J', 'J']),
    },
    sectionTitle: 'Upcoming',
    cards: const [
      UpcomingCardData(tag: 'TOMORROW', icon: '🩺', title: 'Wellness check-up', subtitle: 'Dr. Nadia Al-Farsi · 4:30 PM'),
      UpcomingCardData(tag: 'FRI, JUL 10', icon: '✂️', title: 'Grooming session', subtitle: 'Nice Grooming · 11:00 AM'),
      UpcomingCardData(tag: 'MON, JUL 13', icon: '💉', title: 'Vaccination', subtitle: 'City Vet Clinic · 9:15 AM'),
    ],
    fabActions: const [
      FabActionData(label: 'Add a pet', icon: CupertinoIcons.paw),
      FabActionData(label: 'Book a service', icon: CupertinoIcons.calendar),
    ],
  ),

  'volunteer': RoleDashboardConfig(
    title: 'Volunteer Hub',
    subtitle: 'Shifts & impact',
    greeting: 'Welcome back',
    name: 'Sara 🤝',
    accent: kHighlight,
    accentDark: const Color(0xFFC9821A),
    accentGlow: kHighlightGlow,
    heroGradient: const [Color(0xFF0B1E5B), Color(0xFF40361B), Color(0xFF6B4E12)],
    rings: const [
      RingData(color: kHighlight, pct: 62, label: 'Monthly hours goal'),
      RingData(color: kAccentTeal, pct: 88, label: 'Shift reliability'),
      RingData(color: kCoral, pct: 35, label: 'Badge progress'),
    ],
    widgets: const [
      WidgetCardData(bg: kAccentTeal, fg: Color(0xFF04372F), title: 'Hours served', value: '34 hrs', sub: 'This month'),
      WidgetCardData(bg: CupertinoColors.white, fg: kInk, title: 'Next shift', value: 'Dog walking', sub: 'Sat, 8:00 AM', solid: false),
    ],
    chartLabel: 'Hours volunteered',
    chartSub: 'Total hours',
    datasets: const {
      'week': ChartDataset(total: '9 hrs', values: [20, 0, 40, 60, 30, 90, 10], labels: ['M', 'T', 'W', 'T', 'F', 'S', 'S']),
      'month': ChartDataset(total: '34 hrs', values: [50, 40, 60, 30, 70, 55, 45], labels: ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7']),
      'year': ChartDataset(total: '286 hrs', values: [30, 45, 50, 60, 70, 65, 80], labels: ['J', 'F', 'M', 'A', 'M', 'J', 'J']),
    },
    sectionTitle: 'Upcoming shifts',
    cards: const [
      UpcomingCardData(tag: 'SAT, JUL 11', icon: '🐕', title: 'Dog walking shift', subtitle: 'Riyadh Shelter · 8:00 AM'),
      UpcomingCardData(tag: 'SUN, JUL 12', icon: '🧹', title: 'Kennel cleaning', subtitle: 'Riyadh Shelter · 10:00 AM'),
      UpcomingCardData(tag: 'WED, JUL 15', icon: '🎉', title: 'Adoption event', subtitle: 'City Park · 2:00 PM'),
    ],
    fabActions: const [
      FabActionData(label: 'Find a shift', icon: CupertinoIcons.search),
      FabActionData(label: 'Log hours', icon: CupertinoIcons.pencil),
    ],
  ),

  'shelter': RoleDashboardConfig(
    title: 'Shelter Operations',
    subtitle: 'Care, housing & intake',
    greeting: 'Good morning',
    name: 'Team dashboard 🏠',
    accent: kAccentTeal,
    accentDark: const Color(0xFF0D9488),
    accentGlow: kAccentTealGlow,
    heroGradient: const [Color(0xFF0B1E5B), Color(0xFF0F3A46), Color(0xFF0D6E63)],
    rings: const [
      RingData(color: kAccentTeal, pct: 64, label: 'Kennel capacity'),
      RingData(color: kHighlight, pct: 81, label: 'Adoption rate'),
      RingData(color: kCoral, pct: 53, label: 'Vaccination compliance'),
    ],
    widgets: const [
      WidgetCardData(bg: kCoral, fg: Color(0xFF4A0A0A), title: 'Urgent care', value: '3 animals', sub: 'Need attention today'),
      WidgetCardData(bg: CupertinoColors.white, fg: kInk, title: 'Next intake', value: '2 animals', sub: 'Arriving 3:00 PM', solid: false),
    ],
    chartLabel: 'Intake vs. outcomes',
    chartSub: 'Net change',
    datasets: const {
      'week': ChartDataset(total: '+4 animals', values: [40, 60, 30, 70, 50, 90, 45], labels: ['M', 'T', 'W', 'T', 'F', 'S', 'S']),
      'month': ChartDataset(total: '+18 animals', values: [50, 45, 65, 55, 70, 60, 80], labels: ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7']),
      'year': ChartDataset(total: '+142 animals', values: [45, 50, 60, 55, 70, 75, 85], labels: ['J', 'F', 'M', 'A', 'M', 'J', 'J']),
    },
    sectionTitle: 'Needs attention',
    cards: const [
      UpcomingCardData(tag: 'URGENT', icon: '🩺', title: 'Milo — post-op check', subtitle: 'Kennel 12 · Due 2:00 PM'),
      UpcomingCardData(tag: 'TODAY', icon: '💉', title: 'Vaccination batch', subtitle: '6 animals · Kennel block B'),
      UpcomingCardData(tag: 'TOMORROW', icon: '🏡', title: 'Foster hand-off', subtitle: 'Bella → Al-Otaibi family'),
    ],
    fabActions: const [
      FabActionData(label: 'Add animal', icon: CupertinoIcons.add),
      FabActionData(label: 'New task', icon: CupertinoIcons.list_bullet),
    ],
  ),

  'shop': RoleDashboardConfig(
    title: 'Shop Owner',
    subtitle: 'Commerce & inventory',
    greeting: 'Good morning',
    name: 'Zoovana Pet Store 🏬',
    accent: const Color(0xFF6C8EF5),
    accentDark: const Color(0xFF3B5BD9),
    accentGlow: const Color(0xFFE7ECFB),
    heroGradient: const [Color(0xFF0B1E5B), Color(0xFF122A6E), Color(0xFF1E3A8A)],
    rings: const [
      RingData(color: kAccentTeal, pct: 71, label: 'Monthly revenue goal'),
      RingData(color: kHighlight, pct: 38, label: 'Inventory health'),
      RingData(color: kCoral, pct: 95, label: 'Order fulfillment'),
    ],
    widgets: const [
      WidgetCardData(bg: kHighlight, fg: Color(0xFF5C3D06), title: 'Low stock', value: '5 items', sub: 'Reorder soon'),
      WidgetCardData(bg: CupertinoColors.white, fg: kInk, title: 'Pending orders', value: '8 orders', sub: 'Ship by tomorrow', solid: false),
    ],
    chartLabel: 'Revenue overview',
    chartSub: 'Total revenue',
    datasets: const {
      'week': ChartDataset(total: 'SAR 4,120', values: [35, 50, 45, 80, 60, 95, 55], labels: ['M', 'T', 'W', 'T', 'F', 'S', 'S']),
      'month': ChartDataset(total: 'SAR 16,900', values: [50, 55, 60, 75, 65, 80, 90], labels: ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7']),
      'year': ChartDataset(total: 'SAR 198,000', values: [45, 50, 55, 65, 70, 80, 88], labels: ['J', 'F', 'M', 'A', 'M', 'J', 'J']),
    },
    sectionTitle: 'Recent orders',
    cards: const [
      UpcomingCardData(tag: 'NEW', icon: '🛒', title: 'Order #4821', subtitle: '2 items · SAR 240'),
      UpcomingCardData(tag: 'PACKED', icon: '📦', title: 'Order #4818', subtitle: '1 item · SAR 95'),
      UpcomingCardData(tag: 'SHIPPED', icon: '🚚', title: 'Order #4810', subtitle: '4 items · SAR 610'),
    ],
    fabActions: const [
      FabActionData(label: 'Add product', icon: CupertinoIcons.tag),
      FabActionData(label: 'New order', icon: CupertinoIcons.doc_text),
    ],
  ),

  'provider': RoleDashboardConfig(
    title: 'Service Provider',
    subtitle: 'Bookings & earnings',
    greeting: 'Good morning',
    name: 'Nice Grooming ✂️',
    accent: kCoral,
    accentDark: const Color(0xFFE14848),
    accentGlow: kCoralGlow,
    heroGradient: const [Color(0xFF0B1E5B), Color(0xFF3E1B2E), Color(0xFF7A1F2B)],
    rings: const [
      RingData(color: kHighlight, pct: 96, label: 'Client rating'),
      RingData(color: kAccentTeal, pct: 84, label: 'Response rate'),
      RingData(color: kCoral, pct: 57, label: 'Monthly bookings goal'),
    ],
    widgets: const [
      WidgetCardData(bg: kAccentTeal, fg: Color(0xFF04372F), title: 'Profile rating', value: '4.9 ⭐', sub: '128 reviews'),
      WidgetCardData(bg: CupertinoColors.white, fg: kInk, title: 'Next booking', value: 'Grooming', sub: 'Today, 3:00 PM', solid: false),
    ],
    chartLabel: 'Earnings overview',
    chartSub: 'Total earned',
    datasets: const {
      'week': ChartDataset(total: 'SAR 1,860', values: [40, 60, 35, 85, 55, 90, 50], labels: ['M', 'T', 'W', 'T', 'F', 'S', 'S']),
      'month': ChartDataset(total: 'SAR 7,240', values: [50, 60, 55, 80, 65, 75, 90], labels: ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7']),
      'year': ChartDataset(total: 'SAR 84,600', values: [45, 55, 50, 65, 70, 78, 88], labels: ['J', 'F', 'M', 'A', 'M', 'J', 'J']),
    },
    sectionTitle: 'Upcoming bookings',
    cards: const [
      UpcomingCardData(tag: 'TODAY', icon: '✂️', title: 'Full groom — Max', subtitle: '3:00 PM · 45 min'),
      UpcomingCardData(tag: 'TOMORROW', icon: '🛁', title: 'Bath & trim — Luna', subtitle: '10:30 AM · 30 min'),
      UpcomingCardData(tag: 'FRI, JUL 10', icon: '✂️', title: 'Full groom — Rocky', subtitle: '1:00 PM · 45 min'),
    ],
    fabActions: const [
      FabActionData(label: 'New service', icon: CupertinoIcons.wrench),
      FabActionData(label: 'Availability', icon: CupertinoIcons.calendar_today),
    ],
  ),
};
