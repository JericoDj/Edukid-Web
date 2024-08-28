
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webedukid/features/screens/homescreen/widgets/home_categories.dart';
import 'package:webedukid/features/screens/homescreen/widgets/myappbar.dart';
import 'package:webedukid/features/screens/homescreen/widgets/promo_slider.dart';

import '../../../common/widgets/customShapes/containers/primary_header_container.dart';
import '../../../common/widgets/customShapes/containers/search_container.dart';
import '../../../common/widgets/layouts/grid_layout.dart';
import '../../../common/widgets/products/product_card/product_card_vertical.dart';
import '../../../common/widgets/shimmer/vertical_product_shimmer.dart';
import '../../../common/widgets/texts/section_heading.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../shop/controller/product/product_controller.dart';
import '../../shop/screens/all_products/all_products.dart';
import '../../shop/screens/bookings/booking_session.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
            const MyPrimaryHeaderContainer(
              child: Column(
                children: [
                  /// APP BAR
                  MyHomeAppBar(),

                  /// SEARCH BAR
                  MySearchContainer(text: ' Search for Items'),
                  SizedBox(height: MySizes.spaceBtwItems),

                  /// CATEGORIES
                  Padding(
                    padding: EdgeInsets.only(left: MySizes.defaultspace),
                    child: Column(
                      children: [
                        /// HEADING OF CATEGORIES
                        MySectionHeading(
                          title: 'List of Products',
                          showActionButton: false,
                          textColor: MyColors.white,
                        ),
                        SizedBox(height: MySizes.spaceBtwItems),

                        /// LIST OF CATEGORIES
                        MyHomeCategories(),
                      ],
                    ),
                  ),
                  SizedBox(height: MySizes.spaceBtwSections),
                ],
              ),
            ),

            /// BODY OF PAGE
            Padding(
              padding: const EdgeInsets.all(MySizes.defaultspace),
              child: Column(
                children: [
                  /// PromoSlider
                  const MyPromoSlider(),
                  const SizedBox(height: MySizes.spaceBtwSections),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Container(
                          width: double.infinity, // Set width to fill available space
                          child: ElevatedButton(
                            onPressed: () => Get.to(() => BookingSessionScreen(selectedDates: [], selectedTimes: [],)),
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(MyColors.white),
                              // Change background color
                              side: WidgetStateProperty.all<BorderSide>(
                                BorderSide(color: MyColors.primaryColor),
                              ),
                            ),
                            child: Text(
                              'Try a Free Session',
                              style: TextStyle(color: MyColors.primaryColor, fontSize: MySizes.fontSizeMd),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20), // Adjust the spacing between buttons
                      Flexible(
                        flex: 2,
                        child: Container(
                          width: double.infinity, // Set width to fill available space
                          child: ElevatedButton(
                            onPressed: () => Get.to(() => BookingSessionScreen(selectedDates: [], selectedTimes: [], )),
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(MyColors.primaryColor),
                              // Change background color
                              side: WidgetStateProperty.all<BorderSide>(
                                BorderSide(color: MyColors.primaryColor),
                              ),
                            ),
                            child: Text(
                              'Book a Session',
                              style: TextStyle(color: Colors.white, fontSize: MySizes.fontSizeMd),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),




                  /// Worksheets Heading
                  MySectionHeading(
                    title: 'Worksheets',
                    onPressed: () => Get.to(() => AllProductsScreen(
                      title: 'Popular Products',
                      futureMethod: controller.fetchAllFeaturedProducts(),
                    )),
                  ),

                  /// Popular Products (WorkSheets)
                  Obx(() {
                    if (controller.isLoading.value)
                      return const MyVerticalProductShimmer();

                    if (controller.featuredProducts.isEmpty) {
                      return Center(
                        child: Text(
                          'No Data Found',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }

                    // Print details of fetched products
                    for (var product in controller.featuredProducts) {
                      print('Product ID: ${product.id}');
                      print('Product Title: ${product.title}');
                      // Print other details as needed
                    }

                    return MyGridLayoutWidget(
                      mainAxisExtent: 320,
                      itemCount: controller.featuredProducts.length,
                      itemBuilder: (_, index) => MyProductCardVertical(
                        product: controller.featuredProducts[index],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


