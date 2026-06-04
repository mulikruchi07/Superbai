/// Thrown when a maid already has a booking overlapping the requested slot.
class MaidSlotUnavailableException implements Exception {
  const MaidSlotUnavailableException([
    this.message =
        'This maid is already booked for the selected time. '
        'Please choose another slot or maid.',
  ]);

  final String message;

  @override
  String toString() => message;
}
