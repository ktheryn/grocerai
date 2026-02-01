import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Import this
import 'package:grocerai/features/home/domain/grocery.dart';
import 'package:grocerai/features/home/presentation/bloc/history_bloc/history_bloc.dart';
import 'package:grocerai/features/home/presentation/widgets/history_detail_modal.dart';
import 'package:intl/intl.dart';

class HistoryItemTile extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  const HistoryItemTile({super.key, required this.docId, required this.data});

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final historyBloc = context.read<HistoryBloc>();
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Delete History"),
          content: const Text("This will be permanently removed. Are you sure?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                historyBloc.add(DeleteHistoryTrip(docId));
                Navigator.of(dialogContext).pop();
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime date = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final double total = (data['totalSpent'] as num?)?.toDouble() ?? 0.0;
    final List itemsRaw = data['items'] ?? [];

    return Slidable(
      key: Key(docId),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => _showDeleteConfirmation(context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          title: Text(DateFormat('MMM dd, yyyy • hh:mm a').format(date)),
          subtitle: Text("${itemsRaw.length} items • Total: \$${total.toStringAsFixed(2)}"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            final List<dynamic> itemsRaw = data['items'] ?? [];
            final List<GroceryItem> items = itemsRaw
                .map((item) => GroceryItem.fromJson(Map<String, dynamic>.from(item)))
                .toList();

            showModalBottomSheet(
              context: context,
              isScrollControlled: true, // Allows the modal to take more height if needed
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => HistoryDetailModal(
                date: date,
                items: items,
                total: total,
              ),
            );
          },
        ),
      ),
    );
  }
}