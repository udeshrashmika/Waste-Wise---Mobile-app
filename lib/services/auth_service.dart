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

  Future<String?> registerResident({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String apartmentId,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': fullName,
          'email': email,
          'phone': phoneNumber,
          'apartmentId': apartmentId,
          'role': 'Resident',
          'createdAt': FieldValue.serverTimestamp(),
        });
        return "success";
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
    return null;
  }
}
