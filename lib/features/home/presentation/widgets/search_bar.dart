import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocerai/features/home/presentation/bloc/history_bloc/history_bloc.dart';

class SearchHistoryBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (v) => context.read<HistoryBloc>().add(SearchHistory(v)),
        decoration: InputDecoration(
          hintText: "Search items...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // Removes the border stroke
          ),
        ),
      ),
    );
  }
}