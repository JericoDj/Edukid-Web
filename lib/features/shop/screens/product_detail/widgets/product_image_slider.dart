import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../common/widgets/customShapes/curvedEdges/curved_edges_widget.dart';
import '../../../../../common/widgets/images/my_rounded_image.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controller/product/images_controller.dart';
import '../../../models/product_model.dart';

class MyProductImageSlider extends StatelessWidget {
  const MyProductImageSlider({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunctions.isDarkMode(context);
    final imagesController = Get.put(ImagesController()); // Get ImagesController
    final images = imagesController.getAllProductImages(product);

    return MyCurvedEdgesWidget(
      child: Container(
        height: 420,
        color: dark ? MyColors.darkerGrey : MyColors.light,
        child: Stack(children: [
          /// Main Large Image
          Positioned(
            child: SizedBox(
              height: 380,
              child: Padding(
                padding: EdgeInsets.all(MySizes.productImageRadius * 2),
                child: Center(
                  child: Obx(
                        () {
                      final image = imagesController.selectedProductImage.value;
                      return GestureDetector(
                        // Show image in a popup dialog when tapped
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                backgroundColor: Colors.transparent,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: image,
                                      progressIndicatorBuilder: (_, __, downloadProgress) =>
                                          CircularProgressIndicator(
                                            value: downloadProgress.progress,
                                            color: MyColors.primaryColor,
                                          ),
                                    ),
                                    Positioned(
                                      top: 20,
                                      right: 20,
                                      child: IconButton(
                                        icon: Icon(Icons.close, color: Colors.white),
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: CachedNetworkImage(
                          imageUrl: image,
                          progressIndicatorBuilder: (_, __, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                  color: MyColors.primaryColor),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 30,
            left: MySizes.defaultspace,
            child: Center(
              child: SizedBox(
                height: 80,
                child: ListView.separated(
                  itemCount: images.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: AlwaysScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => SizedBox(
                    width: MySizes.spaceBtwItems,
                  ),
                  itemBuilder: (_, index) => Obx(
                        () {
                      final imageSelected = imagesController.selectedProductImage.value == images[index];
                      return MyRoundedImage(
                        width: 80,
                        isNetworkImage: true,
                        backgroundColor: dark ? MyColors.dark : MyColors.white,
                        onPressed: () => imagesController.selectedProductImage.value = images[index],
                        border: Border.all(color: imageSelected ? MyColors.primaryColor : Colors.transparent),
                        padding: EdgeInsets.all(MySizes.md),
                        imageUrl: images[index],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 300),
        ]),
      ),
    );
  }
}
