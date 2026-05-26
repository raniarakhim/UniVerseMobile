/// Нормализация телефона для поиска в Firestore (только цифры).
String normalizePhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('8') && digits.length == 11) {
    return '7${digits.substring(1)}';
  }
  return digits;
}

/// E.164 для Firebase Phone Auth (Казахстан: +7…).
String formatPhoneE164(String raw) {
  final n = normalizePhone(raw);
  if (n.isEmpty) return '';
  if (n.length == 11 && n.startsWith('7')) return '+$n';
  if (n.length == 10) return '+7$n';
  return '+$n';
}

String maskPhone(String e164) {
  final digits = e164.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 4) return e164;
  final last = digits.substring(digits.length - 2);
  if (digits.length >= 11) {
    return '+${digits.substring(0, 1)} ${digits.substring(1, 4)}*****$last';
  }
  return '*****$last';
}

String maskEmail(String email) {
  final parts = email.split('@');
  if (parts.length != 2) return email;
  final local = parts[0];
  if (local.length <= 2) return '**@${parts[1]}';
  return '${local.substring(0, 2)}***@${parts[1]}';
}
