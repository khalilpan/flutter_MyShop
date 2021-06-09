import 'package:flutter/material.dart';
import 'package:my_shop/providers/Cart.dart' show Cart;
import 'package:my_shop/widgets/cart_item.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({key}) : super(key: key);

  static const routeCartScreen = '/cartScreen';

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$R${cartProvider.getTotalAmount}',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.title.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  FlatButton(
                    onPressed: () {},
                    child: Text('Order Now'),
                    textColor: Theme.of(context).primaryColor,
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: (ctx, index) => CartItem(
              cartProvider.getItems.values.toList()[index].id,
              cartProvider.getItems.values.toList()[index].price,
              cartProvider.getItems.values.toList()[index].quantity,
              cartProvider.getItems.values.toList()[index].title,
            ),
            itemCount: cartProvider.itemCount,
          ))
        ],
      ),
    );
  }
}
