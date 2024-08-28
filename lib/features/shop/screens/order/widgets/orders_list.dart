
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/customShapes/containers/rounded_container.dart';
import '../../../../../common/widgets/loaders/animation_loader.dart';
import '../../../../../navigation_Bar.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/cloud_helper_functions.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controller/product/order_controller.dart';

class MyOrderListItems extends StatelessWidget {
  const MyOrderListItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunctions.isDarkMode(context);
    final controller = Get.put(OrderController());
    return FutureBuilder(
      future: controller.fetchUserOrders(),
      builder: (_, snapshot) {
        /// Nothing Found Widget
        final emptyWidget = MyAnimationLoaderWidget(
          text: 'Whoops! No Orders Yet!',
          animation: MyImages.loaders,
          showAction: true,
          actionText: 'Let\'s fill it',
          onActionPressed: () => Get.off(() => const NavigationBarMenu()),
        );

        /// Helper Function: Handle Loader, No Record, OR ERROR Message
        final response = MyCloudHelperFunctions.checkMultiRecordState(
            snapshot: snapshot, nothingFound: emptyWidget);
        if (response != null) return response;

        /// Congratulations Record found.
        final orders = snapshot.data!;

        return ListView.separated(
          shrinkWrap: true,
          itemCount: orders.length,
          separatorBuilder: (_, __) => SizedBox(
            height: MySizes.spaceBtwItems,
          ),
          itemBuilder: (_, index) => MyRoundedContainer(
            showBorder: true,
            padding: EdgeInsets.all(MySizes.md),
            backgroundColor: dark ? MyColors.dark : MyColors.light,
            borderColor: MyColors.primaryColor, // Set border color here
            child: Column(
              children: [
                /// row 1
                Row(
                  children: [
                    /// 1 Icon
                    const Icon(Iconsax.ship),
                    const SizedBox(width: MySizes.spaceBtwItems / 2),

                    /// 2 Status & Date
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${orders[index].id}',
                            style: Theme.of(context).textTheme.bodyLarge!.apply(
                              color: MyColors.primaryColor,
                            ),
                          ),
                          Text('${orders[index].orderDate}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),

                    /// 3 - Icon
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Iconsax.arrow_right_34,
                        size: MySizes.iconSm,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MySizes.spaceBtwItems,
                ),

                /// row 2
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          /// 1 Icon
                          const Icon(Iconsax.tag),
                          const SizedBox(width: MySizes.spaceBtwItems / 2),

                          /// 2 Status & Date
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${orders[index].status}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .apply(
                                    color: MyColors.primaryColor,
                                  ),
                                ),
                                Text('${orders[index].id}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          /// 1 Icon
                          const Icon(Iconsax.calendar),
                          const SizedBox(width: MySizes.spaceBtwItems / 2),

                          /// 2 Status & Date
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${orders[index].paymentMethod}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .apply(
                                    color: MyColors.primaryColor,
                                  ),
                                ),
                                Text('${orders[index].deliveryDate}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
