import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
            children: [
              // Display brands related to the category
              CategoryBrands(category: category),

              /// Products below the box
              FutureBuilder(
                future: controller.getCategoryProducts(categoryId: category.id),
                builder: (context, snapshot) {
                  // Handle the loading, error, and empty state
                  final response = MyCloudHelperFunctions.checkMultiRecordState(
                    snapshot: snapshot,
                    loader: const MyVerticalProductShimmer(),
                  );
                  if (response != null) return response;

                  // Data is available - now display the products
                  final products = snapshot.data!;

                  // List of products
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

                      // Use ListView.builder to display products with ListTile
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final title = product.title; // Assuming title field
                          final level = product.level; // Assuming level field

                          // Return a ListTile for each product
                          return ListTile(
                            title: Text(title ?? 'No Title'),
                            subtitle: Text('Level: ${level ?? 'Unknown Level'}'),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
