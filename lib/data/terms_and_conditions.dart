class TermsSection {
  const TermsSection({required this.title, required this.body});

  final String title;
  final String body;
}

/// SuperBai Terms of Service and Privacy Policy (v2).
class TermsAndConditions {
  TermsAndConditions._();

  static const String version = '2.0';

  static const String intro =
      'These Terms of Service constitute a legally binding agreement between you and SuperBai Solutions Private Limited. By accessing, registering on, or using the Platform, you acknowledge that you have read, understood, and agreed to be bound by these Terms, the Privacy Policy, and all applicable policies published by SuperBai.';

  static const List<TermsSection> termsSections = [
    TermsSection(
      title: '1. Acceptance of Terms',
      body:
          'These Terms of Service ("Terms") constitute a legally binding agreement between the user ("User", "Customer", "Domestic Worker", "You") and SuperBai Solutions Private Limited ("SuperBai", "Company", "We", "Us", "Our").\n\nBy accessing, registering on, or using the Platform, you acknowledge that you have read, understood, and agreed to be bound by these Terms, the Privacy Policy, and all applicable policies published by SuperBai.',
    ),
    TermsSection(
      title: '2. Definitions',
      body:
          'Platform means the SuperBai website, mobile application, WhatsApp Business channels, software, and related services.\n\n'
          'Customer means any individual, family, household, society, or entity using the Platform.\n\n'
          'Domestic Worker means any maid, cook, nanny, babysitter, caregiver, cleaner, helper, substitute worker, or other household service provider registered on the Platform.\n\n'
          'Subscription Services means paid services offered by SuperBai including workforce management, substitute coordination, support services, and related benefits.\n\n'
          'Substitute Service means SuperBai\'s coordination service through which an alternate domestic worker may be identified and introduced when the primary worker is unavailable.',
    ),
    TermsSection(
      title: '3. Nature of Services',
      body:
          'SuperBai operates as a technology-enabled household workforce management and coordination platform.\n\n'
          'The Platform may facilitate:\n'
          '• Registration of domestic workers\n'
          '• Workforce management\n'
          '• Attendance tracking\n'
          '• Leave management\n'
          '• Substitute coordination\n'
          '• Communication support\n'
          '• Service scheduling\n'
          '• Customer support\n'
          '• Household assistance requests\n\n'
          'SuperBai does not itself perform domestic work and does not employ domestic workers for the benefit of customers.',
    ),
    TermsSection(
      title: '4. User Eligibility',
      body:
          'Users must:\n'
          '• Be at least eighteen (18) years of age;\n'
          '• Possess legal capacity to enter into binding contracts;\n'
          '• Provide accurate and complete information.\n\n'
          'SuperBai reserves the right to verify information and reject registrations at its discretion.',
    ),
    TermsSection(
      title: '5. User Accounts',
      body:
          'Users shall:\n'
          '• Maintain confidentiality of account credentials;\n'
          '• Be responsible for all activities conducted through their accounts;\n'
          '• Immediately notify SuperBai of unauthorized access.\n\n'
          'SuperBai may suspend or terminate accounts for security, compliance, or operational reasons.',
    ),
    TermsSection(
      title: '6. Subscription & Fees',
      body:
          'Certain services may require payment of subscription fees.\n\n'
          'Subscription benefits may include:\n'
          '• Substitute coordination;\n'
          '• Priority support;\n'
          '• Household workforce management;\n'
          '• Attendance and leave tracking;\n'
          '• Service assistance.\n\n'
          'Fees are subject to revision upon prior notice. Applicable taxes including GST shall be charged in accordance with applicable laws.',
    ),
    TermsSection(
      title: '7. Payments',
      body:
          'Customers may:\n\n'
          '(a) Direct Payment Model\n'
          'Pay domestic workers directly and separately pay subscription fees to SuperBai.\n\n'
          '(b) Coordinated Payment Model\n'
          'Authorize SuperBai to collect domestic worker compensation and subscription fees for coordination and payment facilitation purposes.\n\n'
          'SuperBai is not a banking institution and merely facilitates payment processing through authorized payment service providers.',
    ),
    TermsSection(
      title: '8. Substitute Service Disclaimer',
      body:
          'Substitute Services are offered on a commercially reasonable and best-efforts basis.\n\n'
          'SuperBai does not guarantee:\n'
          '• Substitute availability;\n'
          '• Exact skill matching;\n'
          '• Identical service quality;\n'
          '• Availability within a specified timeframe.\n\n'
          'The inability to provide a substitute shall not constitute a breach of these Terms.',
    ),
    TermsSection(
      title: '9. Independent Contractor Status',
      body:
          'Domestic workers registered on the Platform are independent service providers.\n\n'
          'Nothing contained in these Terms shall be construed as creating:\n'
          '• Employer-employee relationship;\n'
          '• Principal-agent relationship;\n'
          '• Partnership;\n'
          '• Joint venture;\n'
          '• Labour engagement\n\n'
          'between SuperBai and any domestic worker. SuperBai acts solely as a facilitator and coordinator.',
    ),
    TermsSection(
      title: '10. Verification Disclaimer',
      body:
          'SuperBai may collect and review identity, contact, and background information of domestic workers.\n\n'
          'Such verification:\n'
          '• Is limited in nature;\n'
          '• Is based on information available at the time of verification;\n'
          '• Does not guarantee future conduct, honesty, safety, or suitability.\n\n'
          'Users engage domestic workers at their own discretion and risk.',
    ),
    TermsSection(
      title: '11. Safety, Theft & Property Damage',
      body:
          'SuperBai shall not be responsible for:\n'
          '• Theft;\n'
          '• Fraud;\n'
          '• Property damage;\n'
          '• Criminal acts;\n'
          '• Misconduct;\n'
          '• Personal injury;\n'
          '• Loss of valuables;\n'
          '• Workplace disputes.\n\n'
          'Any dispute arising between Customers and Domestic Workers shall remain between the concerned parties. SuperBai may assist in communication and dispute management but assumes no liability.',
    ),
    TermsSection(
      title: '12. Customer Obligations',
      body:
          'Customers shall:\n'
          '• Provide a safe work environment;\n'
          '• Treat workers with dignity and respect;\n'
          '• Comply with applicable laws;\n'
          '• Refrain from discrimination, harassment, or abuse.\n\n'
          'Customers remain solely responsible for activities occurring within their premises.',
    ),
    TermsSection(
      title: '13. Prohibited Conduct',
      body:
          'Users shall not:\n'
          '• Misrepresent information;\n'
          '• Violate applicable laws;\n'
          '• Interfere with Platform operations;\n'
          '• Circumvent fees;\n'
          '• Harass other users;\n'
          '• Upload malicious software;\n'
          '• Engage in fraudulent activity.',
    ),
    TermsSection(
      title: '14. Intellectual Property',
      body:
          'All rights, title, and interest in:\n'
          '• SuperBai name;\n'
          '• Logos;\n'
          '• Software;\n'
          '• Designs;\n'
          '• Content;\n'
          '• Databases;\n'
          '• Trademarks;\n'
          '• Business processes;\n\n'
          'remain the exclusive property of SuperBai Solutions Private Limited.',
    ),
    TermsSection(
      title: '15. Disclaimer of Warranties',
      body:
          'The Platform is provided on an "AS IS" and "AS AVAILABLE" basis.\n\n'
          'SuperBai makes no warranties regarding:\n'
          '• Service availability;\n'
          '• Service quality;\n'
          '• Worker suitability;\n'
          '• Worker conduct;\n'
          '• Platform uptime;\n'
          '• Substitute availability.',
    ),
    TermsSection(
      title: '16. Limitation of Liability',
      body:
          'To the fullest extent permitted under law, SuperBai\'s aggregate liability arising from use of the Platform shall not exceed the subscription fees paid by the User to SuperBai during the preceding three (3) months.\n\n'
          'SuperBai shall not be liable for:\n'
          '• Indirect damages;\n'
          '• Consequential damages;\n'
          '• Loss of profits;\n'
          '• Loss of data;\n'
          '• Reputational harm;\n'
          '• Personal injury;\n'
          '• Property damage.',
    ),
    TermsSection(
      title: '17. Indemnity',
      body:
          'Users agree to indemnify and hold harmless SuperBai, its founders, directors, employees, consultants, affiliates, and agents against all claims, liabilities, losses, costs, and expenses arising from:\n'
          '• User misconduct;\n'
          '• Violation of these Terms;\n'
          '• Breach of applicable laws;\n'
          '• Disputes between Customers and Domestic Workers.',
    ),
    TermsSection(
      title: '18. Privacy',
      body:
          'Use of the Platform is subject to the SuperBai Privacy Policy, incorporated herein by reference.',
    ),
    TermsSection(
      title: '19. Suspension & Termination',
      body:
          'SuperBai may suspend, restrict, or terminate accounts at its discretion for:\n'
          '• Fraud;\n'
          '• Security concerns;\n'
          '• Misconduct;\n'
          '• Policy violations;\n'
          '• Operational requirements.',
    ),
    TermsSection(
      title: '20. Modification of Terms',
      body:
          'SuperBai reserves the right to modify these Terms at any time. Continued use of the Platform after publication of revised Terms shall constitute acceptance of such revisions.',
    ),
    TermsSection(
      title: '21. Force Majeure',
      body:
          'SuperBai shall not be liable for delays or failures resulting from events beyond reasonable control, including natural disasters, strikes, government actions, epidemics, internet outages, or transportation disruptions.',
    ),
    TermsSection(
      title: '22. Dispute Resolution & Arbitration',
      body:
          'Any dispute arising out of or relating to these Terms shall first be attempted to be resolved amicably.\n\n'
          'Failing such resolution, disputes shall be referred to arbitration under the provisions of the Arbitration and Conciliation Act, 1996.\n\n'
          'The seat of arbitration shall be Mumbai, Maharashtra. Proceedings shall be conducted in English.',
    ),
    TermsSection(
      title: '23. Governing Law',
      body:
          'These Terms shall be governed by the laws of India. Subject to the arbitration clause, courts at Mumbai shall have exclusive jurisdiction.',
    ),
  ];

