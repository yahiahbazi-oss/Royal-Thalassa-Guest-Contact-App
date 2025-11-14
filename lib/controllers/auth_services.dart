import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  // Create account with email and password
  Future<String> createAccountwithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "Account created successfully";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  //login with email and password
  Future<String> loginwithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "login successfully";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  //logout
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  //is signed in
  // check whether the user is sign in or not
  Future<bool> isLoggedIn() async {
    var user = FirebaseAuth.instance.currentUser;
    return user != null;
  }
}
