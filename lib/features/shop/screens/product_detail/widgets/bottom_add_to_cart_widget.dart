
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/icons/my_circular_icon.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';

import '../../../../authentication/login/login.dart';
import '../../../controller/product/cart_controller.dart';
import '../../../models/product_model.dart';
import '../../../../../common/data/repositories.authentication/authentication_repository.dart';

import '../../../controller/product/cart_controller.dart';
import '../../../models/product_model.dart';


class MyBottomAddToCart extends StatelessWidget {
  const MyBottomAddToCart({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
        final controller = CartController.instance;
    controller.updateAlreadyAddedProductCount(product);
    final dark = MyHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MySizes.defaultspace,
        vertical: MySizes.defaultspace / 2,
      ),
      decoration: BoxDecoration(
        color: dark ? MyColors.darkerGrey : MyColors.light,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(MySizes.cardRadiusLg),
          topRight: Radius.circular(MySizes.cardRadiusLg),
        ),
      ),
      child: Obx(
            () => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                MyCircularIcon(
                  icon: Iconsax.minus,
                  backroundColor: MyColors.darkGrey,
                  width: 40,
                  height: 40,
                  color: MyColors.white,
                  onPressed: () {
                    // Decrease quantity, but ensure it doesn't go below 1
                    if (controller.initialProductCount.value > 1) {
                      controller.initialProductCount.value -= 1;
                    }
                  },
                ),
                const SizedBox(width: MySizes.spaceBtwItems),
                Text(
                  controller.initialProductCount.value.toString(),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(width: MySizes.spaceBtwItems),
                MyCircularIcon(
                  icon: Iconsax.add,
                  backroundColor: MyColors.black,
                  width: 40,
                  height: 40,
                  color: MyColors.white,
                  onPressed: () {
                    // Increase quantity
                    controller.initialProductCount.value += 1;
                  },
                ),
              ],
            ),
            SizedBox(width: 20,),
            ElevatedButton(
              onPressed: () {
                // Check if the user is authenticated
                if (AuthenticationRepository.instance.authUser != null) {
                  // Only add to cart if the quantity is 1 or more
                  if (controller.initialProductCount.value > 0) {
                    controller.productQuantityInCart.value = controller.initialProductCount.value;
                    controller.addToCart(product);
                  }
                } else {
                  // Redirect to login screen if not authenticated
                  context.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(MySizes.md),
                backgroundColor: MyColors.black,
                side: const BorderSide(color: MyColors.black),
              ),
              child: const Text('Add to Cart'),
            )

          ],
        ),
      ),
    );
  }
}
