
import 'package:flutter/material.dart';

import '../../../../common/widgets/appbar.dart';
import '../../../../common/widgets/products/sortable/sortable_products.dart';
import '../../../../common/widgets/shimmer/vertical_product_shimmer.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/cloud_helper_functions.dart';
import '../../controller/brand_controller.dart';
import '../../models/brand_model.dart';
import '../store/mybrandcard.dart';

class BrandProducts extends StatelessWidget {
  const BrandProducts({super.key, required this.brand});

  final BrandModel brand;

  @override
  Widget build(BuildContext context) {
    final controller = BrandController.instance;
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MySizes.defaultspace),
        child: Column(
          children: [
            ///Brand Details
            MyBrandCard(showBorder: true, brand: brand,),
            SizedBox(
              height: MySizes.spaceBtwSections,
            ),

            FutureBuilder(
              future: controller.getBrandProducts(brandId: brand.id),
              builder: (context, snapshot) {

                /// Handle Loader, No Record, OR Error Message
                const loader = MyVerticalProductShimmer();
                final widget = MyCloudHelperFunctions.checkMultiRecordState(snapshot: snapshot, loader: loader);
                  if (widget != null) return widget;
                /// Record Found!
                final brandProducts = snapshot.data!;
                return MySortableProducts (products: brandProducts);
              }
            ),
          ],
        ),
      ),
    );
  }
}
