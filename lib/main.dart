import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Represenst a Cart Item. Has <int>`id`, <String>`name`, <int>`quantity`
class CartItem {
  int id;
  String name;
  int quantity;

  CartItem(this.id, this.name, this.quantity);
}

/// Manages a cart. Implements ChangeNotifier
class CartState with ChangeNotifier {
  List<CartItem> _products = [];

  CartState();

  /// The number of individual items in the cart. That is, all cart items' quantities.
  int get totalCartItems => _products.fold(0, (previousValue, element) => previousValue + element.quantity);

  /// The list of CartItems in the cart
  List<CartItem> get products => _products;

  /// Clears the cart. Notifies any consumers.
  void clearCart() {
    _products.clear();
    notifyListeners();
  }

  /// Adds a new CartItem to the cart. Notifies any consumers.
  void addToCart({required CartItem item}) {
    _products.add(item);
    notifyListeners();
  }

  /// Updates the quantity of the Cart item with this id. Notifies any consumers.
  void updateQuantity({required int id, required int newQty}) {
    _products[_products.indexWhere((element) => element.id == id)].quantity = newQty;
    notifyListeners();
  }

  /// Removes an item from the cart with this id. Notifies any consumers.
  void removeFromCart({required int id}) {
    _products.removeWhere((element) => element.id == id);
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartState(),
      child: MyCartApp(),
    ),
  );
}

class MyCartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          child: Column(
            children: [
              ListOfCartItems(),
              CartSummary(),
              CartControls(),
            ],
          ),
        ),
      ),
    );
  }
}

class CartControls extends StatelessWidget {
  /// Handler for Add Item pressed
  void _addItemPressed(BuildContext context) {
    /// mostly unique cartItemId.
    /// don't change this; not important for this test
    int nextCartItemId = Random().nextInt(10000);
    String nextCartItemName = 'A cart item';
    int nextCartItemQuantity = 1;

    CartItem
        item = new CartItem(nextCartItemId, nextCartItemName, nextCartItemQuantity); // Actually use the CartItem constructor to assign id, name and quantity

    Provider.of<CartState>(context, listen: false).addToCart(item: item);
  }

  /// Handle clear cart pressed. Should clear the cart
  void _clearCartPressed(BuildContext context) {
    Provider.of<CartState>(context, listen: false).clearCart();
  }

  @override
  Widget build(BuildContext context) {
    final Widget addCartItemWidget = TextButton(
      child: Text('Add Item'),
      onPressed: () {
        _addItemPressed(context);
      },
    );

    final Widget clearCartWidget = TextButton(
      child: Text('Clear Cart'),
      onPressed: () {
        _clearCartPressed(context);
      },
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        addCartItemWidget,
        clearCartWidget,
      ],
    );
  }
}

class ListOfCartItems extends StatelessWidget {
  /// Handles adding 1 to the current cart item quantity.
  void _incrementQuantity(context, int id, int delta) {
    Provider.of<CartState>(context, listen: false).updateQuantity(id: id, newQty: Provider.of<CartState>(context, listen: false).products[Provider.of<CartState>(context, listen: false).products.indexWhere((element) => element.id == id)].quantity+1);
  }

  /// Handles removing 1 to the current cart item quantity.
  /// Don't forget: we can't have negative numbers of an item in the cart
  void _decrementQuantity(context, int id, int delta) {
    if (Provider.of<CartState>(context, listen: false).products[Provider.of<CartState>(context, listen: false).products.indexWhere((element) => element.id == id)].quantity > 0) {
      Provider.of<CartState>(context, listen: false).updateQuantity(id: id, newQty: Provider.of<CartState>(context, listen: false).products[Provider.of<CartState>(context, listen: false).products.indexWhere((element) => element.id == id)].quantity-1);
    }
    if (Provider.of<CartState>(context, listen: false).products[Provider.of<CartState>(context, listen: false).products.indexWhere((element) => element.id == id)].quantity == 0) {
      Provider.of<CartState>(context, listen: false).removeFromCart(id: id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartState>(
        builder: (BuildContext context, CartState cart, Widget? child) {
      if (cart.totalCartItems == 0) {
        return Text("There are no items in the cart.");
      }

      return Column(children: [
        ...cart.products.map(
          (c) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(c.name + " x " + c.quantity.toString()),
                //  Current quantity should update whenever a change occurs.
                
                TextButton(onPressed: () => _incrementQuantity(context, c.id, 1), child: Text('+')),
                TextButton(onPressed: () => _decrementQuantity(context, c.id, 1), child: Text('-')),
              ],
            ),
          ),
        ),
      ]);
    });
  }
}

class CartSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartState>(
      builder: (BuildContext context, CartState cart, Widget? child) {
        return Column(children: [
          Text("Total items: ${cart.totalCartItems}"),
          Image.network('https://image.shutterstock.com/image-vector/shopping-cart-vector-icon-flat-260nw-1690453492.jpg')
        ]);
      },
    );
  }
}
