
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../common/widgets/appbar.dart';
import '../../../../common/widgets/images/my_rounded_image.dart';
import '../../../../common/widgets/products/product_card/product_card_horizontal.dart';
import '../../../../common/widgets/shimmer/horizontal_product_shimmer.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/cloud_helper_functions.dart';
import '../../controller/category_controller.dart';
import '../../models/category_model.dart';
import '../all_products/all_products.dart';

class SubCategoriesScreen extends StatelessWidget {
  const SubCategoriesScreen({Key? key, required this.category}) : super(key: key);

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.instance;
    print("Category ID: ${category.id}");
    print("Category Name: ${category.name}");

    return Scaffold(
      appBar: MyAppBar(title: Text(category.name), showBackArrow: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(MySizes.defaultspace),
          child: Column(
            children: [
              /// Banner
              MyRoundedImage(
                  padding: EdgeInsets.all(MySizes.xs),
                  imageUrl: MyImages.onBoardingImage3,
                  applyImageRadius: true),
              SizedBox(height: MySizes.spaceBtwSections),

              /// Sub-Categories
              FutureBuilder(
                  future: controller.getSubCategories(category.id),
                  builder: (context, snapshot) {
                    /// Handle Loader, No Record, or Error Message
                    const loader = MyHorizontalProductShimmer();
                    final widget = MyCloudHelperFunctions.checkMultiRecordState(
                        snapshot: snapshot, loader: loader);
                    if (widget != null) return widget;

                    /// Record found
                    final subCategories = snapshot.data!;

                    print('Sub Categories List:');
                    for (final subCategory in subCategories) {
                      print('Document ID: ${subCategory.id}');
                      print('Category Name: ${subCategory.name}');
                      // Add more properties as needed
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: subCategories.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (_, index) {
                        final subCategory = subCategories[index];
                        return FutureBuilder(


                          future: controller.getSubCategoryProducts(categoryId: subCategory.id),
                          builder: (context, snapshot) {

                            /// Handle Loader, No Record, or Error Message
                            final widget = MyCloudHelperFunctions.checkMultiRecordState(
                                snapshot: snapshot, loader: loader);
                            if (widget != null) return widget;

                            /// Record found
                            final products = snapshot.data!;


                            return Column(
                              children: [
                                /// HEADING
                                MySectionHeading(
                                  title: subCategory.name,
                                  onPressed: () => Get.to(
                                        () => AllProductsScreen(
                                      title: subCategory.name,
                                      futureMethod: controller.getCategoryProducts(categoryId: subCategory.id, limit: -1),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: MySizes.spaceBtwItems / 2,
                                ),
                                SizedBox(
                                  height: 110,
                                  child: ListView.separated(
                                    itemCount: products.length,
                                    scrollDirection: Axis.horizontal,
                                    separatorBuilder: (context, index) => SizedBox(
                                      width: MySizes.spaceBtwItems,
                                    ),
                                    itemBuilder: (context, index) => MyProductCardHorizontal(product: products[index]),
                                  ),
                                ),
                                const SizedBox(height: MySizes.spaceBtwSections,)
                              ],
                            );
                          }
                        );
                      },
                    );
                  })
            ],
          ),
        ), // Padding
      ),
    );
  }
}
