import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> signOut() async {
  print(await GoogleSignIn().isSignedIn()); // Should be false

  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();
  print(await GoogleSignIn().isSignedIn()); // Should be false
  print(FirebaseAuth.instance.currentUser);
  print("Signed out");
}
