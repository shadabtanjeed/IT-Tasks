import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'imageUrl': imageUrl,
    'price': price,
    'quantity': quantity,
  };

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
    id: map['id'],
    title: map['title'],
    imageUrl: map['imageUrl'],
    price: map['price'],
    quantity: map['quantity'],
  );
}

class CartProvider extends ChangeNotifier {
  static const _cartKey = 'cart_items';
  List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_cartKey);
    if (data != null) {
      final List decoded = jsonDecode(data);
      _items = decoded.map((e) => CartItem.fromMap(e)).toList();
      notifyListeners();
    }
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_items.map((e) => e.toMap()).toList());
    await prefs.setString(_cartKey, data);
  }

  Future<void> addToCart(CartItem item) async {
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      _items[index].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    await saveCart();
    notifyListeners();
  }

  Future<void> removeFromCart(String id) async {
    _items.removeWhere((e) => e.id == id);
    await saveCart();
    notifyListeners();
  }

  Future<void> updateQuantity(String id, int quantity) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index >= 0 && quantity > 0) {
      _items[index].quantity = quantity;
      await saveCart();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
    notifyListeners();
  }
}
