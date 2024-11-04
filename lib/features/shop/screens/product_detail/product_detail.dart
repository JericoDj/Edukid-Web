import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:readmore/readmore.dart';
import 'package:webedukid/features/shop/screens/product_detail/widgets/bottom_add_to_cart_widget.dart';
import 'package:webedukid/features/shop/screens/product_detail/widgets/product_attributes.dart';
import 'package:webedukid/features/shop/screens/product_detail/widgets/product_image_slider.dart';
import 'package:webedukid/features/shop/screens/product_detail/widgets/product_meta_data.dart';
import 'package:webedukid/features/shop/screens/product_detail/widgets/rating_share_widget.dart';

import '../../../../common/widgets/appbar.dart';
import '../../../../common/widgets/products/cart_menu_icons.dart';
import '../../../../common/widgets/products/favorite_icon/favorite_icon.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller/product/product_controller.dart';
import '../../models/product_model.dart';
import '../product_reviews/product_reviews.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({Key? key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(()=>ProductController());
    return Center(
      child: Scaffold(

        // Add to cart
        bottomNavigationBar: MyBottomAddToCart(product: product),
        body: SingleChildScrollView(
          child: Column(
            children: [

              // Product image slider
              MyProductImageSlider(product: product),


              // Product Details
              Container(
                width: 600,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: MySizes.defaultspace,
                    left: MySizes.defaultspace,
                    bottom: MySizes.defaultspace,
                  ),
                  child: Column(
                    children: [
                      // Rating & Share Button
                      /// A WIDGET NEXT TO THIS MyRatingAndShareWidget(),

                      // Price, title, Stack, & Brand
                      MyProductMetaData(product: product),

                      // Attributes
                      if (product.productType == ProductType.variable.toString())
                        MyProductAttributes(product: product),
                      if (product.productType == ProductType.variable.toString())
                        SizedBox(height: MySizes.spaceBtwSections),

                      SizedBox(height: MySizes.spaceBtwSections),

                      // Description
                      MySectionHeading(title: 'Description', showActionButton: false),
                      SizedBox(height: MySizes.spaceBtwItems),
                      ReadMoreText(
                        product.description ?? '',
                        trimLines: 2,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: ' Show more',
                        trimExpandedText: 'Less',
                        moreStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        lessStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: MySizes.spaceBtwItems),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const MySectionHeading(title: 'Reviews (199)', showActionButton: false),
                          IconButton(
                            icon: const Icon(Iconsax.arrow_right_3, size: 18),
                            onPressed: () => Get.to(() => ProductReviewsScreen()),
                          ),
                        ],
                      ),
                      const SizedBox(height: MySizes.spaceBtwSections),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
