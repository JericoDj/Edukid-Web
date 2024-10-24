import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:webedukid/features/shop/screens/product_detail/product_detail.dart';

import '../../../../common/widgets/appbar.dart';
import '../../../../common/widgets/shimmer/horizontal_product_shimmer.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../screens/navigation_controller.dart';
import '../../controller/category_controller.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';

class SubCategoriesScreen extends StatelessWidget {
  const SubCategoriesScreen({Key? key, required this.category}) : super(key: key);

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.instance;
    final navigationController = Get.find<NavigationController>(); // Get the navigation controller

    // Print the category name it received
    print('Category name received: ${category.name}');

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name), // Display category name in the app bar
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(MySizes.defaultspace),
            child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('Products') // Accessing all product documents
                  .where('Level', isEqualTo: category.name) // Query by 'Level' field
                  .get(),
              builder: (context, snapshot) {
                /// Handle Loader, No Record, or Error Message
                const loader = MyHorizontalProductShimmer();
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return loader;
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading products: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No products found.'));
                }

                /// Convert Firestore documents to ProductModel
                final products = snapshot.data!.docs.map((doc) {
                  return ProductModel.fromQuerySnapshot(doc); // Using fromQuerySnapshot to map documents to ProductModel
                }).toList();

                // Use GridView to display products in rows similar to StoreScreen
                return Expanded(
                  child: Container(
                    width: 800,
                    alignment: Alignment.topCenter,
                    child: GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20), // Adjust the padding if needed
                      itemCount: products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Display 3 products per row
                        mainAxisExtent: 400, // Fixed height for each card (customizable)
                        crossAxisSpacing: 20, // Space between the columns
                        mainAxisSpacing: 50, // Space between the rows
                      ),
                      itemBuilder: (context, index) {
                        final product = products[index];

                        return GestureDetector(
                          onTap: () {
                            // Pass the selected product to ProductDetailScreen
                            navigationController.navigateTo('productDetail', product: product);
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
                                      product.thumbnail ?? '',
                                      width: double.infinity,
                                      height: 200, // Ensure it fits properly in height
                                      fit: BoxFit.fill, // Fits the width first
                                      alignment: Alignment.center, // Ensure the image centers if aspect ratios differ
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(child: Text('Image not available'));
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
