import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocerai/locator.dart';

class HistoryGroceryRepository {
  final FirebaseFirestore _fireStore = getIt<FirebaseFirestore>();
  final FirebaseAuth _auth = getIt<FirebaseAuth>();

  CollectionReference get _historyRef => _fireStore
      .collection('users')
      .doc(_auth.currentUser?.uid)
      .collection('grocery_history');

  Stream<List<QueryDocumentSnapshot>> getHistoryStream() {
    return _historyRef
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<void> deleteHistoryTrip(String docId) async {
    await _historyRef.doc(docId).delete();
  }
}