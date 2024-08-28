
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
        appBar: MyAppBar(
          title: Text(
            'Store',
            style: Theme
                .of(context)
                .textTheme
                .headlineMedium,
          ),
          actions: [
            MyCartIcon(
              iconColor: dark ? MyColors.white : MyColors.black,
            ),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (_, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                floating: true,
                backgroundColor: dark ? MyColors.black : MyColors.white,
                expandedHeight: 440,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.all(MySizes.defaultspace),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      const MySearchContainer(
                        text: 'Search for Item here',
                        showBorder: true,
                        showBackround: false,
                        padding: EdgeInsets.zero,
                      ),

                      MySectionHeading(
                        title: 'Featured Items',
                        onPressed: () => Get.to(() => AllBrandsScreen()),
                      ),
                      const SizedBox(height: MySizes.spaceBtwItems / 2),

                      /// Brand Grids
                      Obx(() {
                        if (brandController.isLoading.value)
                          return MyBrandShimmer();

                        if (brandController.featuredBrands.isEmpty) {
                          return Center(
                            child: Text(
                              'No Data Found',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .apply(color: MyColors.white),
                            ),
                          );
                        }

                        return MyGridLayoutWidget(
                          itemCount: brandController.featuredBrands.length,
                          mainAxisExtent: 80,
                          itemBuilder: (_, index) {
                            final brand = brandController.featuredBrands[index];
                            return MyBrandCard(
                              showBorder: true, brand: brand, onTap: () => Get.to(() => BrandProducts(brand: brand,)),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),

                ///
                bottom: MyTabBar(
                  tabs: categories
                      .map((category) =>
                      Tab(
                        child: Text(category.name),
                      ))
                      .toList(),
                ),
              ),
            ];
          },

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
