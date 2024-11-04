
import 'package:flutter/material.dart';

import '../../../../common/widgets/customShapes/containers/rounded_container.dart';
import '../../../../common/widgets/images/my_circular_image.dart';
import '../../../../common/widgets/texts/my_brand_title_text.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../models/brand_model.dart';

class MyBrandCard extends StatelessWidget {
  const MyBrandCard({
    super.key,
    required this.showBorder,
    this.onTap, required this.brand,
  });


  final BrandModel? brand;
  final bool showBorder;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: onTap,

      /// container design
      child: MyRoundedContainer(
        showBorder: showBorder,
        borderColor: MyColors.primaryColor,
        backgroundColor: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ///Icon
             Flexible(
              child: MyCircularImage(
                isNetworkImage: true,

                image: brand!.image,
                backgroundColor: Colors.transparent,
              ),
                         ),

            /// Text
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   MyBrandTitleText(
                    title: brand!.name,
                    brandTextSize: TextSizes.small,
                  ),
                  Text(
                    '${brand!.productsCount ?? 0} products',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}
