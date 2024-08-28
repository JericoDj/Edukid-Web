// Import the necessary packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webedukid/features/screens/profilescreen/widgets/editprofile.dart';

import '../../../common/data/repositories.authentication/authentication_repository.dart';
import '../../../common/widgets/appbar.dart';
import '../../../common/widgets/appbar/myAppBarController.dart';
import '../../../common/widgets/customShapes/containers/primary_header_container.dart';
import '../../../common/widgets/list_tiles/settings.dart';
import '../../../common/widgets/list_tiles/user_profile_tile.dart';
import '../../../common/widgets/texts/section_heading.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../shop/cart/cart.dart';
import '../../shop/screens/account_privacy/account_privacy_screen.dart';
import '../../shop/screens/coupons/coupons_screen.dart';
import '../../shop/screens/order/order.dart';
import '../../shop/screens/wishlist/wishlist.dart';
import '../personalization/screens/address/address.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key,});


  @override
  Widget build(BuildContext context) {
    final previousScreenController = Get.find<PreviousScreenController>();


    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// header
            MyPrimaryHeaderContainer(
                child: Column(
                  children: [
                    MyAppBar(
                        title: Text('Account',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .apply(color: MyColors.white))),

                    ///User profile
                    MyUserProfileTile(onPressed: () async {
                      var result = await Get.to(() => const EditProfileScreen());
                      if (result != null) {

                        previousScreenController.updateUIWithData(result);
                      }
                    },
                    ), // ListTile
                    const SizedBox(
                      height: MySizes.spaceBtwSections,
                    ),
                  ],
                )),

            Padding(
              padding: const EdgeInsets.all(MySizes.defaultspace),
              child: Column(
                children: [
                  ///-- Account Settings

                  const MySectionHeading(title: 'Account Settings',showActionButton: false,),
                  const SizedBox(height: MySizes.spaceBtwItems),
                  MySettingsMenuTile(icon: Iconsax.safe_home, title: 'My Addresses', subTitle: 'Set shopping delivery address', onTap: () => Get.to(() => UserAddressScreen())),
                  MySettingsMenuTile(icon: Iconsax.safe_home, title: 'My Cart', subTitle: 'Add, remove products and move to checkout', onTap: () => Get.to (() => CartScreen())),
                  MySettingsMenuTile(icon: Iconsax.safe_home, title: 'My Orders', subTitle: 'In-progress and Completed Orders', onTap: () => Get.to (() => OrderScreen())),
                  MySettingsMenuTile(icon: Iconsax.safe_home, title: 'My Wishlist', subTitle: 'Add, Remove products to your wishlist', onTap: () => Get.to (() => WishlistScreen())),
                  MySettingsMenuTile(icon: Iconsax.safe_home, title: 'My Coupons', subTitle: 'List of all coupons', onTap: () => Get.to (() => CouponScreen())),
                  MySettingsMenuTile(icon: Iconsax.safe_home, title: 'Account Privacy', subTitle: 'Manage data usage and connected accounts', onTap: () => Get.to (() => AccountPrivacyScreen())),


                  /// App Settings
                  const SizedBox(height: MySizes.spaceBtwSections,),
                  const MySectionHeading(title: 'App Settings', showActionButton: false,),
                  const SizedBox(height: MySizes.spaceBtwSections,),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(onPressed: () {
                      AuthenticationRepository.instance.logout();
                    },
                      child: const Text('Logout'),),
                  ),
                  const SizedBox(height: MySizes.spaceBtwSections * 2,),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
