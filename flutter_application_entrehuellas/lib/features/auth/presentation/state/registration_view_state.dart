enum RegistrationField { name, email, password, confirmation }

class RegistrationViewState {
  const RegistrationViewState({
    this.isBusy = false,
    this.confirmationEmail,
    this.authenticated = false,
    this.errorField,
    this.fieldHint,
    this.message,
    this.errorId = 0,
    this.resendSeconds = 0,
  });
  final bool isBusy;
  final String? confirmationEmail;
  final bool authenticated;
  final RegistrationField? errorField;
  final String? fieldHint;
  final String? message;
  final int errorId;
  final int resendSeconds;

  RegistrationViewState copyWith({
    bool? isBusy,
    int? resendSeconds,
    bool clearError = false,
    String? message,
  }) => RegistrationViewState(
    isBusy: isBusy ?? this.isBusy,
    confirmationEmail: confirmationEmail,
    authenticated: authenticated,
    errorField: clearError ? null : errorField,
    fieldHint: clearError ? null : fieldHint,
    message: clearError ? message : message ?? this.message,
    errorId: errorId,
    resendSeconds: resendSeconds ?? this.resendSeconds,
  );
}
