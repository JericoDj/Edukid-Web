
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../features/shop/controller/all_products_controller.dart';
import '../../../../features/shop/models/product_model.dart';
import '../../../../utils/constants/sizes.dart';
import '../../layouts/grid_layout.dart';
import '../product_card/product_card_vertical.dart';

class MySortableProducts extends StatelessWidget {
  const MySortableProducts({
    super.key, required this.products,
  });


  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllProductsController());
    controller.assignProducts(products);
    return Column(
      children: [
        /// Dropdown
        DropdownButtonFormField(
          decoration: const InputDecoration(prefixIcon: Icon(Iconsax.sort)),
          value: controller.selectedSortOption.value,
          onChanged: (value) {
            controller.sortProducts(value!);
          },
          items: [
            'Name',
            'Higher Price',
            'Lower Price',
            'Sale',
            'Newest',
            'Popularity'
          ]
              .map((option) =>
                  DropdownMenuItem(value: option, child: Text(option)))
              .toList(),
        ), // DropdownButtonFormField
        const SizedBox(height: MySizes.spaceBtwSections),

        /// Products
        Obx(
          () => MyGridLayoutWidget(
            mainAxisExtent: 320,
              itemCount: controller.products.length,
              itemBuilder: (_, index) =>  MyProductCardVertical(product:  controller.products[index],)),
        )
      ],
    );
  }
} // Column
