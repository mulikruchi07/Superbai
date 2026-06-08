class TermsSection {
  const TermsSection({required this.title, required this.body});

  final String title;
  final String body;
}

/// SuperBai legal content (v3).
class TermsAndConditions {
  TermsAndConditions._();

  static const String version = '3.0';

  // ── Login: Customer Terms & Conditions ──────────────────────────────────────

  static const String customerTermsWelcome =
      'Welcome to SuperBai. By registering an account, subscribing to our services, or using the SuperBai platform, you agree to the following Terms & Conditions.';

  static const List<TermsSection> customerTermsSections = [
    TermsSection(
      title: '1. Nature of Service',
      body:
          'SuperBai is a technology-enabled household workforce management platform that helps households coordinate domestic help services, including substitute support, scheduling assistance, communication, attendance tracking, and related household support services.\n\n'
          'SuperBai acts solely as a facilitator and management platform and does not provide domestic services directly.',
    ),
    TermsSection(
      title: '2. No Employer–Employee Relationship',
      body:
          'SuperBai is not the employer of any maid, domestic worker, cook, babysitter, caretaker, or household helper registered on the platform.\n\n'
          'All domestic workers remain independent service providers and retain full control over accepting, rejecting, or discontinuing work opportunities.\n\n'
          'Nothing on the platform shall be construed as creating an employer-employee relationship between:\n'
          '• SuperBai and the domestic worker; or\n'
          '• SuperBai and the customer.',
    ),
    TermsSection(
      title: '3. Customer Responsibility',
      body:
          'The customer is solely responsible for:\n'
          '• Granting access to the premises;\n'
          '• Supervising work performed inside the premises;\n'
          '• Securing valuables, cash, jewellery, documents, and personal belongings;\n'
          '• Verifying suitability of any worker for their specific household requirements.\n\n'
          'Customers are advised not to leave valuables unattended.',
    ),
    TermsSection(
      title: '4. Theft, Loss, Damage & Criminal Acts',
      body:
          'While SuperBai may assist customers in resolving issues and may cooperate with law enforcement authorities where required, SuperBai shall not be liable for:\n'
          '• Theft;\n'
          '• Robbery;\n'
          '• Misappropriation;\n'
          '• Fraud;\n'
          '• Property damage;\n'
          '• Personal injury;\n'
          '• Criminal acts;\n'
          '• Misconduct;\n'
          '• Negligence;\n\n'
          'committed by any domestic worker, substitute worker, customer, resident, guest, or third party.\n\n'
          'Any dispute arising between a customer and a domestic worker shall be resolved directly between the parties and/or through the appropriate legal authorities.',
    ),
    TermsSection(
      title: '5. Substitute Service Disclaimer',
      body:
          'SuperBai\'s substitute service is a best-efforts coordination service.\n\n'
          'Although SuperBai will make reasonable efforts to arrange substitute workers in the event of leave, absence, emergency, or unavailability of a domestic worker, SuperBai does not guarantee:\n'
          '• Availability of substitutes;\n'
          '• Availability within a specific timeframe;\n'
          '• Availability of workers with identical skills, experience, language, or preferences.\n\n'
          'Substitute support shall always remain subject to workforce availability.',
    ),
    TermsSection(
      title: '6. No Service Guarantee',
      body:
          'SuperBai does not guarantee:\n'
          '• Continuous availability of any specific worker;\n'
          '• Quality of work;\n'
          '• Timeliness;\n'
          '• Compatibility between customer and worker;\n'
          '• Future availability of any service.\n\n'
          'The platform only facilitates household workforce coordination.',
    ),
    TermsSection(
      title: '7. Safety & Respect Policy',
      body:
          'Customers shall:\n'
          '• Treat domestic workers with dignity and respect;\n'
          '• Provide a safe working environment;\n'
          '• Refrain from harassment, discrimination, abuse, threats, or unlawful conduct.\n\n'
          'SuperBai reserves the right to suspend or terminate accounts violating this policy.',
    ),
    TermsSection(
      title: '8. Payments & Subscription',
      body:
          'Any subscription fee paid to SuperBai is for access to platform features, management support, coordination services, substitute assistance, and related benefits.\n\n'
          'Subscription fees are generally non-refundable unless expressly stated otherwise.\n\n'
          'Applicable taxes may be charged separately.',
    ),
    TermsSection(
      title: '9. Data & Communication Consent',
      body:
          'By registering, customers consent to:\n'
          '• Receiving service-related calls, SMS, WhatsApp messages, emails, and notifications;\n'
          '• Storage and processing of information required for operating the platform.\n\n'
          'SuperBai will take reasonable steps to protect user information but cannot guarantee absolute security of electronic systems.',
    ),
    TermsSection(
      title: '10. Account Suspension',
      body:
          'SuperBai reserves the right to suspend, restrict, or terminate access to the platform at its sole discretion in cases involving:\n'
          '• Misuse of services;\n'
          '• Fraudulent activity;\n'
          '• Harassment of workers;\n'
          '• False complaints;\n'
          '• Violation of applicable laws;\n'
          '• Breach of these Terms.',
    ),
    TermsSection(
      title: '11. Limitation of Liability',
      body:
          'To the maximum extent permitted by law, SuperBai, its founders, employees, agents, consultants, partners, and affiliates shall not be liable for any direct, indirect, incidental, consequential, special, punitive, or exemplary damages arising from the use of the platform.\n\n'
          'The customer\'s use of the platform is entirely at their own discretion and risk.',
    ),
    TermsSection(
      title: '12. Governing Law',
      body:
          'These Terms & Conditions shall be governed by and construed in accordance with the laws of India.\n\n'
          'Any disputes shall be subject to the exclusive jurisdiction of the courts of Mumbai, Maharashtra.',
    ),
  ];

