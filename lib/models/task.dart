class Task{
  int id;
  String title;
  String description;
  DateTime deliveryDate;

  Task({required this.id, required this.title,
    required this.description, required this.deliveryDate});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      deliveryDate: DateTime.parse(json['deliveryDate']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'deliveryDate': deliveryDate.toIso8601String(),
  };
}