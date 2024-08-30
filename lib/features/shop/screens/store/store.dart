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
        body: NestedScrollView(

          headerSliverBuilder: (_, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                floating: true,

                backgroundColor: dark ? MyColors.black : MyColors.white,
                expandedHeight: 220,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.all(MySizes.defaultspace),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      /// this is inside edukid and little achievers hub
                      MySectionHeading(
                        title: 'Featured Items',
                        onPressed: () => Get.to(() => AllBrandsScreen()),
                      ),
                      const SizedBox(height: MySizes.spaceBtwItems / 2),

                      /// Brand Grids
                      Obx(() {
                        if (brandController.isLoading.value) {
                          return MyBrandShimmer();
                        }

                        if (brandController.featuredBrands.isEmpty) {
                          return Center(
                            child: Text(
                              'No Data Found',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .apply(color: MyColors.white),
                            ),
                          );
                        }
                      /// this entirely the place of little achivers and theedukid
                        return Center(
                          child: Container(
                            height: 200,
                            width: 800,
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                mainAxisExtent: 100,
                                crossAxisCount: 3, // Number of columns
                                crossAxisSpacing: 10, // Spacing between columns
                                mainAxisSpacing: 50, // Spacing between rows
                                childAspectRatio: 10, // Aspect ratio for grid items
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
                    ],
                  ),
                ),

                /// Tab bar at the bottom of the SliverAppBar/// this is the grade 1
                bottom: MyTabBar(
                  tabs: categories
                      .map((category) => Tab(
                    child: Text(category.name),
                  ))
                      .toList(),
                ),
              ),
            ];
          },

          /// Body of the tab views /// everything below the grade 1///
          body: TabBarView(
            children: categories
                .map((category) => MyCategoryTab(category: category))
                .toList(),
          ),
        ),
      ),
    );
  }
}
