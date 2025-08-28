import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/assignment_model.dart';
import '../models/enrollment_model.dart';
import '../models/submission_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- User CRUD Operations ---

  Future<void> addUser(UserModel user) {
    return _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  // Get a stream of all users
  Stream<List<UserModel>> getUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList(),
        );
  }

  // Get a stream for a single user's profile
  Stream<UserModel?> getUser(String? userId) {
    if (userId == null) {
      return Stream.value(null);
    }
    return _firestore.collection('users').doc(userId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) {
        return null;
      }
      return UserModel.fromDocument(snapshot);
    });
  }

  Future<void> updateUser(UserModel user) {
    return _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  Future<void> deleteUser(String userId) {
    return _firestore.collection('users').doc(userId).delete();
  }

  Stream<bool> isUserAdmin(String? userId) {
    if (userId == null) {
      return Stream.value(false);
    }

    return _firestore.collection('users').doc(userId).snapshots().map((
      snapshot,
    ) {
      final userRole = snapshot.data()?['role'] as String?;
      return userRole == 'Admin';
    });
  }

  Stream<List<UserModel>> getStaffUsers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'Staff')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList(),
        );
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

  Stream<List<CourseModel>> getEnrolledCourses(String userId) {
    // Listen for real-time changes to the 'enrollments' collection
    return _firestore
        .collection('enrollments')
        .where('studentId', isEqualTo: userId)
        .snapshots()
        .asyncMap((enrollmentSnapshot) async {
          // If there are no enrollment documents, return an empty list
          if (enrollmentSnapshot.docs.isEmpty) {
            return [];
          }

          // Extract all course IDs from the enrollment documents
          final List<String> enrolledCourseIds =
              enrollmentSnapshot.docs
                  .map((doc) => doc.data()['courseId'] as String)
                  .toList();

          // Firestore's 'whereIn' query has a limit of 10 items.
          // We need to chunk the list to handle more than 10 courses.
          final List<CourseModel> enrolledCourses = [];
          final int chunkSize = 10;

          // Loop through the list of course IDs in chunks of 10
          for (int i = 0; i < enrolledCourseIds.length; i += chunkSize) {
            final chunk = enrolledCourseIds.sublist(
              i,
              i + chunkSize > enrolledCourseIds.length
                  ? enrolledCourseIds.length
                  : i + chunkSize,
            );

            // Query the 'courses' collection for the current chunk of IDs
            final querySnapshot =
                await _firestore
                    .collection('courses')
                    .where(FieldPath.documentId, whereIn: chunk)
                    .get();

            // Add the fetched courses to the main list
            enrolledCourses.addAll(
              querySnapshot.docs.map((doc) => CourseModel.fromDocument(doc)),
            );
          }

          return enrolledCourses;
        });
  }

  // Add a student to a course's enrolled list
  Future<void> enrollInCourse(String courseId, String userId) async {
    final courseRef = _firestore.collection('courses').doc(courseId);
    final userRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final courseSnapshot = await transaction.get(courseRef);
      final userSnapshot = await transaction.get(userRef);

      if (courseSnapshot.exists && userSnapshot.exists) {
        // Add user to the course's enrolled students list
        List<dynamic> enrolledStudents =
            courseSnapshot.data()!['enrolledStudents'] ?? [];
        if (!enrolledStudents.contains(userId)) {
          enrolledStudents.add(userId);
          transaction.update(courseRef, {'enrolledStudents': enrolledStudents});
        }

        // Add course to the user's enrolled courses list
        List<dynamic> enrolledCourses =
            userSnapshot.data()!['enrolledCourses'] ?? [];
        if (!enrolledCourses.contains(courseId)) {
          enrolledCourses.add(courseId);
          transaction.update(userRef, {'enrolledCourses': enrolledCourses});
        }
      }
    });
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

  /// Retrieves a single instructor's name as a Future<String?>.
  Future<String?> getInstructorName(String? instructorId) async {
    if (instructorId == null) {
      return null;
    }
    try {
      final doc = await _firestore.collection('users').doc(instructorId).get();
      if (doc.exists) {
        return doc.data()?['name'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting instructor name: $e');
      return null;
    }
  }

  Stream<int> getEnrolledCoursesCount(String? userId) {
    // Return a stream with a value of 0 if the userId is null to avoid errors.
    if (userId == null) {
      return Stream.value(0);
    }

    // Query the 'enrollments' collection where 'userId' matches the current user's ID.
    return _firestore
        .collection('enrollments')
        .where('studentId', isEqualTo: userId)
        .snapshots() // Get a stream of query snapshots.
        .map(
          (snapshot) => snapshot.docs.length,
        ); // Map the snapshot to its document count.
  }

  // Get the number of total assignments for a student's enrolled courses
  Stream<int> getTotalAssignmentsCount(String? userId) {
    if (userId == null) {
      return Stream.value(0);
    }
    return _firestore
        .collection('enrollments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((enrollmentSnapshot) async {
          if (enrollmentSnapshot.docs.isEmpty) {
            return 0;
          }
          final List<String> courseIds =
              enrollmentSnapshot.docs
                  .map((doc) => doc['courseId'] as String)
                  .toList();

          final assignmentSnapshot =
              await _firestore
                  .collection('assignments')
                  .where('courseId', whereIn: courseIds)
                  .get();
          return assignmentSnapshot.docs.length;
        });
  }

  // Get the number of submitted assignments by the student
  Stream<int> getCompletedAssignmentsCount(String? userId) {
    if (userId == null) {
      return Stream.value(0);
    }
    return _firestore
        .collection('submissions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<List<CourseModel>> getTop5Courses() {
    return _firestore
        .collection('courses')
        .limit(5)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => CourseModel.fromDocument(doc))
                  .toList(),
        );
  }
}
