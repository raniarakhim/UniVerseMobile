import 'package:diplomka/housing/models/housing_photos.dart';

class HousingItem {
  const HousingItem({
    required this.id,
    required this.title,
    required this.address,
    required this.price,
    required this.imagePath,
    required this.roomsLabel,
    required this.areaLabel,
    required this.floorLabel,
    required this.amenities,
    required this.about,
    required this.mapAddress,
    required this.latitude,
    required this.longitude,
    required this.ownerName,
    required this.ownerRole,
    this.ownerPhone = '',
    this.ownerTelegram = '',
    this.priceShort = '',
    this.ownerOnline = false,
    this.photoUrls = const [],
  });

  final String id;
  final String title;
  final String address;
  final String price;
  final String imagePath;
  final String roomsLabel;
  final String areaLabel;
  final String floorLabel;
  final List<String> amenities;
  final String about;
  final String mapAddress;
  final double latitude;
  final double longitude;
  final String ownerName;
  final String ownerRole;
  final String ownerPhone;
  final String ownerTelegram;
  final String priceShort;
  final bool ownerOnline;
  final List<String> photoUrls;

  List<String> get galleryPhotos {
    final photos = <String>[];
    if (imagePath.isNotEmpty) photos.add(imagePath);
    for (final url in photoUrls) {
      if (!photos.contains(url)) photos.add(url);
    }
    return photos;
  }

  String get coverPhoto => galleryPhotos.first;

  String get ownerStatus {
    final status = ownerOnline ? 'Online' : 'Offline';
    return '$ownerRole · $status';
  }

  static const studioSksu = HousingItem(
    id: 'studio-sksu',
    title: 'Studio near SKSU',
    address: 'Al-Farabi St, Shymkent',
    price: '₸60,000 /mo',
    imagePath: HousingPhotos.studioLiving,
    roomsLabel: '1 room',
    areaLabel: '32 m²',
    floorLabel: '3rd floor',
    amenities: ['Wi-Fi', 'Furnished', 'Bills incl.', 'Parking'],
    about:
        'Cozy fully furnished studio, 5 min walk from SKSU. Quiet neighborhood, all utilities included. Perfect for students.',
    mapAddress: 'Al-Farabi St 5, Shymkent',
    latitude: 42.3201,
    longitude: 69.5962,
    ownerName: 'Aiman Bekova',
    ownerRole: 'Private landlord',
    ownerPhone: '+7 701 234 5678',
    ownerTelegram: '@aiman_bekova',
    priceShort: '₸60k/mo',
    ownerOnline: true,
    photoUrls: [
      HousingPhotos.studioSofa,
      HousingPhotos.studioCozy,
      HousingPhotos.studioModern,
    ],
  );

  static const roomYufu = HousingItem(
    id: 'room-yufu',
    title: 'Room near YUFU',
    address: 'Tauke Khan Ave, Shymkent',
    price: '₸45,000 /mo',
    imagePath: HousingPhotos.roomBed,
    roomsLabel: '1 room',
    areaLabel: '18 m²',
    floorLabel: '2nd floor',
    amenities: ['1 room', 'Wi-Fi', 'Parking'],
    about: 'Quiet room in a student-friendly building, 8 min walk to YUFU.',
    mapAddress: 'Tauke Khan Ave 88, Shymkent',
    latitude: 42.3184,
    longitude: 69.5918,
    ownerName: 'Marat Zhumabekov',
    ownerRole: 'Private landlord',
    ownerPhone: '+7 702 111 2233',
    priceShort: '₸45k/mo',
    photoUrls: [
      HousingPhotos.roomBright,
      HousingPhotos.roomSimple,
      HousingPhotos.roomDesk,
    ],
  );

  static const apartmentBaitursynov = HousingItem(
    id: 'apt-baitursynov',
    title: 'Apartment Baitursynov',
    address: 'Baitursynov St, Shymkent',
    price: '₸80,000 /mo',
    imagePath: HousingPhotos.aptLiving,
    roomsLabel: '2 rooms',
    areaLabel: '54 m²',
    floorLabel: '5th floor',
    amenities: ['2 rooms', 'Wi-Fi', 'Bills incl.'],
    about: 'Spacious two-room flat with balcony, close to public transport.',
    mapAddress: 'Baitursynov St 21, Shymkent',
    latitude: 42.3123,
    longitude: 69.5841,
    ownerName: 'Gulnara Suleimenova',
    ownerRole: 'Agency',
    ownerPhone: '+7 705 444 5566',
    priceShort: '₸80k/mo',
    photoUrls: [
      HousingPhotos.aptWide,
      HousingPhotos.aptKitchen,
      HousingPhotos.aptDining,
    ],
  );

