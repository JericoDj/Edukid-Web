import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/products/cart/add_remove_button.dart';
import '../../../../common/widgets/products/cart/cart_item.dart';
import '../../../../common/widgets/texts/product_price_text.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller/product/cart_controller.dart';

class MyCartItemsListView extends StatelessWidget {
  const MyCartItemsListView({
    Key? key,
    this.showAddRemoveButtons = true,
  }) : super(key: key);

  final bool showAddRemoveButtons;

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;

    return Obx(
          () => ListView.separated(
        shrinkWrap: true,
        itemCount: cartController.cartItems.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: MySizes.spaceBtwSections),
        itemBuilder: (_, index) => Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            color: Colors.red,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
          ),
          confirmDismiss: (direction) async {
            Completer<bool> completer = Completer<bool>();

            await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Remove Product'),
                  content:
                  Text('Are you sure you want to remove this product?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        completer.complete(false);
                        Get.back();
                      },
                      child: Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        completer.complete(true);
                        Get.back();
                      },
                      child: Text('Yes'),
                    ),
                  ],
                );
              },
            );

            return completer.future;
          },
          onDismissed: (direction) {
            cartController.removeFromCart(index);
          },
          child: Column(
            children: [
              /// Cart Item
              MyCartItem(cartItem: cartController.cartItems[index]),
              if (showAddRemoveButtons)
                SizedBox(height: MySizes.spaceBtwItems),

              /// add remove button row with total price
              if (showAddRemoveButtons)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        /// extra space
                        SizedBox(width: 70),

                        /// add remove buttons
                        MyProductQuantityWithAddRemoveButton(
                          quantity: cartController.cartItems[index].quantity,
                          add: () => cartController.addOneToCart(
                              cartController.cartItems[index]),
                          remove: () => cartController.removeOneFromCart(
                              cartController.cartItems[index]),
                        ),
                      ],
                    ),
                    MyProductPriceText(
                      price: (cartController.cartItems[index].price *
                          cartController.cartItems[index].quantity)
                          .toStringAsFixed(1),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}



