
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../features/shop/models/brand_model.dart';
import '../../../features/shop/screens/brands/brand_products.dart';
import '../../../features/shop/screens/store/mybrandcard.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../customShapes/containers/rounded_container.dart';
import '../shimmer/shimmer.dart';



class MyBrandShowCase extends StatelessWidget {
  const MyBrandShowCase({
    super.key,
    required this.images, required this.brand,
  });


  final BrandModel brand;
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(() => BrandProducts(brand: brand)),
      /// holder of the item
      child: MyRoundedContainer(
        width: 10,
        showBorder: true,
        borderColor: MyColors.darkGrey,
        padding: const EdgeInsets.all(MySizes.md),
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.only(bottom: MySizes.spaceBtwItems),
        child: Column(
          children: [
             MyBrandCard(showBorder: false, brand: brand),

            Row(children: images.map((image) => brandTopProductImageWidget(image, context)).toList())
          ],
        ),
      ),
    );
  }

  /// image of the iem

  Widget brandTopProductImageWidget(String image, context) {
    return Flexible(
      fit: FlexFit.tight,
      flex: 5,
      /// imgae of the item
      child: MyRoundedContainer(
        width: 10,

        height: 150 ,
        padding: const EdgeInsets.all(MySizes.md),
        margin: const EdgeInsets.only (right: MySizes.sm),
        backgroundColor: MyHelperFunctions.isDarkMode(context) ? MyColors
            .darkerGrey : MyColors.light,
        child: CachedNetworkImage(
          height: 20,
            fit: BoxFit.contain,
            imageUrl: image,
          progressIndicatorBuilder: (context, url, downloadprogress) => const MyShimmerEffect(width: 100, height: 100),
          errorWidget:(context, url, error) => const Icon(Icons.error),
        ),
      ), // TRoundedContainer
    ); // Expanded
  }
}
