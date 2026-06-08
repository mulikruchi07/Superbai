import 'package:flutter_test/flutter_test.dart';
import 'package:superbai/data/customer_care_faq.dart';
import 'package:superbai/data/terms_and_conditions.dart';

void main() {
  test('terms of service and privacy policy content is present', () {
    expect(TermsAndConditions.termsSections, isNotEmpty);
    expect(TermsAndConditions.privacySections, isNotEmpty);
    expect(TermsAndConditions.declarations, isNotEmpty);
  });

  test('customer care FAQ sections are present', () {
    expect(CustomerCareFaq.sections, isNotEmpty);
    for (final section in CustomerCareFaq.sections) {
      expect(section.title.trim(), isNotEmpty);
      expect(section.items, isNotEmpty);
    }
  });
}
