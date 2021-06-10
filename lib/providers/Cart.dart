import 'package:flutter/cupertino.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get getItems {
    return {..._items};
  }

  int get itemCount {
    return _items == null ? 0 : _items.length;
  }

  void removeItem(String prodcutId) {
    _items.remove(prodcutId);
    notifyListeners();
  }

  double get getTotalAmount {
    double total = 0.0;
    _items.forEach((key, item) {
      total += (item.price * item.quantity);
    });

    return total;
  }

  void addItemToCart(
    String productId,
    double price,
    String title,
  ) {
    if (_items.containsKey(productId)) {
      //change quantity
      _items.update(
        productId,
        (existingCartItem) => CartItem(
            id: existingCartItem.id,
            title: existingCartItem.title,
            quantity: existingCartItem.quantity + 1,
            price: existingCartItem.price),
      );
    } else {
      //add item
      _items.putIfAbsent(
          productId,
          () => CartItem(
                id: DateTime.now().toString(),
                title: title,
                quantity: 1,
                price: price,
              ));
    }

    notifyListeners();
  }

  void removeSingleItem(String productID) {
    if (!_items.containsKey(productID)) {
      return;
    }
    if (_items[productID].quantity > 1) {
      _items.update(
        productID,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          quantity: existingCartItem.quantity - 1,
          price: existingCartItem.price,
        ),
      );
    } else {
      _items.remove(productID);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
