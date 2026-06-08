# Flutter Mobile App - Home Screen Design Guide

## Overview
This guide shows how to adapt the Zoovana website's home page into a Flutter mobile app with proper mobile UX patterns.

---

## Current Website Structure
The website home page consists of:
1. **Hero Section** - Full-height banner with title, subtitle, and CTA
2. **About Section** - Image + text layout
3. **Marquee Section** - Scrolling content showcase
4. **Services Section** - Service cards with blob shapes
5. **AdoptPet Section** - Pet cards grid with images
6. **Join Section** - Call-to-action section
7. **Footer** - Navigation and links

---

## Mobile Home Screen Design Strategy

### Layout Approach
For mobile, convert the scrollable page into a **vertical scrolling screen** instead of horizontal sections. Use mobile-optimized patterns:
- **Stack** (vertical scroll) instead of hero + sections
- **Shorter sections** that fit mobile viewport
- **Single-column layout** instead of complex grid layouts
- **Swipeable cards** for horizontal scrolling instead of carousels

---

## Proposed Flutter Home Screen Structure

```
lib/
├── features/
│   └── home/
│       ├── data/
│       │   ├── models/
│       │   │   ├── animal_model.dart
│       │   │   ├── service_model.dart
│       │   │   └── category_model.dart
│       │   ├── repositories/
│       │   │   └── home_repository.dart
│       │   └── services/
│       │       └── home_service.dart
│       ├── presentation/
│       │   ├── controllers/
│       │   │   └── home_controller.dart
│       │   ├── pages/
│       │   │   └── home_page.dart
│       │   └── widgets/
│       │       ├── hero_section.dart
│       │       ├── featured_pets_section.dart
│       │       ├── services_section.dart
│       │       ├── about_section.dart
│       │       ├── categories_section.dart
│       │       └── cta_section.dart
│       └── bindings/
│           └── home_binding.dart
```

---

## Section-by-Section Design

### 1. Hero Section
**Purpose**: Grab attention, introduce the app

**Mobile Implementation**:
```dart
// hero_section.dart
class HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300, // Shorter than web (100vh → 300)
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative shapes (animated)
          Positioned(
            top: 20,
            left: 20,
            child: AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingAnimation.value * 10),
                  child: Image.asset('assets/images/hero_shape.png', width: 60),
                );
              },
            ),
          ),
          
          // Main content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to Zoovana',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002169),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'Find your perfect pet companion',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Get.toNamed('/adopt');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF002169),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text('Get Started →', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

**Key Differences from Web**:
- Height: 300dp (mobile-friendly) vs 100vh (web)
- Single column layout
- Simplified animations (one floating element vs multiple)
- Larger tap targets for buttons

---

### 2. Featured Pets Section (was "AdoptPet")
**Purpose**: Showcase adoptable animals

**Mobile Implementation**:
```dart
// featured_pets_section.dart
class FeaturedPetsSection extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Featured Pets',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          // Horizontal scrollable pet cards
          SizedBox(
            height: 280,
            child: Obx(() => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.featuredPets.length,
              itemBuilder: (context, index) {
                final pet = controller.featuredPets[index];
                return PetCard(pet: pet, index: index);
              },
            )),
          ),
          
          SizedBox(height: 16),
          // "View All" button
          Center(
            child: TextButton(
              onPressed: () => Get.toNamed('/animals'),
              child: Text('View All Pets →'),
            ),
          ),
        ],
      ),
    );
  }
}

class PetCard extends StatelessWidget {
  final AnimalModel pet;
  final int index;

  const PetCard({required this.pet, required this.index});

  @override
  Widget build(BuildContext context) {
    // Alternating corner radius based on index
    final isAlt = index >= 2;
    final BorderRadius borderRadius = isAlt
        ? BorderRadius.only(
            topRight: Radius.circular(80),
            bottomLeft: Radius.circular(80),
            topLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(80),
            bottomRight: Radius.circular(80),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          );

    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with alternating curves
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: isAlt ? Radius.circular(24) : Radius.circular(80),
              topRight: isAlt ? Radius.circular(80) : Radius.circular(24),
            ),
            child: GestureDetector(
              onTap: () => Get.toNamed('/animal/${pet.id}'),
              child: Container(
                height: 150,
                color: Colors.grey[200],
                child: Image.network(
                  pet.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.pets),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF002169),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        pet.location ?? 'Unknown',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

**Key Differences**:
- Vertical scrolling list → Horizontal scrollable cards (swiping pattern)
- Card size: 200dp width (fits mobile viewport)
- Removed grid layout, using ListView
- Tap to view details instead of complex hover states

---

### 3. Services Section
**Purpose**: Showcase app services

**Mobile Implementation**:
```dart
// services_section.dart
class ServicesSection extends StatelessWidget {
  final List<ServiceModel> services = [
    ServiceModel(
      id: '1',
      title: 'Pet Adoption',
      description: 'Find & adopt your perfect companion',
      icon: Icons.pets,
    ),
    ServiceModel(
      id: '2',
      title: 'Pet Care',
      description: 'Expert care guidance & tips',
      icon: Icons.favorite,
    ),
    ServiceModel(
      id: '3',
      title: 'Pet Shop',
      description: 'Quality pet supplies & products',
      icon: Icons.shopping_bag,
    ),
    ServiceModel(
      id: '4',
      title: 'Pet Health',
      description: 'Medical records & vaccination tracking',
      icon: Icons.health_and_safety,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Services',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          // Grid of service cards (2x2 on mobile)
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return ServiceCard(service: services[index]);
            },
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed('/service/${service.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    service.icon,
                    color: Color(0xFF002169),
                    size: 28,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  service.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  service.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**Key Differences**:
- 2x2 grid instead of blob-shaped cards
- Icons instead of custom SVG shapes
- Simpler visual design for mobile

---

### 4. About Section
**Purpose**: Build trust and explain the platform

**Mobile Implementation**:
```dart
// about_section.dart
class AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          // Image on top
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/about_img.png',
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 24),
          
