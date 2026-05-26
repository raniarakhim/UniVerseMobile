const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const { getFirestore, FieldValue, Timestamp } = require("firebase-admin/firestore");
const crypto = require("crypto");
const nodemailer = require("nodemailer");

initializeApp();

const db = getFirestore();
const auth = getAuth();

const OTP_TTL_MS = 10 * 60 * 1000;
const RESET_TOKEN_TTL_MS = 15 * 60 * 1000;
const MAX_ATTEMPTS = 5;

function normalizePhone(raw) {
  const digits = String(raw || "").replace(/\D/g, "");
  if (digits.startsWith("8") && digits.length === 11) return "7" + digits.slice(1);
  return digits;
}

function hashCode(code) {
  return crypto.createHash("sha256").update(String(code)).digest("hex");
}

function randomCode() {
  return String(Math.floor(100000 + Math.random() * 900000));
}

function randomToken() {
  return crypto.randomBytes(24).toString("hex");
}

async function findUidByPhone(normalized) {
  let snap = await db
    .collection("users")
    .where("phoneNormalized", "==", normalized)
    .limit(1)
    .get();
  if (!snap.empty) return snap.docs[0].id;

  snap = await db.collection("users").limit(300).get();
  for (const doc of snap.docs) {
    const phone = doc.data().phone || "";
    if (normalizePhone(phone) === normalized) return doc.id;
  }
  return null;
}

async function sendEmailOtp(email, code) {
  const user = process.env.GMAIL_USER;
  const pass = process.env.GMAIL_APP_PASSWORD;

  if (!user || !pass) {
    console.log(`[DEV] Password reset OTP for ${email}: ${code}`);
    return { devMode: true };
  }

  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: { user, pass },
  });

  await transporter.sendMail({
    from: `UniVerse <${user}>`,
    to: email,
    subject: "Код для сброса пароля UniVerse",
    text: `Ваш код: ${code}\n\nКод действует 10 минут. Если вы не запрашивали сброс — проигнорируйте письмо.`,
    html: `<p>Ваш код для сброса пароля:</p><p style="font-size:28px;font-weight:bold;letter-spacing:4px">${code}</p><p>Код действует 10 минут.</p>`,
  });
  return { devMode: false };
}

/** Проверка, что номер зарегистрирован (до отправки SMS). */
exports.checkPhoneForPasswordReset = onCall(async (request) => {
  const normalized = normalizePhone(request.data?.phone || "");
  if (normalized.length < 10) {
    throw new HttpsError("invalid-argument", "Некорректный номер");
  }
  const uid = await findUidByPhone(normalized);
  if (!uid) {
    throw new HttpsError(
      "not-found",
      "Аккаунт с этим номером не найден. Укажите email при регистрации.",
    );
  }
  return { ok: true, uid };
});

/** Запрос 6-значного кода на email. */
exports.requestPasswordResetOtp = onCall(async (request) => {
  const email = String(request.data?.email || "")
    .trim()
    .toLowerCase();
  if (!email.includes("@") || email.length < 5) {
    throw new HttpsError("invalid-argument", "Некорректный email");
  }

  let uid;
  try {
    const user = await auth.getUserByEmail(email);
    uid = user.uid;
  } catch {
    throw new HttpsError("not-found", "Пользователь с таким email не найден");
  }

  const code = randomCode();
  const sessionId = randomToken();
  const expiresAt = Timestamp.fromMillis(Date.now() + OTP_TTL_MS);

  await db.collection("password_reset_sessions").doc(sessionId).set({
    channel: "email",
    target: email,
    uid,
    codeHash: hashCode(code),
    attempts: 0,
    verified: false,
    expiresAt,
    createdAt: FieldValue.serverTimestamp(),
  });

  const mail = await sendEmailOtp(email, code);
  const masked = email.replace(/(.{2}).+(@.+)/, "$1***$2");

  return {
    sessionId,
    maskedDestination: masked,
    devMode: mail.devMode === true,
  };
});

