import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/appbar.dart';
import '../../../../common/widgets/appbar/tabbar.dart';
import '../../../../common/widgets/customShapes/containers/search_container.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/products/cart_menu_icons.dart';
import '../../../../common/widgets/shimmer/brand_shimmer.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controller/brand_controller.dart';
import '../../controller/category_controller.dart';
import '../brands/all_brands.dart';
import '../brands/brand_products.dart';
import 'category_tab.dart';
import 'mybrandcard.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brandController = Get.put(BrandController());
    final categories = CategoryController.instance.featuredCategories;
    final dark = MyHelperFunctions.isDarkMode(context);

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        body: SingleChildScrollView(

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Section with SliverAppBar Content
              Container(
                color: dark ? MyColors.black : MyColors.white,
                padding: const EdgeInsets.all(MySizes.defaultspace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MySectionHeading(
                      title: 'Featured Items',
                      onPressed: () => Get.to(() => AllBrandsScreen()),
                    ),
                    const SizedBox(height: MySizes.spaceBtwItems / 2),

                    /// Brand Grids
                    Obx(() {


                      return Center(
                        child: Container(
                          width: 800,
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisExtent: 100,
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 50,
                              childAspectRatio: 10,
                            ),
                            itemCount: brandController.featuredBrands.length,
                            itemBuilder: (_, index) {
                              final brand = brandController.featuredBrands[index];
                              return Center(
                                child: MyBrandCard(
                                  showBorder: true,
                                  brand: brand,
                                  onTap: () => Get.to(() => BrandProducts(brand: brand)),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),


                    SizedBox(height: MySizes.spaceBtwItems,),

                    /// Tab Bar Below Content
                    MyTabBar(
                      tabs: categories
                          .map((category) => Tab(
                        child: Text(category.name),
                      ))
                          .toList(),
                    ),
                  ],
                ),
              ),

              /// Tab Bar View
              Container(
                height: 400, // Set an appropriate height
                child: TabBarView(
                  children: categories
                      .map((category) => MyCategoryTab(category: category))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
