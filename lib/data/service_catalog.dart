/// In-app service catalog (UI assets + filters). Persisted selections use [UserFields.services].
class ServiceCatalog {
  ServiceCatalog._();

  static const String cleaning = 'Cleaning';
  static const String cooking = 'Cooking';
  static const String laundry = 'Laundry';
  static const String elderCare = 'Elder-care';
  static const String babysitter = 'Babysitter';
  static const String allRounder = 'All-rounder';

  static const List<ServiceDefinition> all = [
    ServiceDefinition(
      id: cleaning,
      title: cleaning,
      imageAsset: 'assets/dashboard_images/cleaning_icon.png',
    ),
    ServiceDefinition(
      id: cooking,
      title: cooking,
      imageAsset: 'assets/dashboard_images/cooking_icon.jpg',
    ),
    ServiceDefinition(
      id: laundry,
      title: laundry,
      imageAsset: 'assets/dashboard_images/laundry_icon.png',
      comingSoon: true,
    ),
    ServiceDefinition(
      id: elderCare,
      title: elderCare,
      imageAsset: 'assets/dashboard_images/elder_care_icon.png',
      comingSoon: true,
    ),
    ServiceDefinition(
      id: babysitter,
      title: babysitter,
      imageAsset: 'assets/dashboard_images/baby_sitter_icon.png',
      comingSoon: true,
    ),
    ServiceDefinition(
      id: allRounder,
      title: allRounder,
      imageAsset: 'assets/dashboard_images/all_rounder_icon.png',
      comingSoon: true,
    ),
  ];

  static Set<String> get comingSoonTitles => {
    for (final s in all)
      if (s.comingSoon) s.title,
  };

  static ServiceDefinition? byTitle(String title) {
    for (final s in all) {
      if (s.title == title) return s;
    }
    return null;
  }

  static bool isComingSoon(String title) => comingSoonTitles.contains(title);

  /// Instant booking tab: only active services (no coming-soon).
  static List<ServiceDefinition> get instantBookable => [
    byTitle(cleaning)!,
    byTitle(cooking)!,
  ];
}

class ServiceDefinition {
  const ServiceDefinition({
    required this.id,
    required this.title,
    required this.imageAsset,
    this.comingSoon = false,
  });

  final String id;
  final String title;
  final String imageAsset;
  final bool comingSoon;

  Map<String, String> toGridItem() => {'name': title, 'image': imageAsset};

  Map<String, String> toTitleImage() => {'title': title, 'image': imageAsset};
}
