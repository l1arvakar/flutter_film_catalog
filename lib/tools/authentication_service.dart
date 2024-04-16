import 'package:flutter_film_catalog/tools/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_film_catalog/models/user.dart' as models;

class AuthenticationService {
  final _auth = FirebaseAuth.instance;

  models.User? _userFromFirebaseUser(User? user) {
    return user != null ? models.User(uid: user.uid) : null;
  }

  Stream<models.User?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      await DatabaseService(uid: user!.uid)
          .createUserData();

      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future deleteAccount() async {
    var uid = _auth.currentUser?.uid;
    try {
      await _auth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      print(e.toString());

      if (e.code == "requires-recent-login") {
        await _reauthenticateAndDelete();
      } else {
        print(e.toString());
      }
    } catch (e) {
      print(e.toString());
    }
    await DatabaseService(uid: uid).deleteUserData();
  }

  Future<void> _reauthenticateAndDelete() async {
    try {
      final providerData = _auth.currentUser?.providerData.first;

      if (AppleAuthProvider().providerId == providerData!.providerId) {
        await _auth.currentUser!
            .reauthenticateWithProvider(AppleAuthProvider());
      } else if (GoogleAuthProvider().providerId == providerData.providerId) {
        await _auth.currentUser!
            .reauthenticateWithProvider(GoogleAuthProvider());
      }

      await _auth.currentUser?.delete();
    } catch (e) {
      print(e.toString());
    }
  }
}
