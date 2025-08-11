import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuth {
  BuildContext context;
  AppleAuth({required this.context});
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInWithApple() async {
    if (!Platform.isIOS) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Apple sign-in is only available on iOS.')),
      );
      return null;
    }

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    final UserCredential userCredential = await _auth.signInWithCredential(
      oauthCredential,
    );
    return userCredential.user;
  }
}
