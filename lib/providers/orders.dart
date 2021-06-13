import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:my_shop/providers/Cart.dart';
import 'package:http/http.dart' as http;

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

  Future<void> addOrder(
    List<CartItem> cartProducts,
    double total,
  ) async {
    final timeStamp = DateTime.now();
    final url = Uri.https(
        'flutter-shop-app-8d3e1-default-rtdb.firebaseio.com', '/orders.json');
    var response = null;
    try {
      response = await http.post(url,
          body: json.encode({
            'amount': total,
            'dateTime': timeStamp.toIso8601String(),
            'products': cartProducts
                .map((element) => {
                      'id': element.id,
                      'title': element.title,
                      'quantity': element.quantity,
                      'price': element.price,
                    })
                .toList()
          }));
    } catch (e) {
      print(e);
    }

    _orders.add(OrderItem(
      json.decode(response.body)['name'],
      total,
      cartProducts,
      timeStamp,
    ));
    notifyListeners();
  }
}
