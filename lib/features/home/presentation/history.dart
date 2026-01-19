import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grocerai/features/home/domain/grocery.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // Function to delete a specific trip from Firestore
  Future<void> _deleteTrip(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('history')
          .doc(docId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Trip deleted from history")),
        );
      }
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping History"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search by item name...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = "");
                })
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('history')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error loading history"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          // Filter documents based on search query
          final allDocs = snapshot.data!.docs;
          final filteredDocs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final List items = data['items'] ?? [];
            // Check if any item name in the list matches the search query
            return items.any((item) =>
                (item['item'] as String).toLowerCase().contains(_searchQuery));
          }).toList();

          if (filteredDocs.isEmpty) {
            return const Center(child: Text("No matching history found."));
          }

          return ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final DateTime date = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
              final double total = (data['totalSpent'] as num?)?.toDouble() ?? 0.0;
              final List itemsRaw = data['items'] ?? [];

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Delete Record?"),
                      content: const Text("This will permanently remove this trip from your history."),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) => _deleteTrip(doc.id),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(DateFormat('MMM dd, yyyy • hh:mm a').format(date)),
                    subtitle: Text("${itemsRaw.length} items • Total: \$${total.toStringAsFixed(2)}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.settings_backup_restore, color: Colors.deepPurple),
                      onPressed: () => _restoreList(context, itemsRaw),
                    ),
                    onTap: () => _showTripDetails(context, itemsRaw, total),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _restoreList(BuildContext context, List itemsRaw) {
    List<GroceryItem> restoredItems = itemsRaw.map((itemData) {
      final item = GroceryItem.fromJson(itemData as Map<String, dynamic>);
      item.isChecked = false;
      return item;
    }).toList();
    Navigator.pop(context, restoredItems);
  }

  void _showTripDetails(BuildContext context, List items, double total) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text("Trip Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item['item'] ?? 'Unknown'),
                      subtitle: Text("${item['amount']} ${item['unit']}"),
                      trailing: Text("\$${(item['price'] as num).toStringAsFixed(2)}"),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}