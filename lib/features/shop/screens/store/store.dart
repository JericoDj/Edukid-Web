import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webedukid/features/screens/navigation_controller.dart'; // Import the navigation controller
import '../../../../common/widgets/appbar/tabbar.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controller/brand_controller.dart';
import '../../controller/category_controller.dart';
import '../../models/product_model.dart';
import '../brands/all_brands.dart';
import '../brands/brand_products.dart';
import '../product_detail/product_detail.dart';
import 'category_tab.dart';
import 'mybrandcard.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String selectedCategoryName = ''; // Store selected category name

  @override
  void initState() {
    super.initState();
    final categories = CategoryController.instance.featuredCategories;

    // Ensure categories list is not empty before initializing the TabController
    if (categories.isNotEmpty) {
      _tabController = TabController(length: categories.length, vsync: this);

      // Set the initial selected category to the first one
      selectedCategoryName = categories[0].name;

      // Add a listener to the TabController to detect tab changes
      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) {
          // The tab has been changed, so update the selected category name
          final selectedIndex = _tabController!.index;
          final selectedCategory = categories[selectedIndex];
          selectedCategoryName = selectedCategory.name;

          // Refresh UI by calling setState
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose(); // Safely dispose the TabController if it's not null
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brandController = Get.put(BrandController());
    final categories = CategoryController.instance.featuredCategories;
    final dark = MyHelperFunctions.isDarkMode(context);
    final navigationController = Get.find<NavigationController>(); // Get the navigation controller

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Section with SliverAppBar Content
            Container(
              color: dark ? MyColors.black : MyColors.white,
              padding: const EdgeInsets.all(MySizes.defaultspace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: MySizes.spaceBtwItems / 2),

                  /// Brand Grids
                  Obx(() {
                    return Container(
                      width: 800,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisExtent: 100,
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 50,
                          childAspectRatio: 1,
                        ),
                        itemCount: brandController.featuredBrands.length,
                        itemBuilder: (_, index) {
                          final brand = brandController.featuredBrands[index];
                          return MyBrandCard(
                            showBorder: true,
                            brand: brand,
                            onTap: () =>
                                Get.to(() => BrandProducts(brand: brand)),
                          );
                        },
                      ),
                    );
                  }),

                  SizedBox(
                    height: MySizes.spaceBtwItems,
                  ),

                  /// Tab Bar Below Content
                  if (_tabController != null)
                    MyTabBar(
                      tabs: categories
                          .map((category) => Tab(
                        child: Text(category.name),
                      ))
                          .toList(),
                      controller: _tabController!, // Pass the non-null TabController
                    ),
                ],
              ),
            ),

            SizedBox(
              height: MySizes.spaceBtwItems,
            ),

            /// Fetch and display only the products that match the selected category's level
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('Products').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error fetching products: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('No products found.');
                }

                // If data is available, filter products by the selected category (Level)
                final products = snapshot.data!.docs.where((product) {
                  final level = product['Level'];
                  return level == selectedCategoryName; // Match the selected tab's name
                }).toList();

                // Display filtered products
                return Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 400, vertical: 0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisExtent: 400,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 0,
                      childAspectRatio: 1, // Adjusted to fit better on screen
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final level = product['Level'];
                      final title = product['Title'];
                      final thumbnail = product['Thumbnail'];
                      final salePrice = product['SalePrice'];

                      // Navigate to ProductDetailScreen when the product is pressed
                      return GestureDetector(
                        onTap: () {
                          // Create the ProductModel from the query snapshot
                          final selectedProduct = ProductModel.fromQuerySnapshot(product);

                          // Use the NavigationController to navigate to ProductDetailScreen
                          navigationController.navigateTo('productDetail', product: selectedProduct);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300, width: 1),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
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
                                    thumbnail ?? '',
                                    width: double.infinity,
                                    height: 200, // Ensure it fits properly in height
                                    fit: BoxFit.fill, // Fits the width first
                                    alignment: Alignment.center, // Ensure the image centers if aspect ratios differ
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14, // Compact font size
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Price: \$${salePrice.toString()}',
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
            ),

            SizedBox(
              height: MySizes.spaceBtwItems,
            ),
          ],
        ),
      ),
    );
  }
}
