# Настройка Firebase для UniVerse (diplomka)

## Что уже сделано в коде

- **Firebase Auth** — регистрация (email + пароль), **Login / Sign up with Google**, вход
- **Cloud Firestore** — коллекция `users`, документ с ID = `uid` пользователя:
  - `fullName`, `email`, `phone`, `createdAt`
- Экраны: **Sign Up** → **Create Password** → сохранение в Firebase; **Login** — вход
- **Firebase Storage** — фото профиля (`users/{uid}/profile.jpg`), CV в профиле (`resume.pdf`), CV в заявке на работу (`applications/...pdf`)

## 1. Создайте проект в Firebase

1. Откройте [Firebase Console](https://console.firebase.google.com/)
2. **Add project** → например `diplomkauniverse` (текущий проект приложения)
3. Включите **Authentication** → **Sign-in method** → **Email/Password** → Enable
4. Включите **Google** → Enable → укажите support email → Save
5. Включите **Firestore Database** → Create database → test mode (для разработки) или production с правилами ниже
6. Включите **Storage** → Get started → тот же регион, что и Firestore
7. Разверните правила Storage из корня проекта:

```bash
firebase deploy --only storage
```

(файл `storage.rules` — загрузка только в `users/{uid}/...` для авторизованного пользователя)

### Google Sign-In в браузере (Web / Chrome)

На **Web** используется `signInWithPopup` Firebase — отдельный Client ID в `index.html` не нужен.

1. В Firebase → **Authentication** → **Google** должен быть **Enabled**.
2. **Authentication** → **Settings** → **Authorized domains**: добавьте `localhost` и ваш домен (например `diplomkauniverse.web.app`).
3. Разрешите всплывающие окна для localhost в браузере.

### Google Sign-In на Android (обязательно)

1. После включения Google скачайте **новый** `google-services.json` (в нём должен быть блок `oauth_client`, не пустой `[]`).
2. Положите файл в `android/app/google-services.json`.
3. Добавьте SHA-1 отладочного ключа в Firebase → Project settings → Your apps → Android → Add fingerprint:

```bash
cd android
./gradlew signingReport
```

Скопируйте **SHA1** из `Variant: debug` и вставьте в консоль Firebase.

## 2. Добавьте приложения

### Android
- Package name: `com.example.diplomka` (как в `android/app/build.gradle.kts`)
- Скачайте `google-services.json` → положите в `android/app/google-services.json`

### Web (если запускаете в Chrome)
- Добавьте Web app в консоли Firebase
- Скопируйте конфиг в `lib/firebase/firebase_options.dart` (см. шаг 3)

## 3. Сгенерируйте конфиг (рекомендуется)

В корне проекта:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Команда перезапишет `lib/firebase/firebase_options.dart` реальными ключами для выбранных платформ.

**Либо** вручную замените `YOUR_*` в `lib/firebase/firebase_options.dart` значениями из Firebase Console → Project settings → Your apps.

## 4. Правила Firestore (для продакшена)

В Firebase Console → Firestore → Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Для **тестов** можно временно:

```
allow read, write: if request.auth != null;
```

## 5. Firebase Hosting (веб-версия)

**Hosting** публикует **веб-версию** приложения в интернет. APK на Android и установка на iPhone **не используют** Hosting — они подключаются к Firebase Auth и Firestore напрямую.

| Что | URL / путь |
|-----|------------|
| Сайт приложения | https://diplomkauniverse.web.app |
| Альтернативный домен | https://diplomkauniverse.firebaseapp.com |
| Папка сборки | `build/web` (см. `firebase.json` → `hosting.public`) |

### Деплой после изменений в коде

```powershell
flutter build web --release
firebase deploy --only "hosting,firestore:rules"
```

Только сайт:

```powershell
firebase deploy --only hosting
```

### Важно для входа на сайте

В [Firebase Console](https://console.firebase.google.com/project/diplomkauniverse/authentication/settings) → **Authentication** → **Settings** → **Authorized domains** должны быть:

- `diplomkauniverse.web.app`
- `diplomkauniverse.firebaseapp.com`
- `localhost` (для локальной разработки)

Обычно Firebase добавляет их автоматически при первом деплое Hosting.

## 6. Запуск локально

```bash
flutter pub get
flutter run
```

Для веба в браузере:

```bash
flutter run -d chrome
```

После настройки зарегистрируйте пользователя в приложении — в **Authentication → Users** и в **Firestore → users** появится запись.

## Устранение ошибок

| Ошибка | Решение |
|--------|---------|
| `Firebase не настроен` | Выполните `flutterfire configure` или заполните `firebase_options.dart` |
| `email-already-in-use` | Email уже зарегистрирован |
| Android: Default FirebaseApp failed | Проверьте `google-services.json` в `android/app/` |
| Web: API key invalid | Обновите `web` секцию в `firebase_options.dart` |
