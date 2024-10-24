import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:webedukid/custom_app_bar.dart';
import 'package:webedukid/features/screens/homescreen/widgets/home_categories.dart';
import 'package:webedukid/features/screens/homescreen/widgets/promo_slider.dart';
import 'package:webedukid/features/shop/screens/bookings/booking_session.dart';
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
      appBar: CustomAppBar(currentScreen: 'home',),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
            const MyPrimaryHeaderContainer(
              child: Column(
                children: [
                  /// CATEGORIES
                  Padding(
                    padding: EdgeInsets.only(left: MySizes.defaultspace),
                    child: Column(
                      children: [
                        /// HEADING OF CATEGORIES
                        MySectionHeading(
                          title: '',
                          showActionButton: false,
                          textColor: MyColors.white,
                        ),
                        SizedBox(height: MySizes.spaceBtwItems / 3),

                        /// LIST OF CATEGORIES
                        MyHomeCategories(),
                      ],
                    ),
                  ),
                  SizedBox(height: MySizes.spaceBtwSections),
                ],
              ),
            ),

            /// BODY OF PAGE - This will be hidden if a category is selected
            Obx(() {
              final selectedCategory = navigationController.selectedCategory;
              if (selectedCategory == null) {
                return _buildBodyContent(navigationController, controller);
              } else {
                // Firestore Query based on selected category
                return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance
                      .collection('Products') // Accessing all product documents
                      .where('Level', isEqualTo: selectedCategory.name) // Query by 'Level' field
                      .get(),
                  builder: (context, snapshot) {
                    /// Handle Loader, No Record, or Error Message
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

                    /// Convert Firestore documents to ProductModel
                    final products = snapshot.data!.docs.map((doc) {
                      return ProductModel.fromQuerySnapshot(doc); // Using fromQuerySnapshot to map documents to ProductModel
                    }).toList();

                    // Use GridView to display products in rows
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5, // Display 5 products per row
                          mainAxisExtent: 400, // Fixed height for each card (customizable)
                          crossAxisSpacing: 20, // Space between the columns
                          mainAxisSpacing: 50, // Space between the rows
                        ),
                        itemBuilder: (context, index) {
                          final product = products[index];

                          return GestureDetector(
                            onTap: () {
                              // Pass the selected product to ProductDetailScreen and clear the category selection
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
                                        height: 200, // Ensure it fits properly in height
                                        fit: BoxFit.fill, // Fits the width first
                                        alignment: Alignment.center, // Ensure the image centers if aspect ratios differ
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
                                            fontSize: 14, // Compact font size
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

  /// Separate method for the body content to be hidden or shown
  Widget _buildBodyContent(NavigationController navigationController, ProductController controller) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(MySizes.defaultspace),
        child: Column(
          children: [
            /// PromoSlider
            MyPromoSlider(),
            SizedBox(height: MySizes.spaceBtwSections),

            /// Buttons in a Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () => navigationController.navigateTo('bookingSession'),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(MyColors.white),
                      side: WidgetStateProperty.all<BorderSide>(
                        BorderSide(color: MyColors.primaryColor),
                      ),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                    child: Text('Try a Free Session',
                        style: TextStyle(color: MyColors.primaryColor)),
                  ),
                ),
                SizedBox(width: 20),
                Container(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => BookingSessionScreen());
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(MyColors.primaryColor),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                    child: Text('Book a Session',
                        style: TextStyle(color: MyColors.white)),
                  ),
                ),
              ],
            ),
            SizedBox(height: MySizes.spaceBtwSections),

            /// Worksheets Heading
            MySectionHeading(
              title: 'Worksheets',
              buttonTitle: 'View All',
              onPressed: () {
                navigationController.navigateTo(
                    'allProducts'); // Navigate to AllProductsScreen with its controller
              },
            ),

            /// Popular Products (WorkSheets)
            Container(
              alignment: Alignment.center,
              child: Obx(() {
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
            ),
          ],
        ),
      ),
    );
  }
}
