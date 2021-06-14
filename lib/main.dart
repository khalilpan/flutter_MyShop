import 'package:flutter/material.dart';
import 'package:my_shop/providers/Cart.dart';
import 'package:my_shop/providers/auth.dart';
import 'package:my_shop/providers/orders.dart';
import 'package:my_shop/providers/products_provider.dart';
import 'package:my_shop/screens/auth_screen.dart';
import 'package:my_shop/screens/cart_screen.dart';
import 'package:my_shop/screens/edit_product_screen.dart';
import 'package:my_shop/screens/orders_screen.dart';
import 'package:my_shop/screens/product_detail_screen.dart';
import 'package:my_shop/screens/products_overview_screen.dart';
import 'package:my_shop/screens/splash_screen.dart';
import 'package:my_shop/screens/user_products_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, ProductsProvider>(
            update: (ctx, auth, previousProductsProvider) => ProductsProvider(
                auth.getToke,
                auth.getUserId,
                previousProductsProvider == null
                    ? []
                    : previousProductsProvider.getProductItems),
          ),
          ChangeNotifierProvider(
            create: (ctx) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            update: (ctx, auth, previousOrdersProvider) => Orders(
                auth.getToke,
                auth.getUserId,
                previousOrdersProvider == null
                    ? []
                    : previousOrdersProvider.getOrders),
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'My Shop',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
            ),
            home: auth.getIsAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapShot) =>
                        authResultSnapShot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen()),
            routes: {
              // '/': (ctx) => ProductsOverviewScreen(),
              ProductDetailScreen.routename: (ctx) => ProductDetailScreen(),
              CartScreen.routeCartScreen: (ctx) => CartScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
            },
          ),
        ));
  }
}
