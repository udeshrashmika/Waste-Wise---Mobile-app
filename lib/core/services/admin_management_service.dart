import 'package:cloud_firestore/cloud_firestore.dart';

class AdminManagementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> inviteDriver(String name, String email, String vehicle) async {
    await _db.collection('users').doc(email).set({
      'name': name,
      'email': email,
      'vehicleNumber': vehicle,
      'role': 'Truck Driver',
      'isApproved': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeUser(String docId) async {
    await _db.collection('users').doc(docId).delete();
  }

  Stream<QuerySnapshot> getDrivers() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'Truck Driver')
        .snapshots();
  }
}
