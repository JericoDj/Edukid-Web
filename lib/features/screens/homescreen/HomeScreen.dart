import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:webedukid/custom_app_bar.dart';
import 'package:webedukid/features/screens/homescreen/widgets/home_categories.dart';
import 'package:webedukid/features/screens/homescreen/widgets/promo_slider.dart';
import 'package:webedukid/features/shop/screens/bookings/booking_session.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

import '../../../common/widgets/customShapes/containers/primary_header_container.dart';
import '../../../common/widgets/layouts/grid_layout.dart';
import '../../../common/widgets/products/product_card/product_card_vertical.dart';
import '../../../common/widgets/shimmer/vertical_product_shimmer.dart';
import '../../../common/widgets/texts/section_heading.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../shop/controller/product/product_controller.dart';  // Import ProductController
import '../navigation_controller.dart'; // Import the NavigationController
import '../../shop/models/product_model.dart'; // Import ProductModel

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.find(); // Get the NavigationController
    final ProductController controller = Get.put(ProductController()); // Initialize the ProductController

    // Ensure the selected category is cleared when returning to the HomeScreen
    navigationController.clearSelectedCategory(); // Clear the selection

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const MyPrimaryHeaderContainer(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: MySizes.defaultspace),
                    child: Column(
                      children: [
                        MySectionHeading(
                          title: '',
                          showActionButton: false,
                          textColor: MyColors.white,
                        ),
                        SizedBox(height: MySizes.spaceBtwItems / 3),
                        MyHomeCategories(),
                      ],
                    ),
                  ),
                  SizedBox(height: MySizes.spaceBtwSections),
                ],
              ),
            ),

            Obx(() {
              final selectedCategory = navigationController.selectedCategory;
              if (selectedCategory == null) {
                return _buildBodyContent(navigationController, controller, context); // Pass context
              } else {
                return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance
                      .collection('Products')
                      .where('Level', isEqualTo: selectedCategory.name)
                      .get(),
                  builder: (context, snapshot) {
                    const loader = MyVerticalProductShimmer();
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return loader;
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading products: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No products found.'));
                    }

                    final products = snapshot.data!.docs.map((doc) {
                      return ProductModel.fromQuerySnapshot(doc);
                    }).toList();

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisExtent: 400,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 50,
                        ),
                        itemBuilder: (context, index) {
                          final product = products[index];

                          return GestureDetector(
                            onTap: () {
                              navigationController.navigateTo('productDetail', product: product);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300, width: 1),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  )
                                ],
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                      child: Image.network(
                                        product.thumbnail ?? '',
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.fill,
                                        alignment: Alignment.center,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Center(child: Text('Image not available'));
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          product.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Price: \$${product.salePrice.toString()}',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent(NavigationController navigationController, ProductController controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MySizes.defaultspace),
      child: Column(
        children: [
          MyPromoSlider(),
          SizedBox(height: MySizes.spaceBtwSections),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => context.go('/bookSession'), // Using context.go() for GoRouter
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: const Text('Book a Session', style: TextStyle(color: MyColors.white)),
                ),
              ),
            ],
          ),
          SizedBox(height: MySizes.spaceBtwSections),

          MySectionHeading(
            title: 'Worksheets',
            buttonTitle: 'View All',
            onPressed: () {
              navigationController.navigateTo('allProducts');
            },
          ),

          Obx(() {
            if (controller.isLoading.value) {
              return const MyVerticalProductShimmer();
            }

            return MyGridLayoutWidget(
              mainAxisExtent: 260,
              itemCount: controller.featuredProducts.length,
              itemBuilder: (_, index) => MyProductCardVertical(
                product: controller.featuredProducts[index],
              ),
            );
          }),
        ],
      ),
    );
  }
}
