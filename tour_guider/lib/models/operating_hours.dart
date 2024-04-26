// models/operating_hours.dart

class OperatingHours {
  final String openingTime;
  final String closingTime;

  OperatingHours({
    required this.openingTime,
    required this.closingTime,
  });

  // Method to check if the place is currently open
  bool isOpenNow() {
    final currentTime = DateTime.now();
    final openingTimeParts = openingTime.split(':');
    final closingTimeParts = closingTime.split(':');

    final openingHour = int.parse(openingTimeParts[0]);
    final openingMinute = int.parse(openingTimeParts[1]);
    final closingHour = int.parse(closingTimeParts[0]);
    final closingMinute = int.parse(closingTimeParts[1]);

    final openingDateTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      openingHour,
      openingMinute,
    );

    final closingDateTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      closingHour,
      closingMinute,
    );

    // Check if the current time is between opening and closing times
    return currentTime.isAfter(openingDateTime) && currentTime.isBefore(closingDateTime);
  }
}
