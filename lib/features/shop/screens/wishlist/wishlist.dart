

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar.dart';
import '../../../../common/widgets/icons/my_circular_icon.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/loaders/animation_loader.dart';
import '../../../../common/widgets/products/product_card/product_card_vertical.dart';
import '../../../../common/widgets/shimmer/vertical_product_shimmer.dart';
import '../../../../navigation_Bar.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/cloud_helper_functions.dart';
import '../../controller/category_controller.dart';
import '../../controller/product/favorites_controller.dart';
import '../../controller/product/product_controller.dart';
import '../../models/product_model.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FavoritesController.instance;
    return Scaffold(
        appBar: MyAppBar(
          showBackArrow: true,
          title: Text('Wishlist',
              style: Theme.of(context).textTheme.headlineMedium),
          actions: [
            MyCircularIcon(
              icon: Iconsax.add,
              onPressed: () => Get.offAll( NavigationBarMenu()),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(MySizes.defaultspace),
            child: Column(
              children: [
                Obx(
                () => FutureBuilder(
                    future: controller.favoriteProducts(),
                    builder: (context, snapshot) {

                      /// Nothing Found Widget
                      final emptyWidget = MyAnimationLoaderWidget(
                          text: 'Whoops! Wishlist is Empty...',
                          animation: MyImages.loaders,
                          showAction: false,
                          actionText: 'Let\'s add some',
                          onActionPressed: () => Get.off(() => NavigationBarMenu()),
                      );
                      const loader = MyVerticalProductShimmer (itemCount: 6);
                      final widget = MyCloudHelperFunctions.checkMultiRecordState(snapshot: snapshot, loader: loader, nothingFound: emptyWidget);
                      if (widget!= null) return widget;

                      final products = snapshot.data!;
                      return MyGridLayoutWidget(itemCount: products.length, itemBuilder: (_, index) => MyProductCardVertical (product: products[index]));

                    }
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
