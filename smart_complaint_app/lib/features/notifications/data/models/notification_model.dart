class NotificationModel {
  final String id;
  final String firebaseUID;
  final String title;
  final String message;
  final String type;
  final String? complaintId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.firebaseUID,
    required this.title,
    required this.message,
    required this.type,
    this.complaintId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      firebaseUID: json['firebaseUID'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      complaintId: json['complaintId'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
