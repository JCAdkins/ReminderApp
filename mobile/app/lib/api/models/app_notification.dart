class AppNotification {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final Map<String, dynamic> payload;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    this.payload = const {},
  });
}
