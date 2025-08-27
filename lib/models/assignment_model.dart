import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentModel {
  String id;
  String title;
  String description;
  String courseId; // Reference to the Course
  DateTime dueDate;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    required this.dueDate,
  });

  // Factory constructor to create an AssignmentModel from a Firestore document
  factory AssignmentModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AssignmentModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      courseId: data['courseId'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
    );
  }

  // Method to convert AssignmentModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'courseId': courseId,
      'dueDate': Timestamp.fromDate(dueDate),
    };
  }
}
