import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String? id; // Firestore document IDs are Strings
  final String type;
  final int duration;
  final int calories;
  final Timestamp date; // Firestore uses Timestamp for dates

  Activity({
    this.id,
    required this.type,
    required this.duration,
    required this.calories,
    required this.date,
  });

  // A factory constructor to create an Activity from a Firestore document
  factory Activity.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return Activity(
      id: doc.id,
      type: data['type'] ?? '',
      duration: data['duration'] ?? 0,
      calories: data['calories'] ?? 0,
      date: data['date'] ?? Timestamp.now(),
    );
  }

  // A method to convert an Activity object into a Map for uploading to Firestore
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'duration': duration,
      'calories': calories,
      'date': date,
    };
  }
}
