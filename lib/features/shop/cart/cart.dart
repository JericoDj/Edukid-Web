import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webedukid/features/shop/cart/widgets/my_cart_items_listview.dart';

import '../../../common/widgets/appbar.dart';
import '../../../common/widgets/loaders/animation_loader.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../controller/product/cart_controller.dart';
import '../screens/checkout/checkout.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = CartController.instance;
    return SizedBox(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight), // Set the height of the AppBar
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0), // Add some top padding for spacing
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Get.back(),
                  ),
                  Text(
                    'Cart',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Obx(() {
          /// Nothing Found Widget
          final emptyWidget = MyAnimationLoaderWidget(
            text: 'Whoops! Cart is EMPTY.',
            animation: MyImages.loaders,
          );
          if (controller.cartItems.isEmpty) {
            return emptyWidget;
          } else {
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                child: const SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(MySizes.defaultspace),

                    ///Items in cart
                    child: SizedBox(width: 500,child: MyCartItemsListView()),
                  ),
                ),
              ),
            );
          }
        }),

        /// checkout button
        bottomNavigationBar: controller.cartItems.isEmpty
            ? SizedBox()
            : Padding(
          padding: EdgeInsets.all(MySizes.defaultspace),
          child: ElevatedButton(
            onPressed: () => Get.to(() => CheckOutScreen()),
            child: Obx(() =>
                Text('Check Out \$${controller.totalCartPrice.value}')),
          ),
        ),
      ),
    );
  }
}
