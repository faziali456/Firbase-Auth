import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {

  Future<String> currentUser();
  Future<FirebaseUser> signInViaEmail(String email, String password);
  Future<FirebaseUser> createUser(String email, String password);
  Future<void> signOut();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<FirebaseUser> signInViaEmail(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return user;
  }

  Future<FirebaseUser> createUser(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return user;
  }

  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    if (user != null) {
      return user.uid;
    } else {
      return null;
    }
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

}