/// Production collections linked to a customer [User] document reference.
class UserRelatedFields {
  UserRelatedFields._();

  static const transactionCollection = 'Transaction';
  static const complaintCollection = 'Complaint';
  static const reviewCollection = 'Review';
  static const otpsCollection = 'OTPs';

  static const user = 'User';
  static const transaction = 'Transaction';
  static const phoneNumber = 'phoneNumber';

  static const legacyFactBookings = 'FACT_BOOKINGS';
  static const legacyDimUsers = 'DIM_USERS';
  static const legacyDimServices = 'DIM_SERVICES';
  static const legacyDimTimeSlots = 'DIM_TIME_SLOTS';
  static const legacyDimSalary = 'DIM_SALARY';
  static const legacyUserId = 'UserID';
  static const legacyServiceId = 'ServiceID';
  static const legacyTimeSlotId = 'TimeSlotID';
  static const legacySalaryId = 'SalaryID';
}
