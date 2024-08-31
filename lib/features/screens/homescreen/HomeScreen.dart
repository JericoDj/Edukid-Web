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
import '../navigation_controller.dart'; // Import the NavigationController

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());
    final ScrollController scrollController = ScrollController();
    final NavigationController navigationController = Get.find();

    return Scaffold(
      body: Scrollbar(
        interactive: true,
        thumbVisibility: true,
        trackVisibility: true,


        radius: Radius.circular(MySizes.md),
        controller: scrollController,

        thickness: MySizes.sm,

        child: SingleChildScrollView(

          controller: scrollController,
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

              /// BODY OF PAGE
              Padding(
                padding: const EdgeInsets.all(MySizes.defaultspace),
                child: Column(
                  children: [
                    /// PromoSlider
                    MyPromoSlider(),
                    SizedBox(height: MySizes.spaceBtwSections,), // Adjust the space between the slider and buttons

                    /// Buttons in a Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () => navigationController
                                .navigateTo('bookingSession'),
                            style: ButtonStyle(
                              backgroundColor:
                              WidgetStateProperty.all(MyColors.white),
                              side: WidgetStateProperty.all<BorderSide>(
                                BorderSide(color: MyColors.primaryColor),
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                            child: Text('Try a Free Session',
                                style: TextStyle(
                                    color: MyColors.primaryColor)),
                          ),
                        ),
                        SizedBox(width: 20), // Adjust the space between buttons
                        Container(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () => navigationController
                                .navigateTo('bookingSession'),
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  MyColors.primaryColor),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                            child: Text('Book a Session',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MySizes.spaceBtwSections),

                    /// Worksheets Heading
                    MySectionHeading(
                      title: 'Worksheets',
                      onPressed: () {
                        navigationController.navigateTo(
                            'allProducts'); // Navigate to AllProductsScreen with its controller
                      },
                    ),

                    /// Popular Products (WorkSheets)
                    Container(
                      alignment: Alignment.center,
                      child: Obx(() {
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

                        return MyGridLayoutWidget(
                          mainAxisExtent: 321,
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
            ],
          ),
        ),
      ),
    );
  }
}