  static const List<String> customerDeclarations = [
    'I am at least 18 years of age.',
    'I have read and understood these Terms & Conditions.',
    'I voluntarily agree to be bound by these Terms & Conditions.',
    'I understand that SuperBai is a management and coordination platform and not the employer of domestic workers.',
  ];

  // ── Account: Terms of Service ───────────────────────────────────────────────

  static const String intro =
      'These Terms of Service ("Terms") constitute a legally binding agreement between the user ("User", "Customer", "Domestic Worker", "You") and SuperBai Solutions Private Limited ("SuperBai", "Company", "We", "Us", "Our").\n\n'
      'By accessing, registering on, or using the Platform, you acknowledge that you have read, understood, and agreed to be bound by these Terms, the Privacy Policy, and all applicable policies published by SuperBai.';

  static const List<TermsSection> termsSections = [
    TermsSection(
      title: '1. Acceptance of Terms',
      body:
          'These Terms of Service ("Terms") constitute a legally binding agreement between the user ("User", "Customer", "Domestic Worker", "You") and SuperBai Solutions Private Limited ("SuperBai", "Company", "We", "Us", "Our").\n\n'
          'By accessing, registering on, or using the Platform, you acknowledge that you have read, understood, and agreed to be bound by these Terms, the Privacy Policy, and all applicable policies published by SuperBai.',
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
          'Fees are subject to revision upon prior notice.\n\n'
          'Applicable taxes including GST shall be charged in accordance with applicable laws.',
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
          'between SuperBai and any domestic worker.\n\n'
          'SuperBai acts solely as a facilitator and coordinator.',
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
          'Any dispute arising between Customers and Domestic Workers shall remain between the concerned parties.\n\n'
          'SuperBai may assist in communication and dispute management but assumes no liability.',
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
          'SuperBai reserves the right to modify these Terms at any time.\n\n'
          'Continued use of the Platform after publication of revised Terms shall constitute acceptance of such revisions.',
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
          'The seat of arbitration shall be Mumbai, Maharashtra.\n\n'
          'Proceedings shall be conducted in English.',
    ),
    TermsSection(
      title: '23. Governing Law',
      body:
          'These Terms shall be governed by the laws of India.\n\n'
          'Subject to the arbitration clause, courts at Mumbai shall have exclusive jurisdiction.',
    ),
  ];

  // ── Account: Privacy Policy ─────────────────────────────────────────────────

  static const String privacyIntro =
      'SuperBai Solutions Private Limited ("SuperBai", "we", "our", or "us") operates a technology-enabled household workforce management platform that connects households and domestic workers while providing household workforce management, substitute services, scheduling support, communication assistance, and related services.\n\n'
      'This Privacy Policy explains how we collect, use, store, process, share, and protect your personal information when you access or use the SuperBai website, mobile application, WhatsApp services, customer support channels, or any related services (collectively referred to as the "Platform").\n\n'
      'By accessing or using SuperBai, you consent to the collection and processing of your information as described in this Privacy Policy.';

