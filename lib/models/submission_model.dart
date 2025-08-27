import 'package:cloud_firestore/cloud_firestore.dart';

class SubmissionModel {
  String id;
  String assignmentId;
  String userId;
  String? content; // Can be a link to a file, text, etc.
  DateTime submissionDate;
  int? grade; // Nullable, as it might not be graded yet
  String? feedback;

  SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.userId,
    this.content,
    required this.submissionDate,
    this.grade,
    this.feedback,
  });

  // Factory constructor to create a SubmissionModel from a Firestore document
  factory SubmissionModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubmissionModel(
      id: doc.id,
      assignmentId: data['assignmentId'] ?? '',
      userId: data['userId'] ?? '',
      content: data['content'],
      submissionDate: (data['submissionDate'] as Timestamp).toDate(),
      grade: data['grade'],
      feedback: data['feedback'],
    );
  }

  // Method to convert SubmissionModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'assignmentId': assignmentId,
      'userId': userId,
      'content': content,
      'submissionDate': Timestamp.fromDate(submissionDate),
      'grade': grade,
      'feedback': feedback,
    };
  }
}
