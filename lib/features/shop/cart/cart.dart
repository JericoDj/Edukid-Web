import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webedukid/custom_app_bar.dart';
import 'package:webedukid/features/shop/cart/widgets/my_cart_items_listview.dart';
import '../../../common/widgets/appbar.dart';
import '../../../common/widgets/loaders/animation_loader.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../screens/navigation_controller.dart';  // Import NavigationController
import '../controller/product/cart_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = CartController.instance;
    final navigationController = Get.find<NavigationController>();  // Get NavigationController instance

    return SizedBox(
      child: Scaffold(
        body: Obx(() {
          // Display message if the cart is empty
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

                    // Items in the cart
                    child: SizedBox(width: 500, child: MyCartItemsListView()),
                  ),
                ),
              ),
            );
          }
        }),

        // Checkout button
        bottomNavigationBar: controller.cartItems.isEmpty
            ? SizedBox()
            : Padding(
          padding: EdgeInsets.all(MySizes.defaultspace),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(600, 10, 600, 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.0),
                ),
              ),
              onPressed: () => navigationController.goToCheckoutScreen(context),  // Navigate to Checkout
              child: Obx(
                    () => Text(
                  'Check Out \$${controller.totalCartPrice.value}',  // Display total price
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
