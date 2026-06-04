/// Helpers for normalizing phone numbers stored in Firestore.
class PhoneUtils {
  /// Returns last 10 digits from [e164OrLocal] (e.g. `+918850614966` → `8850614966`).
  static String toTenDigit(String? e164OrLocal) {
    if (e164OrLocal == null || e164OrLocal.isEmpty) return '';
    final digits = e164OrLocal.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 10) return digits;
    return digits.substring(digits.length - 10);
  }

  /// All common stored formats to match legacy [User] / [TestUser] phone fields.
  static List<String> queryVariants(String? e164OrLocal) {
    final phone10 = toTenDigit(e164OrLocal);
    final raw = e164OrLocal?.trim() ?? '';
    final variants = <String>{};
    if (phone10.isNotEmpty) {
      variants.addAll({
        phone10,
        '+91$phone10',
        '91$phone10',
        '0$phone10',
      });
    }
    if (raw.isNotEmpty) {
      variants.add(raw);
      variants.add(raw.replaceAll(RegExp(r'\D'), ''));
    }
    return variants.where((v) => v.isNotEmpty).toList();
  }
}
