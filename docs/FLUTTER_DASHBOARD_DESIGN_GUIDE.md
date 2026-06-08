# Flutter Mobile App - Dashboard Design Guide

## Overview
This guide shows how to adapt Zoovana's web dashboard(s) into Flutter mobile app with proper mobile UX patterns and state management.

---

## Website Dashboard Structure

The website has **multiple role-based dashboards**:

### 1. **Pet Owner Dashboard**
- Overview (stats, charts)
- My Pets (list & management)
- Find Services
- Service Bookings
- Messages/Chat
- Reviews

### 2. **Shop Owner Dashboard**
- Overview (sales, revenue)
- Shop Management
- Categories
- Products
- Marketplace Orders
- Invoices
- Suppliers
- Inventory

### 3. **Shelter Owner Dashboard**
- Overview (statistics & charts)
- Shelters (list & management)
- Animals (list & details)
- Medical Records
- Vaccinations & Kennels
- Adoption Applications
- Volunteers
- Donations
- Lost & Found
- Animal Care Logs

### 4. **Volunteer Dashboard**
- My Shifts (upcoming, history)
- Apply to Shelters
- Shift check-in/check-out

### 5. **Provider Dashboard**
- Services
- Bookings
- Reviews
- Earnings

### 6. **Livestock Owner Dashboard**
- Animals Management
- Health Tracking
- Marketplace Orders

---

## Mobile Dashboard Design Approach

### Key Principles
- **Single column vertical scroll** instead of complex layouts
- **Bottom Tab Navigation** (3-5 main tabs) instead of side menu
- **Card-based layout** for statistics and actions
- **Swipeable tabs** for quick navigation between related data
- **Minimalist charts** (simplified, mobile-friendly)
- **Floating action buttons** for primary actions
- **Collapsible sections** instead of multiple pages

---

## Recommended Folder Structure

```
lib/
├── features/
│   ├── dashboard/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── dashboard_model.dart
│   │   │   │   ├── stat_card_model.dart
│   │   │   │   └── chart_data_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── dashboard_repository.dart
│   │   │   └── services/
│   │   │       └── dashboard_service.dart
│   │   ├── presentation/
│   │   │   ├── controllers/
│   │   │   │   └── dashboard_controller.dart
│   │   │   ├── pages/
│   │   │   │   ├── pet_owner_dashboard.dart
│   │   │   │   ├── shop_owner_dashboard.dart
│   │   │   │   ├── shelter_owner_dashboard.dart
│   │   │   │   └── volunteer_dashboard.dart
│   │   │   └── widgets/
│   │   │       ├── dashboard_header.dart
│   │   │       ├── stat_card.dart
│   │   │       ├── overview_card.dart
│   │   │       ├── simple_line_chart.dart
│   │   │       ├── simple_pie_chart.dart
│   │   │       ├── action_button_group.dart
│   │   │       └── bottom_nav_bar.dart
│   │   └── bindings/
│   │       └── dashboard_binding.dart
│   │
│   ├── pet_owner/
│   │   ├── my_pets/
│   │   ├── bookings/
│   │   ├── services/
│   │   ├── messages/
│   │   └── reviews/
│   │
│   ├── shelter_owner/
│   │   ├── animals/
│   │   ├── medical/
│   │   ├── vaccinations/
│   │   ├── adoptions/
│   │   ├── volunteers/
│   │   └── donations/
│   │
│   ├── shop_owner/
│   │   ├── products/
│   │   ├── orders/
│   │   ├── invoices/
│   │   └── inventory/
│   │
│   └── volunteer/
│       ├── shifts/
│       └── applications/
```

---

## Part 1: Dashboard Header Component