  static const List<TermsSection> privacySections = [
    TermsSection(
      title: '1. Introduction',
      body:
          'Welcome to SuperBai.\n\n'
          'SuperBai Solutions Private Limited ("SuperBai", "we", "our", or "us") operates a technology-enabled household workforce management platform that connects households and domestic workers while providing household workforce management, substitute services, scheduling support, communication assistance, and related services.\n\n'
          'By accessing or using SuperBai, you consent to the collection and processing of your information as described in this Privacy Policy.',
    ),
    TermsSection(
      title: '2. Information We Collect',
      body:
          'A. Customer Information\n'
          'We may collect:\n'
          '• Full Name\n'
          '• Mobile Number\n'
          '• Email Address\n'
          '• Residential Address\n'
          '• Society / Building Information\n'
          '• Profile Details\n'
          '• Service Preferences\n'
          '• Booking Information\n'
          '• Payment Information\n'
          '• Feedback and Support Requests\n\n'
          'B. Domestic Worker Information\n'
          'We may collect:\n'
          '• Full Name\n'
          '• Mobile Number\n'
          '• Residential Address\n'
          '• Emergency Contact Details\n'
          '• Aadhaar or other identity documents\n'
          '• Work Experience\n'
          '• Service Skills\n'
          '• Availability Information\n'
          '• Bank Details (where applicable)\n'
          '• Verification Documents\n'
          '• Profile Photograph (optional)\n\n'
          'C. Technical Information\n'
          'When you use our Platform, we may automatically collect:\n'
          '• Device Information\n'
          '• IP Address\n'
          '• Browser Type\n'
          '• Operating System\n'
          '• Device ID\n'
          '• App Usage Information\n'
          '• Login Activity\n'
          '• Location Data (where permission is granted)\n\n'
          'D. Payment Information\n'
          'Payments made through SuperBai may be processed by third-party payment gateways.\n\n'
          'SuperBai does not store complete debit card, credit card, banking passwords, UPI PINs, or similar sensitive payment credentials.',
    ),
    TermsSection(
      title: '3. How We Collect Information',
      body:
          'We collect information through:\n\n'
          'Directly From You\n'
          'When you:\n'
          '• Register an account\n'
          '• Subscribe to SuperBai Pass\n'
          '• Onboard as a domestic worker\n'
          '• Contact customer support\n'
          '• Submit feedback\n'
          '• Fill forms through the app or WhatsApp\n\n'
          'Automatically\n'
          'Through:\n'
          '• Cookies\n'
          '• Analytics tools\n'
          '• App activity monitoring\n'
          '• Device information\n\n'
          'Through Third Parties\n'
          'Such as:\n'
          '• Payment gateway providers\n'
          '• Verification partners\n'
          '• Referral programs\n'
          '• Society referrals\n'
          '• Domestic worker references',
    ),
    TermsSection(
      title: '4. How We Use Your Information',
      body:
          'We may use your information to:\n'
          '• Create and manage user accounts\n'
          '• Provide household workforce management services\n'
          '• Coordinate substitute services\n'
          '• Facilitate communication between households and workers\n'
          '• Process payments\n'
          '• Generate invoices\n'
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
          'One of SuperBai\'s core services is substitute coordination.\n\n'
          'To facilitate substitute services, SuperBai may use information relating to:\n'
          '• Worker availability\n'
          '• Service preferences\n'
          '• Household requirements\n'
          '• Service schedules\n\n'
          'This information is used solely for workforce coordination and service management.',
    ),
    TermsSection(
      title: '6. Sharing of Information',
      body:
          'We may share limited information with:\n\n'
          'Domestic Workers\n'
          'To facilitate services requested by households.\n\n'
          'Households\n'
          'To facilitate services performed by domestic workers.\n\n'
          'Service Providers\n'
          'Including:\n'
          '• Payment gateway providers\n'
          '• Technology providers\n'
          '• Verification partners\n'
          '• Cloud storage providers\n'
          '• Customer support partners\n\n'
          'Legal Authorities\n'
          'Where required under applicable laws, court orders, governmental directions, or regulatory requirements.',
    ),
    TermsSection(
      title: '7. Information We Do Not Sell',
      body:
          'SuperBai does not sell your personal information to third parties.\n\n'
          'We do not trade, rent, or commercially exploit personal information for unrelated third-party marketing purposes.',
    ),
    TermsSection(
      title: '8. Cookies & Analytics',
      body:
          'SuperBai may use cookies, analytics tools, and similar technologies to:\n'
          '• Improve user experience\n'
          '• Understand platform usage\n'
          '• Monitor system performance\n'
          '• Enhance platform security\n\n'
          'Users may disable cookies through browser settings; however, certain features may not function properly.',
    ),
    TermsSection(
      title: '9. Data Security',
      body:
          'SuperBai implements reasonable security measures to protect personal information, including:\n'
          '• Secure servers\n'
          '• Access controls\n'
          '• Password protection\n'
          '• Data encryption where applicable\n'
          '• Restricted employee access\n\n'
          'However, no electronic system can guarantee absolute security.\n\n'
          'Users acknowledge that transmission of information over the internet carries inherent risks.',
    ),
    TermsSection(
      title: '10. User Responsibilities',
      body:
          'Users are responsible for:\n'
          '• Maintaining account confidentiality\n'
          '• Protecting login credentials\n'
          '• Providing accurate information\n'
          '• Reporting unauthorized account access immediately',
    ),
    TermsSection(
      title: '11. Data Retention',
      body:
          'We retain personal information only for as long as necessary to:\n'
          '• Provide services\n'
          '• Comply with legal obligations\n'
          '• Resolve disputes\n'
          '• Enforce agreements\n'
          '• Maintain business records\n\n'
          'Certain records may be retained even after account closure where required by law.',
    ),
    TermsSection(
      title: '12. Account Deletion',
      body:
          'Users may request deletion of their account by contacting SuperBai Customer Support.\n\n'
          'Upon successful verification and subject to applicable legal requirements:\n'
          '• Platform access may be terminated.\n'
          '• Personal information may be deleted or anonymized.\n\n'
          'Certain records required for compliance, accounting, taxation, fraud prevention, or legal purposes may continue to be retained.',
    ),
    TermsSection(
      title: '13. Communication Consent',
      body:
          'By registering with SuperBai, you consent to receiving:\n'
          '• Calls\n'
          '• SMS\n'
          '• WhatsApp messages\n'
          '• Push notifications\n'
          '• Emails\n\n'
          'related to:\n'
          '• Services\n'
          '• Bookings\n'
          '• Substitute updates\n'
          '• Payments\n'
          '• Customer support\n'
          '• Promotional offers (where permitted)\n\n'
          'Users may opt out of marketing communications at any time.',
    ),
    TermsSection(
      title: '14. Children\'s Privacy',
      body:
          'SuperBai services are intended only for individuals above 18 years of age.\n\n'
          'We do not knowingly collect personal information from minors.',
    ),
    TermsSection(
      title: '15. Business Transfers',
      body:
          'If SuperBai undergoes:\n'
          '• Merger\n'
          '• Acquisition\n'
          '• Investment transaction\n'
          '• Restructuring\n'
          '• Sale of assets\n\n'
          'user information may be transferred as part of such transaction, subject to applicable law.',
    ),
    TermsSection(
      title: '16. Changes to This Policy',
      body:
          'SuperBai reserves the right to update this Privacy Policy from time to time.\n\n'
          'Updated versions will be published on the Platform.\n\n'
          'Continued use of the Platform after such updates constitutes acceptance of the revised Privacy Policy.',
    ),
    TermsSection(
      title: '17. Your Rights',
      body:
          'Subject to applicable law, users may request:\n'
          '• Access to personal information\n'
          '• Correction of inaccurate information\n'
          '• Updating account details\n'
          '• Deletion requests\n'
          '• Withdrawal of consent where legally permissible\n\n'
          'Requests may be submitted through SuperBai Customer Support.',
    ),
    TermsSection(
      title: '18. Third-Party Services',
      body:
          'The Platform may contain links or integrations with third-party services including:\n'
          '• Payment gateways\n'
          '• WhatsApp Business\n'
          '• Google Services\n'
          '• Apple Services\n\n'
          'SuperBai is not responsible for the privacy practices of such third parties.\n\n'
          'Users are encouraged to review their respective privacy policies.',
    ),
    TermsSection(
      title: '19. Contact Us',
      body:
          'For any questions regarding this Privacy Policy, please contact:\n\n'
          'SuperBai Solutions Private Limited\n'
          'Email: superbaisolutions26@gmail.com\n'
          'Website: www.superbai.in',
    ),
  ];

  static const List<String> privacyConsent = [
    'You have read and understood this Privacy Policy.',
    'You consent to the collection, storage, processing, and use of your information as described herein.',
    'You agree to the sharing of information necessary for the provision of SuperBai services.',
  ];

  /// Backwards-compatible alias used by older screens.
  static List<TermsSection> get sections => termsSections;

  /// Backwards-compatible alias for login declarations.
  static List<String> get declarations => customerDeclarations;
}
