import 'package:flutter/cupertino.dart';
import 'package:my_shop/providers/Cart.dart' show Cart;
import 'package:my_shop/widgets/cart_item.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(this.id, this.amount, this.products, this.dateTime);
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get getOrders {
    return [..._orders];
  }

  void addOrder(
    List<CartItem> cartProducts,
    double total,
  ) {
    _orders.add(OrderItem(
        DateTime.now().toString(), total, cartProducts, DateTime.now()));
    notifyListeners();
    
  }
}
