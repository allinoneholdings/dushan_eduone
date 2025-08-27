import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/assignment_model.dart';
import '../models/enrollment_model.dart';
import '../models/submission_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- User CRUD Operations ---

  Future<void> addUser(UserModel user) {
    return _firestore.collection('users').add(user.toMap());
  }

  Stream<List<UserModel>> getUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList(),
        );
  }

  Future<void> updateUser(UserModel user) {
    return _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  Future<void> deleteUser(String userId) {
    return _firestore.collection('users').doc(userId).delete();
  }

  // --- Course CRUD Operations ---

  Future<void> addCourse(CourseModel course) {
    return _firestore.collection('courses').add(course.toMap());
  }

  Stream<List<CourseModel>> getCourses() {
    return _firestore
        .collection('courses')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => CourseModel.fromDocument(doc))
                  .toList(),
        );
  }

  Future<void> updateCourse(CourseModel course) {
    return _firestore
        .collection('courses')
        .doc(course.id)
        .update(course.toMap());
  }

  Future<void> deleteCourse(String courseId) {
    return _firestore.collection('courses').doc(courseId).delete();
  }

  // --- Assignment CRUD Operations ---

  Future<void> addAssignment(AssignmentModel assignment) {
    return _firestore.collection('assignments').add(assignment.toMap());
  }

  Stream<List<AssignmentModel>> getAssignments() {
    return _firestore
        .collection('assignments')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => AssignmentModel.fromDocument(doc))
                  .toList(),
        );
  }

  Future<void> updateAssignment(AssignmentModel assignment) {
    return _firestore
        .collection('assignments')
        .doc(assignment.id)
        .update(assignment.toMap());
  }

  Future<void> deleteAssignment(String assignmentId) {
    return _firestore.collection('assignments').doc(assignmentId).delete();
  }

  // --- Enrollment CRUD Operations ---

  Future<void> addEnrollment(EnrollmentModel enrollment) {
    return _firestore.collection('enrollments').add(enrollment.toMap());
  }

  Stream<List<EnrollmentModel>> getEnrollments() {
    return _firestore
        .collection('enrollments')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => EnrollmentModel.fromDocument(doc))
                  .toList(),
        );
  }

  Future<void> updateEnrollment(EnrollmentModel enrollment) {
    return _firestore
        .collection('enrollments')
        .doc(enrollment.id)
        .update(enrollment.toMap());
  }

  Future<void> deleteEnrollment(String enrollmentId) {
    return _firestore.collection('enrollments').doc(enrollmentId).delete();
  }

  // --- Submission CRUD Operations ---

  Future<void> addSubmission(SubmissionModel submission) {
    return _firestore.collection('submissions').add(submission.toMap());
  }

  Stream<List<SubmissionModel>> getSubmissions() {
    return _firestore
        .collection('submissions')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => SubmissionModel.fromDocument(doc))
                  .toList(),
        );
  }

  Future<void> updateSubmission(SubmissionModel submission) {
    return _firestore
        .collection('submissions')
        .doc(submission.id)
        .update(submission.toMap());
  }

  Future<void> deleteSubmission(String submissionId) {
    return _firestore.collection('submissions').doc(submissionId).delete();
  }
}
