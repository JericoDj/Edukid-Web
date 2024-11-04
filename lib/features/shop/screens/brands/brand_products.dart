import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/widgets/appbar.dart';
import '../../../../common/widgets/products/sortable/sortable_products.dart';
import '../../../../common/widgets/shimmer/vertical_product_shimmer.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/cloud_helper_functions.dart';
import '../../controller/brand_controller.dart';
import '../../models/brand_model.dart';
import '../store/mybrandcard.dart';

class BrandProducts extends StatelessWidget {
  const BrandProducts({
    super.key,
    this.brand,
    required this.brandId,
    required this.brandName,
  });

  final BrandModel? brand;
  final String brandId;
  final String brandName;

  @override
  Widget build(BuildContext context) {
    final controller = BrandController.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(brand?.name ?? brandName),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MySizes.defaultspace),
        child: Column(
          children: [
            // Display Brand Details
            if (brand != null)
              MyBrandCard(showBorder: true, brand: brand!)
            else
              FutureBuilder<BrandModel>(
                future: controller.getBrandById(brandId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return Center(child: Text("Error loading brand details"));
                  } else {
                    final brandData = snapshot.data!;
                    return MyBrandCard(showBorder: true, brand: brandData);
                  }
                },
              ),
            SizedBox(height: MySizes.spaceBtwSections),

            // Fetch and Display Brand Products
            FutureBuilder(
              future: controller.getBrandProducts(brandId: brandId),
              builder: (context, snapshot) {
                const loader = MyVerticalProductShimmer();

                // Handle snapshot state for loading, errors, or empty list
                final widget = MyCloudHelperFunctions.checkMultiRecordState(snapshot: snapshot, loader: loader);
                if (widget != null) return widget;

                final brandProducts = snapshot.data!;
                if (brandProducts.isEmpty) {
                  return Center(child: Text("No products available for this brand."));
                }

                return MySortableProducts(products: brandProducts);
              },
            ),
          ],
        ),
      ),
    );
  }
}
