class CustomerCareFaqItem {
  const CustomerCareFaqItem({
    required this.question,
    required this.screenTitle,
    required this.answer,
  });

  final String question;
  final String screenTitle;
  final String answer;
}

class CustomerCareFaqSection {
  const CustomerCareFaqSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<CustomerCareFaqItem> items;
}

class CustomerCareFaq {
  CustomerCareFaq._();

  static const List<CustomerCareFaqSection> sections = [
    CustomerCareFaqSection(
      title: 'Maid',
      items: [
        CustomerCareFaqItem(
          question: 'What services do the maids offer?',
          screenTitle: 'Maid Services',
          answer:
              'Our maids can assist with:\n'
              '• Cleaning\n'
              '• Cooking\n\n'
              'Services may vary depending on the maid\'s skills and experience.',
        ),
        CustomerCareFaqItem(
          question: 'How can I reschedule or cancel a booking?',
          screenTitle: 'Reschedule or Cancel',
          answer:
              'You can request a cancellation or reschedule directly through the app or by contacting SuperBai Support. Availability of substitutes and rescheduled slots may vary depending on timing and demand.',
        ),
      ],
    ),
    CustomerCareFaqSection(
      title: 'My booking',
      items: [
        CustomerCareFaqItem(
          question: 'How can I modify an existing booking?',
          screenTitle: 'Modify Booking',
          answer:
              'Need to change timing, service requirements, or request additional help? Simply raise a request through the app and our team will assist you.',
        ),
        CustomerCareFaqItem(
          question: 'How can I track the progress of my maid?',
          screenTitle: 'Track Maid Progress',
          answer:
              'You can view your booking status and service updates through the app. For urgent updates, our support team is always available to help.',
        ),
      ],
    ),
    CustomerCareFaqSection(
      title: 'Payment',
      items: [
        CustomerCareFaqItem(
          question: 'What is the payment process for maids?',
          screenTitle: 'Payment Process',
          answer:
              'SuperBai offers flexible payment options based on your convenience.\n'
              'You may either:\n'
              '• Pay your maid\'s salary directly to the maid and pay only the SuperBai subscription fee through the app, or\n'
              '• Pay both the maid\'s salary and the SuperBai subscription fee through the SuperBai app, and we will coordinate the payment process.\n\n'
              'Invoices and payment records are available on request for complete transparency.',
        ),
        CustomerCareFaqItem(
          question: 'Is my payment information secure?',
          screenTitle: 'Payment Security',
          answer:
              'Yes. All payments are processed through secure payment gateways. SuperBai does not store your complete card or banking details.',
        ),
      ],
    ),
    CustomerCareFaqSection(
      title: 'Feedback',
      items: [
        CustomerCareFaqItem(
          question: 'How can I share feedback about my SuperBai experience?',
          screenTitle: 'Share Feedback',
          answer:
              'We\'d love to hear from you.\n\n'
              'Whether it\'s a suggestion, appreciation, service feedback, or an idea to improve SuperBai, you can share it with us anytime through the app or by contacting our support team. Your feedback helps us build a better and more stress-free household experience for everyone.',
        ),
        CustomerCareFaqItem(
          question: 'Report a safety incident',
          screenTitle: 'Safety Incident',
          answer:
              'Your safety and security are important to us.\n\n'
              'If you experience any safety concern, theft, property damage, misconduct, or any incident during a service, please contact the SuperBai Support Team immediately through the app or WhatsApp. Our team will assist you and guide you through the next steps.',
        ),
      ],
    ),
    CustomerCareFaqSection(
      title: 'Referrals',
      items: [
        CustomerCareFaqItem(
          question: 'How does the maid referral program work?',
          screenTitle: 'Referral Program',
          answer:
              'Know a reliable maid? Refer her to SuperBai through the app. Once verified and onboarded, she can start receiving opportunities through our platform.',
        ),
        CustomerCareFaqItem(
          question: 'Benefits of referring maids through the app?',
          screenTitle: 'Referral Benefits',
          answer:
              'A stronger maid network means faster substitutes, better service availability, and improved support for all SuperBai households.',
        ),
      ],
    ),
    CustomerCareFaqSection(
      title: 'SuperBai Service',
      items: [
        CustomerCareFaqItem(
          question: 'How does the Substitute Service work?',
          screenTitle: 'Substitute Service',
          answer:
              'One of the biggest household headaches is when your maid suddenly takes leave.\n\n'
              'With SuperBai, you don\'t have to worry about finding a replacement. If your maid informs us that she will be absent, our team proactively arranges a suitable substitute and coordinates the service for you. You will simply receive a notification informing you that a substitute has been assigned.\n\n'
              'No calls. No searching. No last-minute stress. Just a smoothly managed household.',
        ),
      ],
    ),
    CustomerCareFaqSection(
      title: 'SuperBai Pass',
      items: [
        CustomerCareFaqItem(
          question: 'Why choose SuperBai Pass?',
          screenTitle: 'SuperBai Pass',
          answer:
              'SuperBai Pass is designed for families who want complete peace of mind.\n\n'
              'Benefits may include:\n'
              '• Priority Support\n'
              '• Faster Substitute Arrangements\n'
              '• Household Flexibility Services\n'
              '• Dedicated Customer Assistance\n'
              '• Better Service Coordination\n\n'
              'SuperBai Pass helps you enjoy a more reliable, stress-free, and professionally managed household experience.',
        ),
      ],
    ),
  ];
}
