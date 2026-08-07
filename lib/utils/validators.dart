
class Validators {
  Validators._();

  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final RegExp _phone = RegExp(r'^\+?[\d\s-]{7,15}$');

  static String? required(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? value) {
    final empty = required(value, 'Email');
    if (empty != null) return empty;
    if (!_email.hasMatch(value!.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    final empty = required(value, 'Password');
    if (empty != null) return empty;
    if (value!.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final empty = required(value, 'Confirm password');
    if (empty != null) return empty;
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? phone(String? value) {
    final empty = required(value, 'Phone number');
    if (empty != null) return empty;
    if (!_phone.hasMatch(value!.trim())) return 'Enter a valid phone number';
    return null;
  }

  static String? fullName(String? value) {
    final empty = required(value, 'Full name');
    if (empty != null) return empty;
    if (value!.trim().length < 3) return 'Enter your full name';
    return null;
  }
}
