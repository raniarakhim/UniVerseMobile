# UniVerse (diplomka)

Flutter-приложение для студентов: объявления, события, вакансии, жильё и профиль.

## Стек

- Flutter / Dart
- Firebase (Auth, Firestore, Hosting)
- OpenStreetMap (`flutter_map`) для карты жилья

## Запуск

```bash
flutter pub get
flutter run
```

Release APK:

```bash
flutter build apk --release
```

Готовый файл: [releases/UniVerse-release.apk](releases/UniVerse-release.apk)

## Firebase

См. [FIREBASE_SETUP.md](FIREBASE_SETUP.md). Проект: `diplomkauniverse`, сайт: https://diplomkauniverse.web.app

## Структура

- `lib/home` — главная, объявления
- `lib/events` — события
- `lib/job` — вакансии
- `lib/housing` — жильё и карта
- `lib/profile` — профиль, сохранённое
