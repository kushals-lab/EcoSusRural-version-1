/// Certification badge types aligned with the EcoSusRural trust system.
enum CertificationBadge { giCertified, sustainabilityVerified, handicraftVerified, organicCertified, labTested }

class ProductModel {
  final String id;
  final String title;
  final String description;
  final double priceInr;
  final String category;
  final String state;
  final String makerName;
  final String makerVillage;
  final List<CertificationBadge> badges;
  final double rating;
  final int reviewCount;
  final String impactStory;
  final bool isOrganic;
  final bool isHandicraft;
  final bool isGiTagged;
  final bool isBiodegradable;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priceInr,
    required this.category,
    required this.state,
    required this.makerName,
    required this.makerVillage,
    this.badges = const [],
    this.rating = 4.5,
    this.reviewCount = 0,
    this.impactStory = '',
    this.isOrganic = false,
    this.isHandicraft = false,
    this.isGiTagged = false,
    this.isBiodegradable = false,
  });

  String get badgeLabel {
    final labels = <String>[];
    if (badges.contains(CertificationBadge.giCertified)) labels.add('GI Certified');
    if (badges.contains(CertificationBadge.sustainabilityVerified)) labels.add('Sustainability Verified');
    if (badges.contains(CertificationBadge.handicraftVerified)) labels.add('Handicraft Verified');
    if (badges.contains(CertificationBadge.organicCertified)) labels.add('Organic Certified');
    if (badges.contains(CertificationBadge.labTested)) labels.add('Lab Tested');
    return labels.join(' • ');
  }
}

