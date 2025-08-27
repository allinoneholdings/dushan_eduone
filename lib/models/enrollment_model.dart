import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollmentModel {
  String id;
  String courseId;
  String userId;
  DateTime enrollmentDate;

  EnrollmentModel({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.enrollmentDate,
  });

  // Factory constructor to create an EnrollmentModel from a Firestore document
  factory EnrollmentModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EnrollmentModel(
      id: doc.id,
      courseId: data['courseId'] ?? '',
      userId: data['userId'] ?? '',
      enrollmentDate: (data['enrollmentDate'] as Timestamp).toDate(),
    );
  }

  // Method to convert EnrollmentModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'userId': userId,
      'enrollmentDate': Timestamp.fromDate(enrollmentDate),
    };
  }
}
