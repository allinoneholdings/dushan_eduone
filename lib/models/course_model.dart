import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  String id;
  String name;
  String description;
  String instructor;

  CourseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.instructor,
  });

  // Factory constructor to create a CourseModel from a Firestore document
  factory CourseModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CourseModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      instructor: data['instructor'] ?? '',
    );
  }

  // Method to convert CourseModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'instructor': instructor,
    };
  }
}
