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
  String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get getOrders {
    return [..._orders];
  }

  Future<void> addOrder(
    List<CartItem> cartProducts,
    double total,
  ) async {
    final timeStamp = DateTime.now();
    final url = Uri.parse(
        'https://flutter-shop-app-8d3e1-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
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

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://flutter-shop-app-8d3e1-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');

    final response = await http.get(url);
    print(json.decode(response.body));

    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
        orderId,
        orderData['amount'],
        (orderData['products'] as List<dynamic>)
            .map(
              (item) => CartItem(
                  id: item['id'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: item['price']),
            )
            .toList(),
        DateTime.parse(orderData['dateTime']),
      ));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }
}
