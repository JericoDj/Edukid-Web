
import 'package:flutter/material.dart';

import '../../../../../common/widgets/brands/brand_showcase.dart';
import '../../../../../common/widgets/shimmer/boxes_shimmer.dart';
import '../../../../../common/widgets/shimmer/list_tile_shimmer.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/cloud_helper_functions.dart';
import '../../../controller/brand_controller.dart';
import '../../../models/category_model.dart';

class CategoryBrands extends StatelessWidget {
  const CategoryBrands({
    Key? key,
    required this.category,
  }) : super(key: key);

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final controller = BrandController.instance;

    return FutureBuilder(
      future: controller.getBrandsForCategory(category.id),
      builder: (context, snapshot) {
        // Handle loader, no record, or error message
        ///useless loader
        const loader = Column(
          children: [
            MyListTileShimmer(),
            SizedBox(height: MySizes.spaceBtwItems),
            MyBoxesShimmer(),
            SizedBox(height: MySizes.spaceBtwItems),
          ],
        );

        final widget = MyCloudHelperFunctions.checkMultiRecordState(
          snapshot: snapshot,
          loader: loader,
        );

        if (widget != null) return widget;

        // Records Found!
        final brands = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: brands.length,
          itemBuilder: (_, index) {
            final brand = brands[index];
            return FutureBuilder(
              future: controller.getBrandProducts(brandId: brand.id, limit: 3),
              builder: (context, snapshot) {
                // Handle Loader, No Record, OR Error Message
                final productWidget = MyCloudHelperFunctions.checkMultiRecordState(
                  snapshot: snapshot,
                  loader: loader,
                );

                if (productWidget != null) return productWidget;

                // Record Found!
                final products = snapshot.data!;

                return MyBrandShowCase(
                  brand: brand,
                  images: products.map((e) => e.thumbnail).toList(),
                );
              },
            );
          },
        );
      },
    );
  }
}
