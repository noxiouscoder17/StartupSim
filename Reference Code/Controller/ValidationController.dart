import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Validation {
  String email;
  String _password;
  String _confirmPassword;
  final _auth = FirebaseAuth.instance;
  User user;
  String message;
  String name;

  Validation() {
    this.user = _auth.currentUser;
  }

  Validation.forgotPassword({String email}) {
    this.email = email;
  }

  Validation.signin({String email, String password}) {
    this.email = email;
    this._password = password;
  }

  Validation.signup({String email, String password, String confirmPassword}) {
    this.email = email;
    this._password = password;
    this._confirmPassword = confirmPassword;
  }

  void signup() async {
    if (_password == _confirmPassword) {
      try {
        await _auth.createUserWithEmailAndPassword(
            email: email, password: _password);
        message = null;
      } catch (e) {
        this.message = e.message;
        print(message);
      }
    } else {
      this.message = 'Password and Confirm Password doesn\'t match';
      print(message);
    }
  }

  void signin() async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: _password);
      message = null;
    } catch (e) {
      message = e.message;
      print('Message: ${message}');
    }
  }

  User currentUser() {
    if (_auth.currentUser != null) {
      user = _auth.currentUser;
      return user;
    } else {
      return null;
    }
  }

  bool isVerified() {
    user = _auth.currentUser;
    return user.emailVerified;
  }

  bool isSignedIn() {
    if (_auth.currentUser != null) {
      return true;
    } else {
      return false;
    }
  }

  void sendEmailVerification() {
    user = _auth.currentUser;
    try {
      user.sendEmailVerification();
      message = null;
    } catch (e) {
      message = e.message;
    }
  }

  void sendResetLink() async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      message = null;
    } catch (e) {
      message = e.message;
    }
  }

  void signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void signOut() {
    _auth.signOut();
  }
}
