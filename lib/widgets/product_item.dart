import 'package:flutter/material.dart';
import 'package:my_shop/providers/Cart.dart';
import 'package:my_shop/providers/auth.dart';
import 'package:my_shop/providers/models/product.dart';
import 'package:my_shop/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context, listen: false);
    final productToShow = Provider.of<Product>(context);
    final cart = Provider.of<Cart>(
      context,
      listen: false,
    );

    return GridTile(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(ProductDetailScreen.routename,
              arguments: productToShow.id);
        },
        child: Image.network(
          productToShow.imageUrl,
          fit: BoxFit.cover,
        ),
      ),
      footer: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(
            productToShow.title,
            textAlign: TextAlign.center,
          ),
          leading: IconButton(
            onPressed: () {
              productToShow.toggleFavorite(
                authProvider.getToke,
                authProvider.getUserId,
              );
            },
            icon: Icon(productToShow.isFavorite
                ? Icons.favorite
                : Icons.favorite_border),
            color: Theme.of(context).accentColor,
          ),
          trailing: IconButton(
            onPressed: () {
              cart.addItemToCart(
                productToShow.id,
                productToShow.price,
                productToShow.title,
              );
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Added item to Cart!',
                    textAlign: TextAlign.center,
                  ),
                  duration: Duration(
                    seconds: 2,
                  ),
                  action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        cart.removeSingleItem(productToShow.id);
                      }),
                ),
              );
            },
            icon: Icon(Icons.shopping_cart),
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
