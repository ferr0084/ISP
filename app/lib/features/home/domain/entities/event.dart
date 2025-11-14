

class Event {
  final String month; // e.g., "SEP"
  final String day; // e.g., "28"
  final String title;
  final String timeLocation; // e.g., "10:00 AM - Conference Room"

  Event({
    required this.month,
    required this.day,
    required this.title,
    required this.timeLocation,
  });
}