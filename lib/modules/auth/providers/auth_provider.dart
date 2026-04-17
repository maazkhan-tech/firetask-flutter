import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firetask/modules/auth/model/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifierProvider extends Notifier<AuthState> {
  @override
  AuthState build() =>
      AuthState(status: AsyncData(null), action: AuthAction.none);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login
  Future<void> login(String email, String password) async {
    state = AuthState(status: AsyncLoading(), action: AuthAction.login);
    final result = await AsyncValue.guard(() async {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(Duration(seconds: 10));
    });
    state = AuthState(status: result, action: AuthAction.login);
  }
  // Register

  Future<void> register(String email, String password, String username) async {
    state = AuthState(status: AsyncLoading(), action: AuthAction.register);
    final result = await AsyncValue.guard(() async {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;
      await _firestore.collection('users').doc(uid).set({
        'username': username,
        'userId': uid,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
    state = AuthState(status: result, action: AuthAction.register);
  }

  Future logout() async {
    state = AuthState(status: AsyncLoading(), action: AuthAction.logout);
    final result = await AsyncValue.guard(() async => _auth.signOut());
    state = AuthState(status: result, action: AuthAction.logout);
  }
}

final authProvider = NotifierProvider<AuthNotifierProvider, AuthState>(
  () => AuthNotifierProvider(),
);

final authStreamProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

String handleAuthError(FirebaseAuthException e) {
  return switch (e.code) {
    'user-not-found' => 'No account found with this email.',
    'wrong-password' => 'Incorrect password. Please try again.',
    'email-already-in-use' => 'This email is already registered.',
    'weak-password' => 'Password is too weak.',
    'invalid-email' => 'Please enter a valid email address.',
    'user-disabled' => 'This account has been disabled.',
    'too-many-requests' => 'Too many attempts. Please try again later.',
    'operation-not-allowed' => 'Email/password accounts are not enabled.',
    'network-request-failed' => 'Please check your internet connection.',
    'invalid-credential' => 'Invalid login credentials. Please try again.',
    _ => 'An unexpected error occurred. (${e.code})',
  };
}
