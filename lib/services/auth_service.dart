import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> loginAndGetRole(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        print("✅ Auth Success! User UID: ${user.uid}");

        DocumentSnapshot doc = await _db
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          String? role = doc.get('role') as String?;
          print("✅ Firestore Found Role: $role");
          return role;
        } else {
          print("❌ Firestore Error: No document found for UID: ${user.uid}");
        }
      }
    } on FirebaseAuthException catch (e) {
      print("❌ Auth Error Code: ${e.code}");
      print("❌ Auth Error Message: ${e.message}");
    } catch (e) {
      print("❌ General Login Error: $e");
    }
    return null;
  }
}
