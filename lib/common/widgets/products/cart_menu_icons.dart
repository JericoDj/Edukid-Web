
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../../features/shop/cart/cart.dart';
import '../../../features/shop/controller/product/cart_controller.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';

class MyCartIcon extends StatelessWidget {
  const MyCartIcon({
    super.key,
    this.iconColor,
  });

  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());

    final dark = MyHelperFunctions.isDarkMode(context);
    return Stack(
      children: [
        IconButton(
            onPressed: () => Get.to(() => const CartScreen()),
            icon: const Icon(
              Iconsax.shopping_bag,
            ),
            color: iconColor),
        Positioned(
          right: 0,
          child: Container(
            width: 1,
            height: 18,
            decoration: BoxDecoration(
              color: MyColors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: Obx(() => Text(controller.noOfCartItems.value.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .apply(color: MyColors.white, fontSizeFactor: 0.8))),
            ),
          ),
        ),
      ],
    );
  }
}
