import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:grocerai/features/home/domain/grocery_category.dart';
import 'package:grocerai/features/home/domain/unit_of_measure.dart';

class GroceryItem extends Equatable {
  final String id;
  final String name;
  final double quantity;
  final UnitOfMeasure unitOfMeasure;
  final GroceryCategory category;
  final double price;
  final bool isChecked;
  final DateTime? lastPurchased;
  final int? frequencyDays;
  final bool isSuggestion;
  final bool isAiGenerated;
  final String? aiReason;

  const GroceryItem({
    required this.id,
    required this.name,
    this.quantity = 1.0,
    this.unitOfMeasure = UnitOfMeasure.pcs,
    this.category = GroceryCategory.other,
    this.price = 0.0,
    this.isChecked = false,
    this.lastPurchased,
    this.frequencyDays,
    this.isSuggestion = false,
    this.isAiGenerated = false,
    this.aiReason,
  });

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: (json['id'] as String?) ?? '',
      name: json['item'] as String,
      quantity: (json['amount'] as num?)?.toDouble() ?? 1.0,
      unitOfMeasure: _parseUnit(json['unit']),
      category: _parseCategory(json['category']),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isChecked: json['isChecked'] as bool? ?? false,
      lastPurchased: _parseDate(json['lastPurchased']),
      frequencyDays: json['frequencyDays'] as int?,
      isSuggestion: json['isSuggestion'] as bool? ?? false,
      isAiGenerated: json['isAiGenerated'] as bool? ?? false, // <--- From JSON
      aiReason: json['aiReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item': name,
      'amount': quantity,
      'unit': unitOfMeasure.name,
      'category': category.name,
      'price': price,
      'isChecked': isChecked,
      'lastPurchased': lastPurchased?.toIso8601String(),
      'frequencyDays': frequencyDays,
      'isSuggestion': isSuggestion,
      'isAiGenerated': isAiGenerated,
      'aiReason': aiReason,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    quantity,
    unitOfMeasure,
    category,
    isChecked,
    lastPurchased,
    isSuggestion,
    isAiGenerated,
    aiReason,
    frequencyDays,
    price,
  ];

  GroceryItem copyWith({
    String? id,
    String? name,
    double? amount,
    UnitOfMeasure? unit,
    GroceryCategory? category,
    double? price,
    bool? isChecked,
    DateTime? lastPurchased,
    int? frequencyDays,
    bool? isSuggestion,
    bool? isAiGenerated,
    String? aiReason,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: amount ?? this.quantity,
      unitOfMeasure: unit ?? this.unitOfMeasure,
      category: category ?? this.category,
      price: price ?? this.price,
      isChecked: isChecked ?? this.isChecked,
      lastPurchased: lastPurchased ?? this.lastPurchased,
      frequencyDays: frequencyDays ?? this.frequencyDays,
      isSuggestion: isSuggestion ?? this.isSuggestion,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      aiReason: aiReason ?? this.aiReason,
    );
  }

  static DateTime? _parseDate(dynamic date) {
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  static UnitOfMeasure _parseUnit(dynamic unit) {
    if (unit is String) {
      return UnitOfMeasure.values.firstWhere(
              (e) => e.name == unit, orElse: () => UnitOfMeasure.pcs);
    }
    return UnitOfMeasure.pcs;
  }

  static GroceryCategory _parseCategory(dynamic category) {
    if (category is String) {
      return GroceryCategory.values.firstWhere(
              (e) => e.name == category, orElse: () => GroceryCategory.other);
    }
    return GroceryCategory.other;
  }
}