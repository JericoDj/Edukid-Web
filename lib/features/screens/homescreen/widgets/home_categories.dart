
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../common/widgets/image_text_widgets/vertical_image_text.dart';
import '../../../../common/widgets/shimmer/catergory_shimmer.dart';
import '../../../../utils/constants/colors.dart';
import '../../../shop/controller/category_controller.dart';
import '../../../shop/screens/sub_category/sub_category.dart';

class MyHomeCategories extends StatelessWidget {
  const MyHomeCategories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.put(CategoryController());

    return Obx(
      () {
        if (categoryController.isLoading.value)
          return const MyCategoryShimmer();

        if (categoryController.featuredCategories.isEmpty) {
          return Center(
            child: Text(
              'No Data Found!',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .apply(color: MyColors.white),
            ),
          );
        }
        return SizedBox(
          height: 80,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categoryController.featuredCategories.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) {
              final category = categoryController.featuredCategories[index];

              return MyVerticalImageText(
                image: category.imagePath,
                title: category.name,
                backgroundColor: MyColors.white,
                onTap: () => Get.to(() => SubCategoriesScreen(category: category)),
              );
            },
          ),
        );
      },
    );
  }
}
