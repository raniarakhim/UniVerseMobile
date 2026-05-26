enum PasswordResetChannel { email, phone }

class PasswordResetFlowArgs {
  const PasswordResetFlowArgs({
    required this.channel,
    required this.maskedDestination,
    required this.target,
    this.sessionId,
    this.normalizedPhone,
    this.e164,
    this.devMode = false,
  });

  final PasswordResetChannel channel;
  final String maskedDestination;
  /// Email или E.164 телефон.
  final String target;
  final String? sessionId;
  final String? normalizedPhone;
  final String? e164;
  final bool devMode;
}

class PasswordResetVerifiedArgs {
  const PasswordResetVerifiedArgs({
    required this.channel,
    required this.sessionId,
    required this.resetToken,
    this.normalizedPhone,
  });

  final PasswordResetChannel channel;
  final String sessionId;
  final String resetToken;
  final String? normalizedPhone;
}
