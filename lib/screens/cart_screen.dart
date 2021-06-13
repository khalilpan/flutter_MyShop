import 'package:flutter/material.dart';
import 'package:my_shop/providers/Cart.dart' show Cart;
import 'package:my_shop/providers/orders.dart';
import 'package:my_shop/widgets/cart_item.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({key}) : super(key: key);

  static const routeCartScreen = '/cartScreen';

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<Cart>(context);
    final ordersProvider = Provider.of<Orders>(context, listen: false);

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
                      '\$R${cartProvider.getTotalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.title.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(
                      cartProvider: cartProvider,
                      ordersProvider: ordersProvider),
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
              cartProvider.getItems.keys.toList()[index],
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

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cartProvider,
    @required this.ordersProvider,
  }) : super(key: key);

  final Cart cartProvider;
  final Orders ordersProvider;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (widget.cartProvider.getTotalAmount <= 0 || _isLoading == true)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });

              await widget.ordersProvider.addOrder(
                widget.cartProvider.getItems.values.toList(),
                widget.cartProvider.getTotalAmount,
              );
              setState(() {
                _isLoading = false;
              });
              widget.cartProvider.clear();
            },
      child: _isLoading ? CircularProgressIndicator() : Text('Order Now'),
      textColor: Theme.of(context).primaryColor,
    );
  }
}