/// Curated sample catalog of verified rural products.
const List<ProductModel> kSampleProducts = [
  ProductModel(
    id: 'p1',
    title: 'Banarasi Silk Saree',
    description:
        'Handwoven by master weavers of Varanasi, this Banarasi silk saree features intricate gold zari '
        'work. Each saree takes 15-20 days to complete and supports an entire family of weavers.',
    priceInr: 12500,
    category: 'Handlooms',
    state: 'Uttar Pradesh',
    makerName: 'Kailash Weavers Collective',
    makerVillage: 'Varanasi',
    badges: [CertificationBadge.giCertified, CertificationBadge.handicraftVerified],
    rating: 4.9,
    reviewCount: 128,
    impactStory:
        'The Kailash Weavers Collective supports 45 artisan families. Every purchase funds a child\'s '
        'schooling and preserves the 500-year-old Banarasi weaving tradition.',
    isHandicraft: true,
    isGiTagged: true,
  ),
  ProductModel(
    id: 'p2',
    title: 'Organic A2 Gir Cow Ghee',
    description:
        'Pure A2 ghee made by the traditional bilona method from free-grazing Gir cows. Lab-tested for '
        'purity, no preservatives, no adulteration.',
    priceInr: 1850,
    category: 'Organic Produce',
    state: 'Gujarat',
    makerName: 'Shree Gir Organic Farms',
    makerVillage: 'Amreli',
    badges: [CertificationBadge.organicCertified, CertificationBadge.labTested, CertificationBadge.sustainabilityVerified],
    rating: 4.8,
    reviewCount: 342,
    impactStory:
        'Shree Gir Organic Farms works with 60 smallholder families, providing premium prices for ethical '
        'dairy farming and funding the preservation of indigenous Gir cattle.',
    isOrganic: true,
  ),
  ProductModel(
    id: 'p3',
    title: 'Chikankari Hand-Embroidered Kurta',
    description:
        'Exquisite Lucknowi Chikankari embroidery on soft cotton. Each piece is hand-embroidered by '
        'artisans using the traditional needlework technique passed down generations.',
    priceInr: 2450,
    category: 'Handicrafts',
    state: 'Uttar Pradesh',
    makerName: 'Zari Chikan Guild',
    makerVillage: 'Lucknow',
    badges: [CertificationBadge.handicraftVerified, CertificationBadge.giCertified],
    rating: 4.7,
    reviewCount: 96,
    impactStory:
        'The Zari Chikan Guild empowers 200+ women artisans from Lucknow\'s old city, offering fair wages '
        'and free skill-training programs.',
    isHandicraft: true,
    isGiTagged: true,
  ),
  ProductModel(
    id: 'p4',
    title: 'Naga King Chilli Pickle',
    description:
        'Fiery King Chilli (Raja Mircha) pickle from Nagaland, made with traditional fermented recipes. '
        'FSSAI-certified and lab-tested for quality.',
    priceInr: 425,
    category: 'Processed Foods',
    state: 'Nagaland',
    makerName: 'Naga Hills Agri Co',
    makerVillage: 'Kohima',
    badges: [CertificationBadge.labTested, CertificationBadge.sustainabilityVerified],
    rating: 4.6,
    reviewCount: 210,
    impactStory:
        'Naga Hills Agri Co sources from tribal farmers in the remote hills, providing a fair market and '
        'reducing post-harvest losses.',
  ),
  ProductModel(
    id: 'p5',
    title: 'Terracotta Handmade Pottery Set',
    description:
        'Hand-thrown terracotta pots and serving sets from the traditional potters of Molela, Rajasthan. '
        'Each piece is unique, fired in traditional kilns, and food-safe.',
    priceInr: 1350,
    category: 'Pottery & Ceramics',
    state: 'Rajasthan',
    makerName: 'Molela Terracotta Karkhana',
    makerVillage: 'Molela',
    badges: [CertificationBadge.handicraftVerified],
    rating: 4.8,
    reviewCount: 74,
    impactStory:
        'Molela potters have been crafting terracotta for 300 years. Your purchase preserves a dying art '
        'form and supports 30 artisan families.',
    isHandicraft: true,
  ),
  ProductModel(
    id: 'p6',
    title: 'Kashmiri Saffron (Kesar)',
    description:
        'Premium Kashmiri Mongra saffron, GI-tagged, hand-harvested from Pampore fields. High crocin '
        'content and lab-verified purity.',
    priceInr: 3200,
    category: 'Spices',
    state: 'Jammu & Kashmir',
    makerName: 'Pampore Saffron Growers',
    makerVillage: 'Pampore',
    badges: [CertificationBadge.giCertified, CertificationBadge.labTested],
    rating: 4.9,
    reviewCount: 187,
    impactStory:
        'Pampore Saffron Growers cooperative represents 300+ farming families in the saffron bowl of India, '
        'preserving the world\'s finest saffron.',
    isGiTagged: true,
  ),
  // Biodegradable aisle: compostable / plastic-free, GI or not.
  ProductModel(
    id: 'p7',
    title: 'Compostable Areca Leaf Plates (25 pc)',
    description:
        'Fallen areca-palm leaf plates, heat-pressed without chemicals. Fully compostable in 60 days; '
        'no plastic lining, no GI tag needed.',
    priceInr: 349,
    category: 'Biodegradable',
    state: 'Karnataka',
    makerName: 'Shimoga LeafWorks',
    makerVillage: 'Shimoga',
    badges: [CertificationBadge.sustainabilityVerified],
    rating: 4.7,
    reviewCount: 158,
    impactStory:
        'LeafWorks employs 40 rural women pressing fallen leaves into export-grade tableware.',
    isBiodegradable: true,
  ),
  ProductModel(
    id: 'p8',
    title: 'Jute Market Tote + Vegetable Bags (set of 4)',
    description:
        'Hand-stitched jute tote with 3 cotton-mesh vegetable bags. Replaces ~500 plastic bags a year; '
        'biodegrades fully at end of life.',
    priceInr: 499,
    category: 'Biodegradable',
    state: 'West Bengal',
    makerName: 'Nadia Jute Collective',
    makerVillage: 'Nadia',
    badges: [CertificationBadge.sustainabilityVerified],
    rating: 4.8,
    reviewCount: 203,
    impactStory:
        'Nadia jute farmers + tailoring SHGs share every rupee of margin.',
    isBiodegradable: true,
  ),
  ProductModel(
    id: 'p9',
    title: 'Bamboo Toothbrush (pack of 4)',
    description:
        'Moso-bamboo handle, BPA-free bristles. Plastic-free daily essential; '
        'handle composts, heads recycled via take-back.',
    priceInr: 199,
    category: 'Biodegradable',
    state: 'Assam',
    makerName: 'Brahmaputra Bamboo Co',
    makerVillage: 'Dhemaji',
    badges: [
      CertificationBadge.sustainabilityVerified,
      CertificationBadge.labTested
    ],
    rating: 4.6,
    reviewCount: 311,
    impactStory:
        'Bamboo grown on degraded riverbanks; every pack funds bank-stabilisation planting.',
    isBiodegradable: true,
  ),
];

const List<String> kProductCategories = [
  'All',
  'Handlooms',
  'Handicrafts',
  'Pottery & Ceramics',
  'Organic Produce',
  'Spices',
  'Processed Foods',
  'Biodegradable',
  'Jewellery',
  'Woodwork',
  'Metalwork',
];
