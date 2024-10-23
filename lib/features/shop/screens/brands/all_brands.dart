
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../common/widgets/appbar.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/shimmer/brand_shimmer.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller/brand_controller.dart';
import '../../models/brand_model.dart';
import '../store/mybrandcard.dart';
import 'brand_products.dart';

class AllBrandsScreen extends StatelessWidget {
  const AllBrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brandController = BrandController.instance;


    return Scaffold(
      appBar: MyAppBar(title: Text('Brand'), showBackArrow: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(MySizes.defaultspace),
          child: Column(
            children: [
              ///Heading
              MySectionHeading(
                title: 'Brands',
                showActionButton: false,
              ),
              SizedBox(
                height: MySizes.spaceBtwItems,
              ),

              ///Brands
              Obx(() {
                if (brandController.isLoading.value)
                  return MyBrandShimmer();

                if (brandController.allBrands.isEmpty) {
                  return Center(
                    child: Text(
                      'No Data Found',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .apply(color: MyColors.white),
                    ),
                  );
                }
/// shown
                return MyGridLayoutWidget(
                  itemCount: brandController.allBrands.length,
                  mainAxisExtent: 80,
                  itemBuilder: (_, index) {
                    final brand = brandController.allBrands[index];
                    return  MyBrandCard(
                      showBorder: true, brand: brand, onTap: () => Get.to (() => BrandProducts(brand: brand)),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
