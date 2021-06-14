import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:my_shop/http_exception/heep_exception.dart';
import 'package:my_shop/providers/models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductsProvider with ChangeNotifier {
  var _showFavoritesOnly = false;
  String _authTekon;

  ProductsProvider(this._authTekon, this._productItems);

  List<Product> _productItems = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get getProductItems {
    return [..._productItems];
  }

  List<Product> get getFavorites {
    return [..._productItems.where((element) => element.isFavorite == true)];
  }

  Product getProductById(String id) {
    return _productItems.firstWhere((item) => item.id == id);
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https(
        'flutter-shop-app-8d3e1-default-rtdb.firebaseio.com', '/products.json');
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'isFavorite': product.isFavorite,
          }));

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _productItems.add(newProduct);
      // _productItems.insert(0, newProduct); //add to the begging of the list
      print(response);

      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _productItems.indexWhere((item) => item.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https(
          'flutter-shop-app-8d3e1-default-rtdb.firebaseio.com',
          '/products/$id.json');
      try {
        await http.patch(url,
            body: json.encode({
              'title': newProduct.title,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl,
              'price': newProduct.price,
            }));
      } catch (error) {
        print(error);
      }
//converting map to Json
      _productItems[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('Product not found.');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.https('flutter-shop-app-8d3e1-default-rtdb.firebaseio.com',
        '/products/$id.json');
    final existingProductIndex =
        _productItems.indexWhere((element) => element.id == id);
    final existingProduct = _productItems[existingProductIndex];
    _productItems.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _productItems.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete the product.');
    }
  }

  Future<Void> fetchAndSetProducts() async {
    final url = Uri.parse(
        'https://flutter-shop-app-8d3e1-default-rtdb.firebaseio.com/products.json?auth=$_authTekon');
    try {
      final response = await http.get(url);
      // print(json.decode(response.body));
      final extraxtedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];

      // if (extraxtedData == null) {
      //   return;
      // }

      extraxtedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
        ));
      });
      _productItems = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }
}
