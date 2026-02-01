import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocerai/features/home/presentation/bloc/history_bloc/history_bloc.dart';
import 'package:grocerai/features/home/presentation/widgets/history_item_tile.dart';
import 'package:grocerai/features/home/presentation/widgets/search_bar.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping History"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: SearchHistoryBar(),
        ),
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) return const Center(child: CircularProgressIndicator());
          if (state is HistoryError) return Center(child: Text(state.message));

          if (state is HistoryLoaded) {
            if (state.trips.isEmpty) return const Center(child: Text("No records found."));

            return ListView.builder(
              itemCount: state.trips.length,
              itemBuilder: (context, index) {
                final doc = state.trips[index];
                final data = doc.data() as Map<String, dynamic>;
                return HistoryItemTile(docId: doc.id, data: data);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}