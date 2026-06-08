class WhatsAppMessages {
  static const String supportNumber = '919819293826';

  static String flexibility({
    String? serviceDate,
    String? currentServiceTime,
    String? requestedServiceTime,
  }) {
    return '''
I would like to use the Flexibility Feature to adjust the timing of my daily maid service.

Please fill the details below:

📅 Service Date: ${serviceDate ?? ''}
⏰ Current Service Time: ${currentServiceTime ?? ''}
⏰ Requested Service Time: ${requestedServiceTime ?? ''}

📌 Note: Requests must be raised at least 12 hours before the scheduled service time.'''
        .trim();
  }

  static String replaceMaid({
    String? maidName,
    String? service,
    String? timeSlot,
  }) {
    return '''
I would like to use the Replacement Feature to replace my current daily maid.

Please fill in the details below:

👤 Name of the Maid: ${maidName ?? ''}
🧹 Service: ${service ?? ''}
⏰ Time Slot of Service: ${timeSlot ?? ''}

📌 Replacement will be provided from Superbai's trusted and verified maid network.'''
        .trim();
  }

  static String superbaiPass({String? houseSize}) {
    return '''
I would like to join the Superbai Pass and enjoy a stress-free household experience.

Please fill in the details below:

🏠 Size of the House: ${houseSize ?? ''}

📌 Note: Your subscription pricing will be based on the size of your house. Our team will review your details and share the payment QR code shortly.'''
        .trim();
  }

  static String instantBooking({
    String? service,
    String? houseSize,
    String? additionalRequirements,
    String? preferredTimeSlot,
  }) {
    return '''
I would like to book a maid through Superbai.

Please find my service requirements below:

🧹 Service: ${service ?? ''}
🏠 Size of House: ${houseSize ?? ''}
➕ Additional Requirements: ${additionalRequirements ?? ''}
⏰ Preferred Time Slot: ${preferredTimeSlot ?? ''}

📌 Note: Based on your requirements, a trusted and verified maid from Superbai's network will be matched for your requested service.'''
        .trim();
  }

  static String complaint({String? natureOfComplaint}) {
    return '''
I would like to use the Complaint Feature to inform Superbai about an issue I am facing with my current maid so that it can be resolved and managed more effectively.

Please share the details below:

📝 Nature of Complaint: ${natureOfComplaint ?? ''}

📌 Note: Our team will review your concern, coordinate with the maid, and work towards an appropriate resolution.'''
        .trim();
  }
}
