import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String name;
  final String? description;
  final int suggestedDuration;
  final DateTime startDate;
  final int totalDaysCompleted;

  Habit({
    required this.id,
    required this.name,
    this.description,
    required this.suggestedDuration,
    required this.startDate,
    required this.totalDaysCompleted,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      suggestedDuration: json['suggestedDuration'],
      startDate: (json['startDate'] as Timestamp).toDate(),
      totalDaysCompleted: json['totalDaysCompleted'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'suggestedDuration': suggestedDuration,
      'startDate': Timestamp.fromDate(startDate),
      'totalDaysCompleted': totalDaysCompleted,
    };
  }
}
