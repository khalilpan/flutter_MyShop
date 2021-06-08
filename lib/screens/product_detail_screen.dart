import 'package:flutter/material.dart';
import 'package:my_shop/providers/products_provider.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({key}) : super(key: key);

  static const routename = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final productsProvider = Provider.of<ProductsProvider>(
      context,
      listen: false,
    );
    final prodcutToShow = productsProvider.getProductById(productId);

    return Scaffold(
      appBar: AppBar(
        title: Text(prodcutToShow.title),
      ),
    );
  }
}
