
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../../common/widgets/chips/choice_chip.dart';
import '../../../../../common/widgets/customShapes/containers/rounded_container.dart';
import '../../../../../common/widgets/texts/product_price_text.dart';
import '../../../../../common/widgets/texts/product_title_text.dart';
import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controller/product/variation_controller.dart';
import '../../../models/product_model.dart';

class MyProductAttributes extends StatelessWidget {
  const MyProductAttributes({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunctions.isDarkMode(context);
    final controller = Get.put(VariationController());
    return Obx(
      () => Column(
        children: [
          /// selected attribute pricing and description
          if (controller.selectedVariation.value.id.isNotEmpty)
            MyRoundedContainer(
              padding: EdgeInsets.all(MySizes.md),
              backgroundColor: dark ? MyColors.darkerGrey : MyColors.lightGrey,
              child: Column(children: [
                ///Tittle,Price and stock
                Row(
                  children: [
                    const MySectionHeading(
                        title: 'Variation', showActionButton: false),
                    const SizedBox(width: MySizes.spaceBtwItems),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const MyProductTitleText(
                                title: 'Price: ', smallSize: true),

                            /// Actual Price
                            if (controller.selectedVariation.value.salePrice >
                                0)
                              Text(
                                '\$${controller.selectedVariation.value.price}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .apply(
                                        decoration: TextDecoration.lineThrough),
                              ), // Text
                            const SizedBox(width: MySizes.spaceBtwItems),

                            /// Sale Price
                            MyProductPriceText(
                                price: controller.getVariationPrice()),
                          ],
                        ), // Row
                        /// Stock
                        Row(
                          children: [
                            const MyProductTitleText(
                                title: 'Stock', smallSize: true),
                            Text(controller.variationStockStatus.value,
                                style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                      ],
                    )
                  ],
                ),

                /// Variation Description
                MyProductTitleText(
                  title: controller.selectedVariation.value.description ?? '',
                  smallSize: true,
                  maxLines: 4,
                ),
              ]),
            ),
          SizedBox(
            height: MySizes.spaceBtwItems,
          ),

          ///Attributes
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: product.productAttributes!
                .map((attribute) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MySectionHeading(
                        title: attribute.name ?? '',
                        showActionButton: false,
                      ),
                      SizedBox(
                        height: MySizes.spaceBtwItems / 2,
                      ),
                      Obx(() {
                        // Print variations for debugging
                        print(
                            "Selected Variation: ${controller.selectedVariation.value}");

                        return Wrap(
                          spacing: 8,
                          children: attribute.values!.map(
                            (attributeValue) {
                              final isSelected = controller
                                      .selectedAttributes[attribute.name] ==
                                  attributeValue;
                              final available = controller
                                  .getAttributesAvailabilityInVariation(
                                      product.productVariations!,
                                      attribute.name!)
                                  .contains(attributeValue);
                              return MyChoiceChip(
                                  text: attributeValue,
                                  selected: isSelected,
                                  onSelected: available
                                      ? (selected) {
                                          if (selected && available) {
                                            controller.onAttributeSelected(
                                                product,
                                                attribute.name ?? '',
                                                attributeValue);
                                          }
                                        }
                                      : null);
                            },
                          ).toList(),
                        );
                      }),
                    ],
                  ),
                )
                .toList(),
          )
        ],
      ),
    );
  }
}
