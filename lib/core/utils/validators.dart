class Validators {
  Validators._();

  static String? required(String? v, String message) =>
      (v == null || v.trim().isEmpty) ? message : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Enter a valid email address';
  }
}
