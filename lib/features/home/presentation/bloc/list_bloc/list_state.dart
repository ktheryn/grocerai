part of 'list_bloc.dart';

class ListState extends Equatable {
  final List<GroceryItem> items;
  final int? selectedIndex;
  final double total;
  final String? lastError;
  final bool isChecked;

  const ListState({
    this.items = const [],
    this.selectedIndex,
    this.total = 0.0,
    this.lastError,
    this.isChecked = false,
  });

  @override
  List<Object?> get props => [
    items,
    selectedIndex,
    total,
    lastError,
    isChecked,
  ];

  ListState copyWith({
    List<GroceryItem>? items,
    int? selectedIndex,
    double? total,
    String? lastError,
    bool? isChecked,
  }) {
    return ListState(
      items: items ?? this.items,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      total: total ?? this.total,
      lastError: lastError ?? this.lastError,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
