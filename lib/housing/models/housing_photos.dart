/// Фото интерьеров жилья (Unsplash) — у каждого объявления свой URL.
abstract final class HousingPhotos {
  static const _q = 'auto=format&fit=crop&w=800&h=500&q=80';

  /// Запасное фото, если загрузка не удалась.
  static const defaultCover =
      'https://images.unsplash.com/photo-1502672260266-1c1ef2cd9361?$_q';

  // Студия
  static const studioLiving =
      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?$_q';
  static const studioSofa =
      'https://images.unsplash.com/photo-1554995207-c18c203602cb?$_q';
  static const studioCozy =
      'https://images.unsplash.com/photo-1484154218962-a197022b5858?$_q';
  static const studioModern =
      'https://images.unsplash.com/photo-1560448075-cbc4a93cd7e0?$_q';

  // Комната
  static const roomBed =
      'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?$_q';
  static const roomBright =
      'https://images.unsplash.com/photo-1598928506311-c55ded939a1c?$_q';
  static const roomSimple =
      'https://images.unsplash.com/photo-1560185127-6ed189bf04f6?$_q';
  static const roomDesk =
      'https://images.unsplash.com/photo-1513694203232-719a280e022f?$_q';

  // Квартира
  static const aptLiving =
      'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?$_q';
  static const aptWide =
      'https://images.unsplash.com/photo-1600210492486-724fe994c013?$_q';
  static const aptKitchen =
      'https://images.unsplash.com/photo-1556912173-46c336c3fd55?$_q';
  static const aptDining =
      'https://images.unsplash.com/photo-1600047509807-ba8f99d2cd7a?$_q';

  // Общежитие
  static const dormRoom =
      'https://images.unsplash.com/photo-1555854877-bab0ef45d366?$_q';
  static const dormBeds =
      'https://images.unsplash.com/photo-1595526114035-0d3ed99242d7?$_q';
  static const dormHall =
      'https://images.unsplash.com/photo-1524758631624-e2822e304c36?$_q';

  // Лофт
  static const loftLiving =
      'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?$_q';
  static const loftKitchen =
      'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?$_q';
  static const loftDetail =
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?$_q';
  static const loftOpen =
      'https://images.unsplash.com/photo-1616594039964-4088aaba88ca?$_q';

  // 2-комнатная
  static const twoRoomLiving =
      'https://images.unsplash.com/photo-1600575154526-990d9af97546?$_q';
  static const twoRoomBed =
      'https://images.unsplash.com/photo-1616135824236-bab0e834b118?$_q';
  static const twoRoomView =
      'https://images.unsplash.com/photo-1484101403633-562891f886b2?$_q';

  // Shared
  static const sharedBed =
      'https://images.unsplash.com/photo-1631889992176-680e893c27c0?$_q';
  static const sharedSmall =
      'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?$_q';
}
