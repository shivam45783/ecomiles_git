import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:EcoMiles/provider/loadingProvider.dart';
import 'package:provider/provider.dart';

// import '';
class GoogleAuth {
  BuildContext context;
  GoogleAuth({required this.context});
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<bool> isUserSignedInWithGoogle() async {
    return await _googleSignIn.isSignedIn();
  }

  // String accessToken = "";
  Future<User?> signInWithGoogle() async {
    final loadingInstance = Provider.of<LoadingProvider>(
      context,
      listen: false,
    );
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      loadingInstance.show();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      // loadingInstance.hide();
      return userCredential.user;
    } catch (e) {
      // loadingInstance.hide();
      print("Google sign-in error: $e");

      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    print(FirebaseAuth.instance.currentUser);
    print("Signed out");
  }
}