  static const String privacyIntro =
      'SuperBai Solutions Private Limited ("SuperBai", "we", "our", or "us") operates a technology-enabled household workforce management platform. This Privacy Policy explains how we collect, use, store, process, share, and protect your personal information when you use the SuperBai website, mobile application, WhatsApp services, customer support channels, or any related services (collectively, the "Platform").';

  static const List<TermsSection> privacySections = [
    TermsSection(
      title: '1. Introduction',
      body:
          'Welcome to SuperBai.\n\n'
          'By accessing or using SuperBai, you consent to the collection and processing of your information as described in this Privacy Policy.',
    ),
    TermsSection(
      title: '2. Information We Collect',
      body:
          'A. Customer Information\n'
          'We may collect: Full Name, Mobile Number, Email Address, Residential Address, Society / Building Information, Profile Details, Service Preferences, Booking Information, Payment Information, and Feedback and Support Requests.\n\n'
          'B. Domestic Worker Information\n'
          'We may collect: Full Name, Mobile Number, Residential Address, Emergency Contact Details, Aadhaar or other identity documents, Work Experience, Service Skills, Availability Information, Bank Details (where applicable), Verification Documents, and Profile Photograph (optional).\n\n'
          'C. Technical Information\n'
          'When you use our Platform, we may automatically collect: Device Information, IP Address, Browser Type, Operating System, Device ID, App Usage Information, Login Activity, and Location Data (where permission is granted).\n\n'
          'D. Payment Information\n'
          'Payments made through SuperBai may be processed by third-party payment gateways. SuperBai does not store complete debit card, credit card, banking passwords, UPI PINs, or similar sensitive payment credentials.',
    ),
    TermsSection(
      title: '3. How We Collect Information',
      body:
          'We collect information through:\n\n'
          'Directly From You — when you register an account, subscribe to SuperBai Pass, onboard as a domestic worker, contact customer support, submit feedback, or fill forms through the app or WhatsApp.\n\n'
          'Automatically — through cookies, analytics tools, app activity monitoring, and device information.\n\n'
          'Through Third Parties — such as payment gateway providers, verification partners, referral programs, society referrals, and domestic worker references.',
    ),
    TermsSection(
      title: '4. How We Use Your Information',
      body:
          'We may use your information to:\n'
          '• Create and manage user accounts\n'
          '• Provide household workforce management services\n'
          '• Coordinate substitute services\n'
          '• Facilitate communication between households and workers\n'
          '• Process payments and generate invoices\n'
          '• Verify user identities\n'
          '• Improve platform functionality\n'
          '• Resolve disputes and complaints\n'
          '• Provide customer support\n'
          '• Send notifications and updates\n'
          '• Comply with legal obligations\n'
          '• Prevent fraud and misuse',
    ),
    TermsSection(
      title: '5. Substitute Service Management',
      body:
          'One of SuperBai\'s core services is substitute coordination. To facilitate substitute services, SuperBai may use information relating to worker availability, service preferences, household requirements, and service schedules. This information is used solely for workforce coordination and service management.',
    ),
    TermsSection(
      title: '6. Sharing of Information',
      body:
          'We may share limited information with:\n\n'
          'Domestic Workers — to facilitate services requested by households.\n'
          'Households — to facilitate services performed by domestic workers.\n'
          'Service Providers — including payment gateway providers, technology providers, verification partners, cloud storage providers, and customer support partners.\n'
          'Legal Authorities — where required under applicable laws, court orders, governmental directions, or regulatory requirements.',
    ),
    TermsSection(
      title: '7. Information We Do Not Sell',
      body:
          'SuperBai does not sell your personal information to third parties. We do not trade, rent, or commercially exploit personal information for unrelated third-party marketing purposes.',
    ),
    TermsSection(
      title: '8. Cookies & Analytics',
      body:
          'SuperBai may use cookies, analytics tools, and similar technologies to improve user experience, understand platform usage, monitor system performance, and enhance platform security. Users may disable cookies through browser settings; however, certain features may not function properly.',
    ),
    TermsSection(
      title: '9. Data Security',
      body:
          'SuperBai implements reasonable security measures to protect personal information, including secure servers, access controls, password protection, data encryption where applicable, and restricted employee access. However, no electronic system can guarantee absolute security. Users acknowledge that transmission of information over the internet carries inherent risks.',
    ),
    TermsSection(
      title: '10. User Responsibilities',
      body:
          'Users are responsible for maintaining account confidentiality, protecting login credentials, providing accurate information, and reporting unauthorized account access immediately.',
    ),
    TermsSection(
      title: '11. Data Retention',
      body:
          'We retain personal information only for as long as necessary to provide services, comply with legal obligations, resolve disputes, enforce agreements, and maintain business records. Certain records may be retained even after account closure where required by law.',
    ),
    TermsSection(
      title: '12. Account Deletion',
      body:
          'Users may request deletion of their account by contacting SuperBai Customer Support. Upon successful verification and subject to applicable legal requirements, platform access may be terminated and personal information may be deleted or anonymized. Certain records required for compliance, accounting, taxation, fraud prevention, or legal purposes may continue to be retained.',
    ),
    TermsSection(
      title: '13. Communication Consent',
      body:
          'By registering with SuperBai, you consent to receiving calls, SMS, WhatsApp messages, push notifications, and emails related to services, bookings, substitute updates, payments, customer support, and promotional offers (where permitted). Users may opt out of marketing communications at any time.',
    ),
    TermsSection(
      title: '14. Children\'s Privacy',
      body:
          'SuperBai services are intended only for individuals above 18 years of age. We do not knowingly collect personal information from minors.',
    ),
    TermsSection(
      title: '15. Business Transfers',
      body:
          'If SuperBai undergoes a merger, acquisition, investment transaction, restructuring, or sale of assets, user information may be transferred as part of such transaction, subject to applicable law.',
    ),
    TermsSection(
      title: '16. Changes to This Policy',
      body:
          'SuperBai reserves the right to update this Privacy Policy from time to time. Updated versions will be published on the Platform. Continued use of the Platform after such updates constitutes acceptance of the revised Privacy Policy.',
    ),
    TermsSection(
      title: '17. Your Rights',
      body:
          'Subject to applicable law, users may request access to personal information, correction of inaccurate information, updating account details, deletion requests, and withdrawal of consent where legally permissible. Requests may be submitted through SuperBai Customer Support.',
    ),
    TermsSection(
      title: '18. Third-Party Services',
      body:
          'The Platform may contain links or integrations with third-party services including payment gateways, WhatsApp Business, Google Services, and Apple Services. SuperBai is not responsible for the privacy practices of such third parties. Users are encouraged to review their respective privacy policies.',
    ),
    TermsSection(
      title: '19. Grievance Officer',
      body:
          'For privacy-related concerns, requests, or complaints, users may contact the Grievance Officer through SuperBai Customer Support at support@superbai.in.',
    ),
    TermsSection(
      title: '20. Contact Us',
      body:
          'For any questions regarding this Privacy Policy, please contact:\n\n'
          'SuperBai Solutions Private Limited\n'
          'Email: support@superbai.in\n'
          'Website: www.superbai.in',
    ),
  ];

  static const List<String> privacyConsent = [
    'You have read and understood this Privacy Policy.',
    'You consent to the collection, storage, processing, and use of your information as described herein.',
    'You agree to the sharing of information necessary for the provision of SuperBai services.',
  ];

  static const List<String> declarations = [
    'I am at least 18 years of age.',
    'I have read and understood the Terms of Service and Privacy Policy.',
    'I voluntarily agree to be bound by these Terms.',
    'I understand SuperBai is a coordination platform and not the employer of domestic workers.',
    'I consent to the collection and use of my information as described in the Privacy Policy.',
  ];

  /// Backwards-compatible alias used by older screens.
  static List<TermsSection> get sections => termsSections;
}
