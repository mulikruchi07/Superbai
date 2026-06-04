/// Helpers for normalizing phone numbers stored in Firestore.
class PhoneUtils {
  /// Returns last 10 digits from [e164OrLocal] (e.g. `+918850614966` → `8850614966`).
  static String toTenDigit(String? e164OrLocal) {
    if (e164OrLocal == null || e164OrLocal.isEmpty) return '';
    final digits = e164OrLocal.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 10) return digits;
    return digits.substring(digits.length - 10);
  }
}