/** Проверка email-кода, выдача resetToken. */
exports.verifyPasswordResetOtp = onCall(async (request) => {
  const sessionId = String(request.data?.sessionId || "");
  const code = String(request.data?.code || "").trim();
  if (!sessionId || code.length !== 6) {
    throw new HttpsError("invalid-argument", "Введите 6-значный код");
  }

  const ref = db.collection("password_reset_sessions").doc(sessionId);
  const snap = await ref.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Сессия не найдена. Запросите код снова");
  }

  const data = snap.data();
  if (data.channel !== "email") {
    throw new HttpsError("failed-precondition", "Неверный тип сессии");
  }
  if (data.verified) {
    throw new HttpsError("failed-precondition", "Код уже использован");
  }
  if (data.expiresAt.toMillis() < Date.now()) {
    throw new HttpsError("deadline-exceeded", "Код истёк. Запросите новый");
  }
  if (data.attempts >= MAX_ATTEMPTS) {
    throw new HttpsError("resource-exhausted", "Слишком много попыток");
  }

  if (hashCode(code) !== data.codeHash) {
    await ref.update({ attempts: FieldValue.increment(1) });
    throw new HttpsError("invalid-argument", "Неверный код");
  }

  const resetToken = randomToken();
  await ref.update({
    verified: true,
    resetToken: hashCode(resetToken),
    resetTokenExpiresAt: Timestamp.fromMillis(Date.now() + RESET_TOKEN_TTL_MS),
    verifiedAt: FieldValue.serverTimestamp(),
  });

  return { resetToken };
});

/** Новый пароль после проверки email-кода. */
exports.completePasswordReset = onCall(async (request) => {
  const sessionId = String(request.data?.sessionId || "");
  const resetToken = String(request.data?.resetToken || "");
  const newPassword = String(request.data?.newPassword || "");

  if (!sessionId || !resetToken) {
    throw new HttpsError("invalid-argument", "Нет токена сброса");
  }
  if (newPassword.length < 6) {
    throw new HttpsError("invalid-argument", "Пароль не короче 6 символов");
  }

  const ref = db.collection("password_reset_sessions").doc(sessionId);
  const snap = await ref.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Сессия не найдена");
  }

  const data = snap.data();
  if (!data.verified || hashCode(resetToken) !== data.resetToken) {
    throw new HttpsError("permission-denied", "Сначала подтвердите код");
  }
  if (data.resetTokenExpiresAt.toMillis() < Date.now()) {
    throw new HttpsError("deadline-exceeded", "Время сброса истекло");
  }

  await auth.updateUser(data.uid, { password: newPassword });
  await ref.delete();

  return { success: true };
});

/**
 * После входа по SMS (Phone Auth) — смена пароля аккаунта, найденного по номеру.
 * Клиент: verifyPhoneNumber → signInWithCredential → вызов этой функции.
 */
exports.completePhonePasswordReset = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Сначала подтвердите SMS-код");
  }

  const normalizedPhone = String(request.data?.normalizedPhone || "");
  const newPassword = String(request.data?.newPassword || "");
  if (normalizedPhone.length < 10) {
    throw new HttpsError("invalid-argument", "Некорректный номер");
  }
  if (newPassword.length < 6) {
    throw new HttpsError("invalid-argument", "Пароль не короче 6 символов");
  }

  const authPhone = request.auth.token.phone_number;
  if (!authPhone) {
    throw new HttpsError("failed-precondition", "Нет подтверждённого номера");
  }
  const tokenPhone = normalizePhone(authPhone);
  if (tokenPhone !== normalizedPhone) {
    throw new HttpsError("permission-denied", "Номер не совпадает с подтверждённым");
  }

  const uid = await findUidByPhone(normalizedPhone);
  if (!uid) {
    throw new HttpsError("not-found", "Аккаунт с этим номером не найден");
  }

  const phoneAuthUid = request.auth.uid;
  await auth.updateUser(uid, { password: newPassword });

  if (phoneAuthUid !== uid) {
    try {
      await auth.deleteUser(phoneAuthUid);
    } catch (e) {
      console.warn("Could not delete temp phone user", e);
    }
  }

  return { success: true, uid };
});