          // Text content below
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About Zoovana',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Zoovana is a comprehensive pet care platform connecting pet lovers with shelters, '
                'veterinarians, and trusted service providers. Our mission is to make pet adoption, '
                'care, and wellness accessible to everyone.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
              SizedBox(height: 16),
              
              // Key stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatCard(label: 'Pets Adopted', value: '5K+'),
                  _StatCard(label: 'Active Shelters', value: '100+'),
                  _StatCard(label: 'Pet Parents', value: '50K+'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF002169),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
```

**Key Differences**:
- Image stacked on top of text (mobile friendly)
- Removed two-column layout
- Added stats display in a row instead of paragraph text

---

### 5. Categories Section (New for Mobile)
**Purpose**: Easy navigation to main sections

```dart
// categories_section.dart
class CategoriesSection extends StatelessWidget {
  final List<CategoryModel> categories = [
    CategoryModel(id: '1', name: 'Adoption', icon: Icons.pets),
    CategoryModel(id: '2', name: 'Health', icon: Icons.health_and_safety),
    CategoryModel(id: '3', name: 'Shop', icon: Icons.shopping_bag),
    CategoryModel(id: '4', name: 'Community', icon: Icons.group),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return CategoryChip(category: categories[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final CategoryModel category;

  const CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed('/category/${category.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  color: Color(0xFF002169),
                  size: 24,
                ),
              ),
              SizedBox(height: 8),
              Text(
                category.name,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### 6. CTA Section (Call-to-Action)
**Purpose**: Encourage user registration/sign-in

```dart
// cta_section.dart
class CTASection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF002169), Color(0xFF003d94)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Join Our Community',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'Connect with pet lovers and expert veterinarians',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.toNamed('/register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Sign Up Now',
                style: TextStyle(
                  color: Color(0xFF002169),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Complete Home Page Implementation

```dart
// home_page.dart
class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Hero Section
              HeroSection(),
              
              // 2. Featured Pets
              Obx(() {
                if (controller.isLoading.value) {
                  return ShimmerLoader();
                }
                return FeaturedPetsSection();
              }),
              
              // 3. Categories
              CategoriesSection(),
              
              // 4. Services
              ServicesSection(),
              
              // 5. About
              AboutSection(),
              
              // 6. CTA
              CTASection(),
              
              // 7. Footer
              Footer(),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Home Controller (State Management)

```dart
// home_controller.dart
class HomeController extends GetxController {
  final HomeRepository _repository = Get.find();
  
  final isLoading = false.obs;
  final featuredPets = <AnimalModel>[].obs;
  final categories = <CategoryModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }
  
  void fetchHomeData() async {
    try {
      isLoading.value = true;
      
      final petsResponse = await _repository.getFeaturedPets();
      final categoriesResponse = await _repository.getCategories();
      
      if (petsResponse.success) {
        featuredPets.value = petsResponse.data;
      }
      
      if (categoriesResponse.success) {
        categories.value = categoriesResponse.data;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load home data');
    } finally {
      isLoading.value = false;
    }
  }
}
```

---

## Key Design Principles

| Aspect | Mobile vs Web |
|--------|--------------|
| **Layout** | Single-column vertical scroll | Multi-section horizontal |
| **Hero Height** | 300dp | 100vh |
| **Cards** | Horizontal swipe (ListView) | Grid layout |
| **Spacing** | Compact (16-24dp) | Generous (32-48px) |
| **Images** | Stacked (full width) | Side-by-side layout |
| **Typography** | Smaller, readable | Larger, dramatic |
| **Sections** | Shorter, focused | Full viewport sections |
| **Navigation** | Bottom nav + drawer | Top nav + sidebar |

---

## Color Scheme (Keep Consistent)
- **Primary**: `#002169` (Dark Blue)
- **Light BG**: `#F0F9FF` (Light Blue)
- **White**: `#FFFFFF`
- **Text**: `#1F2937`
- **Secondary**: `#6B7280`

---

## Recommended Libraries

```yaml
dependencies:
  get: ^4.6.5              # State management & routing
  dio: ^5.1.1              # HTTP client
  cached_network_image: ^3.2.3  # Image caching
  shimmer: ^2.0.0          # Loading animation
  carousel_slider: ^4.2.1  # For horizontal scrolling
  smooth_page_indicator: ^1.0.1  # Carousel indicators
  intl: ^0.18.1            # Internationalization
```

---

## Performance Tips

1. **Lazy Loading**: Only load featured pets (limit to 5-10)
2. **Image Optimization**: Use cached_network_image
3. **Shimmer Loaders**: Show loading state for better UX
4. **Pagination**: Implement on "View All" pages
5. **Debounce**: API calls when filtering
6. **State Management**: Use GetX for reactive updates

---

## Migration Path
1. Start with Hero + Featured Pets sections
2. Add Categories section for quick navigation
3. Implement Services grid
4. Add About section with stats
5. Create CTA section
6. Polish with animations and loading states
7. Add footer with additional links

This structure maintains your brand identity while optimizing for mobile user experience!
