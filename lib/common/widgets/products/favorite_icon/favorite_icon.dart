
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../features/shop/controller/product/favorites_controller.dart';
import '../../icons/my_circular_icon.dart';


class MyFavoriteIcon extends StatelessWidget {
  const MyFavoriteIcon({super.key, required this.productId});

  final String productId;


  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FavoritesController());

    return Obx(
      () => MyCircularIcon(
        icon: controller.isFavorite(productId) ? Iconsax.heart5 : Iconsax.heart,
        color: controller.isFavorite(productId) ? Colors.red : null,
        onPressed: () => controller.toggleFavoriteProduct(productId),
      ),
    );
  }
}
