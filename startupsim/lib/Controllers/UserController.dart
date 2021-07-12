import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserController {
  String _password, _confirmPassword, message, email;
  final _auth = FirebaseAuth.instance;
  User firebaseUser;

  UserController() {
    this.firebaseUser = _auth.currentUser;
  }

  UserController.forgotPassword({String email}) {
    this.email = email;
  }

  UserController.signIn({String email, String password}) {
    this.email = email;
    this._password = password;
  }

  UserController.signUp(
      {String email, String password, String confirmPassword}) {
    this.email = email;
    this._password = password;
    this._confirmPassword = confirmPassword;
  }

  void signUp() async {
    if (_password == _confirmPassword) {
      try {
        await _auth.createUserWithEmailAndPassword(
            email: email, password: _password);
        message = null;
        firebaseUser = _auth.currentUser;
      } catch (e) {
        message = e.message;
      }
    } else {
      message = 'Password and Confirm Password do not match';
    }
  }

  void signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: _password);
      message = null;
      firebaseUser = _auth.currentUser;
    } catch (e) {
      message = e.message;
    }
  }

  void forgotPassword() async {
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
    firebaseUser = _auth.currentUser;
  }

  void signOut() {
    _auth.signOut();
    firebaseUser = _auth.currentUser;
  }

  User currentUser() {
    return _auth.currentUser;
  }
}
