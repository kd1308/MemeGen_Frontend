import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign-Up Function with Email Verification
  Future<void> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Send verification email
      await userCredential.user?.sendEmailVerification();
      print("Verification email sent. Please check your inbox.");
    } on FirebaseAuthException catch (e) {
      print('Sign-Up Error: ${e.message}');
    }
  }

  // Sign-In Function with Email Verification Check
  Future<void> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!userCredential.user!.emailVerified) {
        // Sign out the user if not verified
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email before logging in.',
        );
      }
      print("Sign-In Successful");
    } on FirebaseAuthException catch (e) {
      print('Sign-In Error: ${e.message}');
      rethrow;
    }
  }

  // Sign-Out Function
  Future<void> signOut() async {
    await _auth.signOut();
    print("Sign-Out Successful");
  }

  // Get User Initials
  String getUserInitials() {
    final user = _auth.currentUser;
    if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
      List<String> names = user.displayName!.split(" ");
      String initials = names.map((name) => name[0].toUpperCase()).take(2).join();
      return initials;
    }
    return "N/A"; // Default if no name is available
  }
}
