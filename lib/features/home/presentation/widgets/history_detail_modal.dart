import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocerai/features/home/domain/grocery.dart';
import 'package:grocerai/features/home/presentation/bloc/list_bloc/list_bloc.dart';
import 'package:intl/intl.dart';

class HistoryDetailModal extends StatelessWidget {
  final DateTime date;
  final List<GroceryItem> items;
  final double total;

  const HistoryDetailModal({
    super.key,
    required this.date,
    required this.items,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle/Bar for visual cue
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              DateFormat('MMMM dd, yyyy').format(date),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('hh:mm a').format(date),
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Divider(height: 30),
      
            // List of items
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.name),
                    subtitle: Text("${item.quantity} ${item.unitOfMeasure.name} • ${item.category.name}"),
                    trailing: Text(
                      "\$${item.price.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  );
                },
              ),
            ),
      
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Spent", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  "\$${total.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  context.read<ListBloc>().add(RestoreItemsEvent(items));
                  Navigator. popUntil(context, ModalRoute. withName('/home'));
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Reuse This List"),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}