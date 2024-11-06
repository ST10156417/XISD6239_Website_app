import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sokeconsulting/Services/database_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Register user with email and password
  Future<String> registerUserWithEmailandPassword(String fullname, String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await DatabaseService(uid: user.uid).updateUserData(fullname, email);
        await user.updateDisplayName(fullname);
        await user.reload();
        
        return 'success'; // Registration succeeded
      } else {
        return 'User creation failed';
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already registered';
        case 'weak-password':
          return 'The password is too weak';
        case 'invalid-email':
          return 'The email address is invalid';
        default:
          return e.message ?? "An unknown Firebase error occurred";
      }
    } catch (e) {
      return "An unknown error occurred: ${e.toString()}";
    }
  }

  // Login user with email and password
  Future<bool> loginUserWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true; // Successful login
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          print("No user found for this email.");
          break;
        case 'wrong-password':
          print("Wrong password provided.");
          break;
        case 'invalid-email':
          print("Invalid email address.");
          break;
        default:
          print(e.message ?? "An unknown Firebase error occurred");
      }
      return false; // Login failed
    } catch (e) {
      print("An unknown error occurred: ${e.toString()}");
      return false;
    }
  }

  // Logout user
  Future<void> logoutUser() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut(); // Sign out from Google as well
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return false; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      // Optionally save user data in the database
      if (userCredential.user != null) {
        await DatabaseService(uid: userCredential.user!.uid).updateUserData(
          userCredential.user!.displayName ?? 'Unnamed',
          userCredential.user!.email ?? 'No Email',
        );
      }
      
      return true; // Sign-in successful
    } catch (e) {
      print("Google sign-in error: $e");
      return false; // Sign-in failed
    }
  }

  // Other existing methods...

  // Retrieve current user's display name
  Future<String?> getCurrentUserName() async {
    User? user = _firebaseAuth.currentUser;
    return user?.displayName; 
  }

  // Retrieve current user's UID
  String? getCurrentUserId() {
    User? user = _firebaseAuth.currentUser;
    return user?.uid; 
  }
}
