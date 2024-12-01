import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:webedukid/common/widgets/products/product_card/product_card_add_to_cart_button.dart';
import '../../../../features/shop/controller/product/cart_controller.dart';
import '../../../../features/shop/controller/product/product_controller.dart';
import '../../../../features/shop/controller/product/variation_controller.dart';
import '../../../../features/shop/models/product_model.dart';
import '../../../../features/screens/navigation_controller.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../styles/shadows.dart';
import '../../customShapes/containers/rounded_container.dart';
import '../../images/my_rounded_image.dart';
import '../../texts/my_brand_title_text.dart';
import '../../texts/product_price_text.dart';
import '../../texts/product_title_text.dart';
import '../favorite_icon/favorite_icon.dart';

class MyProductCardVertical extends StatelessWidget {
  const MyProductCardVertical({Key? key, required this.product}) : super(key: key);

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => VariationController());
    Get.lazyPut(() => CartController());
    final controller = ProductController.instance;
    final salePercentage = controller.calculateSalePercentage(product.price, product.salePrice);
    final dark = MyHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: () {
        final productNameUrl = product.title.replaceAll(' ', '-');
        context.go(
          '/productDetail/${product.id}/$productNameUrl',
          extra: product,
        );
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          boxShadow: [MyShadowStyle.verticalProductShadow],
          borderRadius: BorderRadius.circular(MySizes.productImageRadius),
          color: dark ? MyColors.darkerGrey : MyColors.white,
        ),
        child: MyRoundedContainer(
          height: 280,
          padding: const EdgeInsets.all(MySizes.sm),
          backgroundColor: dark ? MyColors.dark : MyColors.light,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 6,
                child: Stack(
                  children: [
                    MyRoundedImage(
                      imageUrl: product.thumbnail,
                      height: 150,
                      applyImageRadius: true,
                      isNetworkImage: true,
                      backgroundColor: Colors.transparent,
                    ),
                    if (salePercentage != null)
                      Positioned(
                        top: 12,
                        child: MyRoundedContainer(
                          radius: MySizes.sm,
                          backgroundColor: MyColors.secondaryColor.withOpacity(0.8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: MySizes.sm,
                            vertical: MySizes.xs,
                          ),
                          child: Text(
                            '$salePercentage%',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .apply(color: MyColors.black),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: MyFavoriteIcon(
                        productId: product.id,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: MySizes.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyProductTitleText(title: product.title, smallSize: true),
                      SizedBox(height: MySizes.spaceBtwItems / 2),
                      MyBrandTitleText(title: product.brand!.name, color: Colors.green),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.productType == ProductType.single.toString() &&
                              product.salePrice > 0)
                            Padding(
                              padding: const EdgeInsets.only(left: MySizes.sm),
                              child: Text(
                                product.price.toString(),
                                style: Theme.of(context).textTheme.labelMedium!.apply(
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(left: MySizes.sm),
                            child: MyProductPriceText(price: controller.getProductPrice(product)),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: ProductCardAddToCartButton(product: product),
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
