# Сброс пароля: код на email и SMS на телефон

## Как это работает

| Ввод | Что приходит | Где проверяется |
|------|----------------|-----------------|
| **Email** | 6-значный код на почту | Cloud Functions + экран кода |
| **Телефон** | 6-значный SMS | Firebase Phone Auth |

После кода пользователь задаёт новый пароль на экране **Reset Password**.

## 1. Firebase Console

1. **Authentication → Sign-in method**
   - **Email/Password** — Enabled
   - **Phone** — Enabled (для SMS)
2. **Authentication → Settings → Authorized domains** — `localhost`, ваш домен Hosting.
3. Тариф **Blaze** (pay-as-you-go) — для Phone Auth и Cloud Functions в продакшене.

## 2. Развернуть Cloud Functions (обязательно для email)

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

### Письмо с кодом (Gmail)

Создайте [пароль приложения Gmail](https://myaccount.google.com/apppasswords) и задайте секреты:

```bash
firebase functions:secrets:set GMAIL_USER
firebase functions:secrets:set GMAIL_APP_PASSWORD
```

Либо для теста без почты: код пишется в **логи Functions** (`firebase functions:log`).

В `functions/index.js` используются переменные `process.env.GMAIL_USER` и `GMAIL_APP_PASSWORD`.  
Для secrets v2 добавьте в `index.js` при необходимости `defineSecret` — для диплома можно задать через:

```bash
firebase functions:config:set gmail.user="you@gmail.com" gmail.pass="app-password"
```

И обновить код на `functions.config()` — **текущая версия читает `process.env`**, задайте в Firebase Console → Functions → Environment variables.

### Android Phone Auth

- SHA-1 в настройках Android-приложения
- Тестовые номера: Authentication → Phone → Phone numbers for testing

## 3. Firestore Rules

Уже добавлено: клиент **не** читает `password_reset_sessions` (только Functions).

```bash
firebase deploy --only firestore:rules
```

## 4. Проверка

1. Зарегистрируйтесь с email + телефоном.
2. **Forgot Password** → email → код (почта или лог Functions) → новый пароль.
3. **Forgot Password** → телефон → SMS → новый пароль.

## Ошибка «Сервер недоступен»

Functions не развёрнуты. Выполните `firebase deploy --only functions`.
