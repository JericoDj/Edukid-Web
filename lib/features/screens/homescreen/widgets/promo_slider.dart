
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/customShapes/containers/circular_container.dart';
import '../../../../common/widgets/images/my_rounded_image.dart';
import '../../../../common/widgets/shimmer/shimmer.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../shop/controller/banner_controller.dart';
import '../../../shop/controller/home_controller.dart';

class MyPromoSlider extends StatelessWidget {
  const MyPromoSlider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BannerController());
    return Obx(
      () {
        //Loader
        if (controller.isLoading.value)
          return const MyShimmerEffect(width: double.infinity, height: 190);

        // No Data
        if (controller.banners.isEmpty) {
          return const Center(
            child: Text('No Data Found!'),
          );
        } else {
          return Column(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                    viewportFraction: 1,
                    onPageChanged: (index, _) =>
                        controller.updatePageIndicator(index)),
                items: controller.banners
                    .map((banner) => MyRoundedImage(
                          imageUrl: banner.imageUrl,
                          isNetworkImage: true,
                          onPressed: () => Get.toNamed(banner.targetScreen),
                        ))
                    .toList(),
              ),
              const SizedBox(height: MySizes.spaceBtwItems),
              Center(
                child: Obx(
                  () => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < controller.banners.length; i++)
                        MyCircularWidget(
                          width: 20,
                          height: 5,
                          margin: const EdgeInsets.only(right: 10),
                          backroundColor:
                              controller.carousalCurrentIndex.value == i
                                  ? MyColors.primaryColor
                                  : MyColors.lightGrey,
                        )
                    ],
                  ),
                ),
              )
            ],
          );
        }
      },
    );
  }
}
