import 'package:cloud_firestore/cloud_firestore.dart';

class GroceryItem {
  String item;
  double amount;
  String unit;
  String category;
  double price;
  bool isChecked;
  DateTime? lastPurchased;
  int? frequencyDays;
  bool isSuggestion;
  String? aiReason;

  GroceryItem({
    required this.item,
    this.amount = 1.0,
    this.unit = 'pcs',
    this.category = 'Other',
    this.price = 0.0,
    this.isChecked = false,
    this.lastPurchased,
    this.frequencyDays,
    this.isSuggestion = false,
    this.aiReason,
  });

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      item: json['item'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] as String? ?? 'pcs',
      category: json['category'] as String? ?? 'Other',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isChecked: json['isChecked'] as bool? ?? false,
      lastPurchased: json['lastPurchased'] != null
          ? (json['lastPurchased'] as Timestamp).toDate()
          : null,
      frequencyDays: json['frequencyDays'] as int?,
      isSuggestion: json['isSuggestion'] as bool? ?? false,
      aiReason: json['aiReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'amount': amount,
      'unit': unit,
      'category': category,
      'price': price,
      'isChecked': isChecked,
      'lastPurchased': lastPurchased,
      'frequencyDays': frequencyDays,
      'isSuggestion': isSuggestion,
      'aiReason': aiReason,
    };
  }
}
