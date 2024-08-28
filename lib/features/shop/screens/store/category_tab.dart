
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:webedukid/features/shop/screens/store/widgets/category_brands.dart';

import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/products/product_card/product_card_vertical.dart';
import '../../../../common/widgets/shimmer/vertical_product_shimmer.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/cloud_helper_functions.dart';
import '../../controller/category_controller.dart';
import '../../controller/product/product_controller.dart';
import '../../models/category_model.dart';
import '../all_products/all_products.dart';

class MyCategoryTab extends StatelessWidget {
  const MyCategoryTab({super.key, required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.instance;


    return ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(MySizes.defaultspace),
            child: Column(
              /// brands
              children: [
                CategoryBrands(category: category),

                /// products below the box
                /// 1
                /// category ID value is the ID  of the category
                FutureBuilder(
                    future:
                        controller.getCategoryProducts(categoryId: category.id),

                    builder: (context, snapshot) {
                      /// Helper Function: Handle Loader, No Record, OR ERROR Message
                      final response =
                          MyCloudHelperFunctions.checkMultiRecordState(
                              snapshot: snapshot,
                              loader: const MyVerticalProductShimmer());
                      if (response != null) return response;

                      /// Record Found!
                      final products = snapshot.data!;

                      return Column(
                        children: [
                          MySectionHeading(
                            title: 'You might like',
                            onPressed: () => Get.to(AllProductsScreen(
                              title: category.name,
                              futureMethod: controller.getCategoryProducts(
                                  categoryId: category.id, limit: -1),
                            )),
                          ),
                          const SizedBox(height: MySizes.spaceBtwItems),
                          MyGridLayoutWidget(
                              mainAxisExtent: 320,
                              itemCount: products.length,
                              itemBuilder: (_, index) => MyProductCardVertical(
                                  product: products[index]))
                        ],
                      );
                    })
              ],
            ),
          ),
        ]);
  }
}
