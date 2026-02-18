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
        DocumentSnapshot uidDoc = await _db
            .collection('users')
            .doc(user.uid)
            .get();

        if (uidDoc.exists) {
          return uidDoc.get('role') as String?;
        }

        DocumentSnapshot emailDoc = await _db
            .collection('users')
            .doc(email)
            .get();

        if (emailDoc.exists) {
          return emailDoc.get('role') as String?;
        }
      }
    } catch (e) {
      print("❌ Login Error: $e");
    }
    return null;
  }

  Future<String?> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String? apartmentId,
  }) async {
    try {
      DocumentSnapshot invitedDoc = await _db
          .collection('users')
          .doc(email)
          .get();

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        if (invitedDoc.exists) {
          await _db.collection('users').doc(email).update({
            'uid': user.uid,
            'phone': phoneNumber,
            'isRegistered': true,
            'status': 'Active',
          });
        } else {
          await _db.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': fullName,
            'email': email,
            'phone': phoneNumber,
            'apartmentId': apartmentId,
            'role': 'Resident',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
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
