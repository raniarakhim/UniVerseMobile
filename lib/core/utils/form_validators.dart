class FormValidators {
  FormValidators._();

  static String? requiredField(String? value, {String fieldName = 'Поле'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName обязательно для заполнения';
    }
    return null;
  }

  static String? email(String? value) {
    final empty = requiredField(value, fieldName: 'Email');
    if (empty != null) return empty;
    final v = value!.trim();
    if (!v.contains('@') || !v.contains('.')) {
      return 'Введите корректный email';
    }
    return null;
  }

  static String? phone(String? value) {
    final empty = requiredField(value, fieldName: 'Телефон');
    if (empty != null) return empty;
    final digits = value!.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      return 'Введите корректный номер телефона';
    }
    return null;
  }
}
