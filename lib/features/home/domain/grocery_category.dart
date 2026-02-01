import 'package:flutter/material.dart';

enum GroceryCategory {
  produce('Produce', Icons.local_grocery_store),
  dairy('Dairy & Eggs', Icons.egg),
  bakery('Bakery', Icons.bakery_dining),
  meat('Meat & Poultry', Icons.kebab_dining),
  seafood('Seafood', Icons.set_meal),
  frozen('Frozen Foods', Icons.ac_unit),
  pantry('Pantry', Icons.kitchen),
  beverages('Beverages', Icons.local_drink),
  household('Household', Icons.cleaning_services),
  other('Other', Icons.more_horiz);

  final String displayName;
  final IconData icon;

  const GroceryCategory(this.displayName, this.icon);
}