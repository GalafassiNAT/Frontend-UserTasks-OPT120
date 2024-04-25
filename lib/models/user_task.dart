class UserTask{
  int userId;
  int taskId;
  DateTime delivered;
  double score;
  bool isDelivered;
  bool isDeleted;

  UserTask({
    required this.userId,
    required this.taskId,
    required this.delivered,
    required this.score,
    this.isDelivered = false,
    this.isDeleted = false});

  factory UserTask.fromJson(Map<String, dynamic> json){
    return UserTask(
      userId: json['UserId'] ?? 0,
      taskId: json['TaskId'] ?? 0,
      delivered: json['Delivered'] != null ? DateTime.parse(json['delivered']) : DateTime(0),
      score: json['Score'] ?? 0.00,
      isDelivered: json['IsDelivered'] ?? false,
      isDeleted: json['IsDeleted'] ?? false

    );
  }

  Map<String, dynamic> toJson() => {
    'UserId': userId,
    'TaskId': taskId,
    'Delivered': delivered.toIso8601String(),
    'Score': score
  };

}