```dart
// dashboard_header.dart
class DashboardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? userRole;
  final String? userName;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onLogoutPressed;

  const DashboardHeader({
    required this.title,
    this.subtitle,
    this.userRole,
    this.userName,
    this.onSettingsPressed,
    this.onProfilePressed,
    this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002169),
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 20),
                          SizedBox(width: 12),
                          Text('Profile'),
                        ],
                      ),
                      onTap: onProfilePressed,
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.settings, size: 20),
                          SizedBox(width: 12),
                          Text('Settings'),
                        ],
                      ),
                      onTap: onSettingsPressed,
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Logout', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      onTap: onLogoutPressed,
                    ),
                  ],
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.more_vert,
                      color: Color(0xFF002169),
                    ),
                  ),
                ),
              ],
            ),
            if (userName != null || userRole != null)
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFF0F9FF),
                      child: Text(
                        (userName?.isNotEmpty ?? false) ? userName![0].toUpperCase() : '?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002169),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName ?? 'User',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (userRole != null)
                          Text(
                            userRole!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

---

## Part 2: Statistics Card Component

```dart
// stat_card.dart
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? trend; // "+5 this week"
  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const StatCard({
    required this.label,
    required this.value,
    this.trend,
    required this.icon,
    required this.color,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  if (trend != null)
                    Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        trend!,
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: backgroundColor ?? color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Part 3: Simple Line Chart for Mobile

```dart
// simple_line_chart.dart
import 'package:fl_chart/fl_chart.dart';

class SimpleLineChart extends StatelessWidget {
  final String title;
  final List<ChartDataPoint> data;
  final Color lineColor;
  final String? yAxisLabel;

  const SimpleLineChart({
    required this.title,
    required this.data,
    required this.lineColor,
    this.yAxisLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text('No data available', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(enabled: false),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.length) return SizedBox();
                        return Text(
                          data[index].label,
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.value.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: lineColor,
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: lineColor.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartDataPoint {
  final String label;
  final double value;

  ChartDataPoint({required this.label, required this.value});
}
```

---

## Part 4: Simple Pie Chart for Mobile

```dart
// simple_pie_chart.dart
import 'package:fl_chart/fl_chart.dart';

class SimplePieChart extends StatelessWidget {
  final String title;
  final List<PieChartData> data;
  final String? centerText;

  const SimplePieChart({
    required this.title,
    required this.data,
    this.centerText,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Center(child: Text('No data available')),
          ],
        ),
      );
    }

    final total = data.fold<double>(0, (sum, item) => sum + item.value);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: data.asMap().entries.map((entry) {
                  final percentage = (entry.value.value / total) * 100;
                  return PieChartSectionData(
                    color: entry.value.color,
                    value: entry.value.value,
                    title: '${percentage.toStringAsFixed(0)}%',
                    radius: 40,
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                }).toList(),
                centerSpaceRadius: 30,
                sectionsSpace: 2,
              ),
            ),
          ),
          SizedBox(height: 16),
          // Legend
          Column(
            children: data.map((item) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    Text(
                      item.value.toInt().toString(),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class PieChartData {
  final String label;
  final double value;
  final Color color;

  PieChartData({
    required this.label,
    required this.value,
    required this.color,
  });
}
```

---

## Part 5: Pet Owner Dashboard Implementation

```dart
// pet_owner_dashboard.dart
class PetOwnerDashboard extends GetView<DashboardController> {
  const PetOwnerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F9FF),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(180),
        child: DashboardHeader(
          title: 'Pet Care Hub',
          subtitle: 'Manage your pets & services',
          userName: controller.userName.value,
          userRole: 'Pet Owner',
          onProfilePressed: () => Get.toNamed('/profile'),
          onSettingsPressed: () => Get.toNamed('/settings'),
          onLogoutPressed: () => controller.logout(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Stats Cards (2-column grid)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  StatCard(
                    label: 'My Pets',
                    value: controller.petCount.value.toString(),
                    icon: Icons.pets,
                    color: Colors.blue,
                    trend: '+1 this month',
                    onTap: () => Get.toNamed('/pets'),
                  ),
                  StatCard(
                    label: 'Upcoming Books',
                    value: controller.upcomingBookings.value.toString(),
                    icon: Icons.calendar_today,
                    color: Colors.green,
                    onTap: () => Get.toNamed('/bookings'),
                  ),
                  StatCard(
                    label: 'Messages',
                    value: controller.unreadMessages.value.toString(),
                    icon: Icons.message,
                    color: Colors.orange,
                    onTap: () => Get.toNamed('/messages'),
                  ),
                  StatCard(
                    label: 'Favorites',
                    value: controller.favoriteServices.value.toString(),
                    icon: Icons.favorite,
                    color: Colors.red,
                    onTap: () => Get.toNamed('/favorites'),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Quick Actions
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Get.toNamed('/add-pet'),
                            icon: Icon(Icons.add),
                            label: Text('Add Pet'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Get.toNamed('/find-services'),
                            icon: Icon(Icons.search),
                            label: Text('Services'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Activity Chart
              SimpleLineChart(
                title: 'Booking Activity (Last 6 Months)',
                data: controller.activityChartData,
                lineColor: Colors.blue,
              ),

              SizedBox(height: 20),

              // Services Distribution Pie Chart
              SimplePieChart(
                title: 'Services Used',
                data: controller.servicesDistribution,
              ),

              SizedBox(height: 20),

              // Recent Pets
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Pets',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed('/pets'),
                          child: Text('View All'),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    ...controller.recentPets.map((pet) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: _PetListItem(pet: pet),
                      );
                    }).toList(),
                  ],
                ),
              ),

              SizedBox(height: 30),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-pet'),
        backgroundColor: Color(0xFF002169),
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Obx(
      () => BottomNavigationBar(
        currentIndex: controller.activeTabIndex.value,
        onTap: (index) {
          controller.activeTabIndex.value = index;
          final routes = ['/dashboard', '/pets', '/services', '/bookings', '/messages'];
          Get.toNamed(routes[index]);
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Pets'),
          BottomNavigationBarItem(icon: Icon(Icons.spa), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
        ],
      ),
    );
  }
}

class _PetListItem extends StatelessWidget {
  final PetModel pet;

  const _PetListItem({required this.pet});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/pet/${pet.id}'),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(pet.imageUrl),
            onBackgroundImageError: (_, __) {},
            backgroundColor: Colors.grey[200],
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${pet.breed} • ${pet.age}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
```

---

## Part 6: Shelter Owner Dashboard Implementation

```dart
// shelter_owner_dashboard.dart
class ShelterOwnerDashboard extends GetView<ShelterDashboardController> {
  const ShelterOwnerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F9FF),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(220),
        child: Column(
          children: [
            DashboardHeader(
              title: 'Shelter Management',
              subtitle: 'Manage animals, adoptions & operations',
              userRole: 'Shelter Owner',
              onProfilePressed: () => Get.toNamed('/profile'),
              onLogoutPressed: () => controller.logout(),
            ),
            // Shelter Selector Dropdown
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Obx(() {
                return DropdownButton<String>(
                  isExpanded: true,
                  value: controller.selectedShelterId.value,
                  items: controller.shelters.map((shelter) {
                    return DropdownMenuItem(
                      value: shelter.id,
                      child: Text(shelter.name),
                    );
                  }).toList(),
                  onChanged: (id) {
                    if (id != null) {
                      controller.selectShelter(id);
                    }
                  },
                );
              }),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Overview Stats (5-column grid → 2 columns on mobile)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  StatCard(
                    label: 'Total Animals',
                    value: controller.totalAnimals.value.toString(),
                    icon: Icons.pets,
                    color: Colors.green,
                    trend: '+${controller.animalsThisWeek.value} this week',
                    onTap: () => Get.toNamed('/animals'),
                  ),
                  StatCard(
                    label: 'Adoptions',
                    value: controller.adoptionCount.value.toString(),
                    icon: Icons.favorite,
                    color: Colors.red,
                    onTap: () => Get.toNamed('/adoptions'),
                  ),
                  StatCard(
                    label: 'Kennels',
                    value: controller.kennelCount.value.toString(),
                    icon: Icons.home,
                    color: Colors.orange,
                    onTap: () => Get.toNamed('/kennels'),
                  ),
                  StatCard(
                    label: 'Volunteers',
                    value: controller.volunteerCount.value.toString(),
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: () => Get.toNamed('/volunteers'),
                  ),
                  StatCard(
                    label: 'Medical Records',
                    value: controller.medicalCount.value.toString(),
                    icon: Icons.medical_services,
                    color: Colors.purple,
                    onTap: () => Get.toNamed('/medical'),
                  ),
                  StatCard(
                    label: 'Donations',
                    value: '\$${controller.donationTotal.value}',
                    icon: Icons.favorite_border,
                    color: Colors.pink,
                    onTap: () => Get.toNamed('/donations'),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Quick Actions
              _buildQuickActionsSection(),

              SizedBox(height: 20),

              // Revenue Chart
              SimpleLineChart(
                title: 'Revenue (Last 6 Months)',
                data: controller.revenueChartData,
                lineColor: Colors.green,
              ),

              SizedBox(height: 20),

              // Animal Types Distribution
              SimplePieChart(
                title: 'Animals by Species',
                data: controller.speciesDistribution,
              ),

              SizedBox(height: 20),

              // Recent Activities
              _buildRecentActivitiesSection(),

              SizedBox(height: 30),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.5,
            children: [
              _buildActionButton(
                icon: Icons.add,
                label: 'Add Animal',
                onTap: () => Get.toNamed('/add-animal'),
              ),
              _buildActionButton(
                icon: Icons.event,
                label: 'Add Shift',
                onTap: () => Get.toNamed('/add-shift'),
              ),
              _buildActionButton(
                icon: Icons.medical_services,
                label: 'Medical Log',
                onTap: () => Get.toNamed('/medical-log'),
              ),
              _buildActionButton(
                icon: Icons.assignment,
                label: 'Applications',
                onTap: () => Get.toNamed('/applications'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Color(0xFF002169)),
              SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Animals', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => Get.toNamed('/animals'), child: Text('View All')),
            ],
          ),
          SizedBox(height: 12),
          Obx(() {
            return Column(
              children: controller.recentAnimals.map((animal) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: _AnimalListItem(animal: animal),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Obx(
      () => BottomNavigationBar(
        currentIndex: controller.activeTabIndex.value,
        onTap: (index) {
          controller.activeTabIndex.value = index;
          final routes = ['/dashboard', '/animals', '/medical', '/adoptions', '/volunteers'];
          Get.toNamed(routes[index]);
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Animals'),
          BottomNavigationBarItem(icon: Icon(Icons.health_and_safety), label: 'Medical'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Adoptions'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Volunteers'),
        ],
      ),
    );
  }
}

class _AnimalListItem extends StatelessWidget {
  final AnimalModel animal;

  const _AnimalListItem({required this.animal});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/animal/${animal.id}'),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              animal.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 50,
                height: 50,
                color: Colors.grey[200],
                child: Icon(Icons.pets),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(animal.name, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${animal.species} • ${animal.breed}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
```

---

## Part 7: Dashboard Controller (State Management)

```dart
// dashboard_controller.dart
class DashboardController extends GetxController {
  final api = Get.find<ApiClient>();
  
  // Pet Owner Dashboard
  final userName = ''.obs;
  final petCount = 0.obs;
  final upcomingBookings = 0.obs;
  final unreadMessages = 0.obs;
  final favoriteServices = 0.obs;
  final recentPets = <PetModel>[].obs;
  final activityChartData = <ChartDataPoint>[].obs;
  final servicesDistribution = <PieChartData>[].obs;
  
  // Shelter Dashboard
  final totalAnimals = 0.obs;
  final animalsThisWeek = 0.obs;
  final adoptionCount = 0.obs;
  final kennelCount = 0.obs;
  final volunteerCount = 0.obs;
  final medicalCount = 0.obs;
  final donationTotal = '0.00'.obs;
  final recentAnimals = <AnimalModel>[].obs;
  final revenueChartData = <ChartDataPoint>[].obs;
  final speciesDistribution = <PieChartData>[].obs;
  
  final isLoading = false.obs;
  final activeTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      
      // Fetch user info
      final userResponse = await api.get('/users/me');
      if (userResponse.statusCode == 200) {
        userName.value = userResponse.data['full_name'] ?? '';
      }
      
      // Fetch role-specific data
      final role = GetStorage().read('userRole');
      
      if (role == 'pet_owner') {
        await _fetchPetOwnerData();
      } else if (role == 'shelter_owner') {
        await _fetchShelterOwnerData();
      } else if (role == 'shop_owner') {
        await _fetchShopOwnerData();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchPetOwnerData() async {
    final petsResponse = await api.get('/pets?limit=3');
    if (petsResponse.statusCode == 200) {
      petCount.value = petsResponse.data['meta']['total'];
      recentPets.value = List<PetModel>.from(
        (petsResponse.data['data'] as List).map((x) => PetModel.fromJson(x))
      );
    }

    final bookingsResponse = await api.get('/bookings?status=pending');
    if (bookingsResponse.statusCode == 200) {
      upcomingBookings.value = bookingsResponse.data['meta']['total'];
    }

    final messagesResponse = await api.get('/chats/unread');
    if (messagesResponse.statusCode == 200) {
      unreadMessages.value = messagesResponse.data['count'];
    }

    // Mock chart data - replace with real API data
    activityChartData.value = [
      ChartDataPoint(label: 'Jan', value: 2),
      ChartDataPoint(label: 'Feb', value: 3),
      ChartDataPoint(label: 'Mar', value: 5),
      ChartDataPoint(label: 'Apr', value: 4),
      ChartDataPoint(label: 'May', value: 6),
      ChartDataPoint(label: 'Jun', value: 8),
    ];

    servicesDistribution.value = [
      PieChartData(label: 'Grooming', value: 5, color: Colors.blue),
      PieChartData(label: 'Boarding', value: 3, color: Colors.green),
      PieChartData(label: 'Vet', value: 2, color: Colors.orange),
    ];
  }

  Future<void> _fetchShelterOwnerData() async {
    final overviewResponse = await api.get('/shelters/dashboard/overview');
    if (overviewResponse.statusCode == 200) {
      final data = overviewResponse.data;
      totalAnimals.value = data['total_animals'];
      adoptionCount.value = data['adoptions'];
      kennelCount.value = data['kennels'];
      volunteerCount.value = data['volunteers'];
      medicalCount.value = data['medical_records'];
      donationTotal.value = data['donations'].toString();
    }
  }

  Future<void> _fetchShopOwnerData() async {
    // Similar pattern for shop owner
  }

  void logout() {
    Get.offAllNamed('/login');
  }
}
```

---

## Part 8: Key Responsive Design Tips

### Mobile Breakpoints
```dart
// For responsive widgets
bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 600 && 
                                       MediaQuery.of(context).size.width < 1200;
bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;
```

### Adapt Grid Layouts
```dart
// Web: 5 columns, Mobile: 2 columns
int getCrossAxisCount(BuildContext context) {
  if (isDesktop(context)) return 5;
  if (isTablet(context)) return 3;
  return 2; // mobile
}
```

---

## Part 9: Dependencies

```yaml
dependencies:
  # State management
  get: ^4.6.5
  
  # HTTP client
  dio: ^5.1.1
  
  # Charts
  fl_chart: ^0.63.0
  
  # Local storage
  get_storage: ^2.1.1
  
  # Animation
  lottie: ^2.7.0
  
  # Image caching
  cached_network_image: ^3.3.1
  
  # Responsive UI
  responsive_builder: ^0.10.0
  
  # Localization
  intl: ^0.18.1
  get_localization: ^3.1.2
```

---

## Part 10: Complete Example with Multiple Dashboards

```dart
// main_dashboard_page.dart - Unified entry point
class MainDashboardPage extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    final role = GetStorage().read('userRole');
    
    if (role == 'pet_owner') {
      return PetOwnerDashboard();
    } else if (role == 'shelter_owner') {
      return ShelterOwnerDashboard();
    } else if (role == 'shop_owner') {
      return ShopOwnerDashboard();
    } else if (role == 'volunteer') {
      return VolunteerDashboard();
    }
    
    return Scaffold(
      body: Center(child: Text('Unknown role')),
    );
  }
}
```

---

## Mobile-First Design Checklist

- ✅ Single-column vertical layout
- ✅ 2-column grid for statistics (not 5)
- ✅ Bottom navigation (3-5 tabs)
- ✅ Floating action button for primary action
- ✅ Collapsible sections for space
- ✅ Mobile-friendly charts (simplified)
- ✅ Large touch targets (min 48x48dp)
- ✅ Readable typography (min 12sp)
- ✅ Proper spacing & padding
- ✅ Loading states & error handling
- ✅ Pull-to-refresh functionality
- ✅ Offline support (cached data)

---

## Color Scheme (Matching Your Brand)

```dart
const Color kPrimaryColor = Color(0xFF002169); // Dark Blue
const Color kLightBgColor = Color(0xFFF0F9FF); // Light Blue
const Color kSuccessColor = Color(0xFF10B981); // Green
const Color kWarningColor = Color(0xFFF59E0B); // Orange
const Color kErrorColor = Color(0xFFEF4444); // Red
const Color kInfoColor = Color(0xFF3B82F6); // Blue
```

---

## Performance Optimization

1. **Lazy Loading**: Only load visible sections initially
2. **Image Caching**: Use `cached_network_image`
3. **Pagination**: Limit initial data load
4. **Debouncing**: Delay API calls during interactions
5. **State Management**: Use GetX for reactive updates
6. **Skeleton Loaders**: Show shimmer effect during load

This design maintains your brand identity while optimizing for mobile user experience!