  static const sharedDorm = HousingItem(
    id: 'dorm-sksu',
    title: 'Shared dorm SKSU',
    address: 'Satpayev St, Shymkent',
    price: '₸35,000 /mo',
    imagePath: HousingPhotos.dormBunksAsset,
    roomsLabel: 'Shared',
    areaLabel: '12 m²',
    floorLabel: '1st floor',
    amenities: ['Shared', 'Wi-Fi', 'Furnished'],
    about: 'Budget shared dormitory for SKSU students, utilities included.',
    mapAddress: 'Satpayev St 14, Shymkent',
    latitude: 42.3278,
    longitude: 69.6009,
    ownerName: 'SKSU Housing Office',
    ownerRole: 'University',
    priceShort: '₸35k/mo',
    photoUrls: [
      HousingPhotos.dormRoom,
      HousingPhotos.dormBeds,
      HousingPhotos.dormHall,
    ],
  );

  static const loftCenter = HousingItem(
    id: 'loft-center',
    title: 'Loft center city',
    address: 'Taalim St, Shymkent',
    price: '₸95,000 /mo',
    imagePath: HousingPhotos.loftLiving,
    roomsLabel: '1 room',
    areaLabel: '40 m²',
    floorLabel: '4th floor',
    amenities: ['1 room', 'Parking', 'Pet friendly'],
    about: 'Modern loft in the city center with high ceilings and open kitchen.',
    mapAddress: 'Taalim St 3, Shymkent',
    latitude: 42.3162,
    longitude: 69.5788,
    ownerName: 'Arman Tulegenov',
    ownerRole: 'Private landlord',
    ownerPhone: '+7 707 999 0011',
    priceShort: '₸95k/mo',
    ownerOnline: true,
    photoUrls: [
      HousingPhotos.loftKitchen,
      HousingPhotos.loftDetail,
      HousingPhotos.loftOpen,
    ],
  );

  static const similarYufu = HousingItem(
    id: 'similar-yufu-2room',
    title: '2-room near YUFU',
    address: 'Tauke Khan Ave, Shymkent',
    price: '₸120,000 /mo',
    imagePath: HousingPhotos.twoRoomLiving,
    roomsLabel: '2 rooms',
    areaLabel: '48 m²',
    floorLabel: '4th floor',
    amenities: ['2 rooms', 'Wi-Fi', 'Parking'],
    about: 'Bright apartment within walking distance of YUFU campus.',
    mapAddress: 'Tauke Khan Ave 12, Shymkent',
    latitude: 42.3192,
    longitude: 69.5895,
    ownerName: 'Dana Nurpeisova',
    ownerRole: 'Private landlord',
    priceShort: '₸120k/mo',
    photoUrls: [
      HousingPhotos.twoRoomBed,
      HousingPhotos.twoRoomView,
    ],
  );

  static const similarAbay = HousingItem(
    id: 'similar-abay-shared',
    title: 'Shared room on Abay',
    address: 'Abay St, Shymkent',
    price: '₸45,000 /mo',
    imagePath: HousingPhotos.sharedBed,
    roomsLabel: 'Shared',
    areaLabel: '14 m²',
    floorLabel: '2nd floor',
    amenities: ['Shared', 'Wi-Fi', 'Furnished'],
    about: 'Affordable shared room for students, utilities included.',
    mapAddress: 'Abay St 44, Shymkent',
    latitude: 42.3098,
    longitude: 69.5746,
    ownerName: 'Ruslan Aitov',
    ownerRole: 'Agency',
    priceShort: '₸45k/mo',
    photoUrls: [
      HousingPhotos.dormBunksAsset,
      HousingPhotos.sharedSmall,
    ],
  );

  static const List<HousingItem> catalog = [
        studioSksu,
        roomYufu,
        apartmentBaitursynov,
        sharedDorm,
        loftCenter,
        similarYufu,
        similarAbay,
      ];

  static const List<HousingItem> nearbyList = [
        studioSksu,
        roomYufu,
        apartmentBaitursynov,
        sharedDorm,
        loftCenter,
      ];

  static const List<HousingItem> similar = [];

  static HousingItem? byId(String id) {
    for (final item in catalog) {
      if (item.id == id) return item;
    }
    return null;
  }

  static List<HousingItem> similarTo(HousingItem current, {int limit = 4}) {
    return catalog.where((h) => h.id != current.id).take(limit).toList();
  }
}
