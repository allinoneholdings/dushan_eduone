import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// This service handles all Firebase Authentication and Firestore user data operations.
// By separating this logic from the UI, we make the app more maintainable and testable.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen for real-time authentication state changes.
  // This is a great way to automatically update the UI when a user signs in or out.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Method to create a new user with email and password.
  // It also saves additional user data to Firestore.
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the user's display name immediately after creation.
      await userCredential.user?.updateDisplayName(name);

      // Save user-specific data (name, email, role) to a Firestore collection.
      // This is helpful for storing information not included in the standard Auth user object.
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException {
      rethrow; // Re-throw the exception to be handled by the UI.
    } catch (e) {
      debugPrint('Error during sign up: $e');
      return null;
    }
  }

  // Method to sign in an existing user with email and password.
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      rethrow; // Re-throw the exception to be handled by the UI.
    } catch (e) {
      debugPrint('Error during sign in: $e');
      return null;
    }
  }

  // Method to sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
