
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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
    return Scaffold(
      appBar: MyAppBar(
        showBackArrow: true,
        title: Text(
          'Cart',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Obx(() {
        /// Nothing Found Widget
        final emptyWidget = MyAnimationLoaderWidget(
          text: 'Whoops! Cart is EMPTY.',
          animation: MyImages.loaders,

          /// showAction: true,
          /// if want to use this
          ///actionText: 'Let\'s fill it',
          ///onActionPressed: () => Get.off(() => const NavigationBarMenu()),
        );
        if (controller.cartItems.isEmpty) {
          return emptyWidget;
        } else {
          return const SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(MySizes.defaultspace),

              ///Items in cart
              child: MyCartItemsListView(),
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
    );
  }
}
