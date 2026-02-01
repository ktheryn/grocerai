import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getUserName() async {
    final user = _auth.currentUser;
    if (user == null) return "Shopper";

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (doc.exists && doc.data() != null) {
      return doc.data()!['fullName'] ?? "Shopper";
    }
    return "Shopper";
  }
}