import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocerai/features/home/domain/grocery.dart';
import 'package:grocerai/locator.dart';

class ArchiveRepository {
  final FirebaseFirestore _fireStore = getIt<FirebaseFirestore>();
  final FirebaseAuth _auth = getIt<FirebaseAuth>();

  Future<void> archiveTrip({
    required List<GroceryItem> items,
    required double totalSpent,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User must be logged in to archive.");

    final historyRef = _fireStore
        .collection('users')
        .doc(user.uid)
        .collection('grocery_history')
        .doc();

    final now = DateTime.now();

    final updatedItems = items.map((item) {
      return item.copyWith(lastPurchased: now).toJson();
    }).toList();

    final data = {
      'timestamp': FieldValue.serverTimestamp(),
      'totalSpent': totalSpent,
      'items': updatedItems,
    };

    await historyRef.set(data);
  }
}