import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
import '../../personalization/controllers/user_controller.dart';
import '../../shop/cart/cart.dart';
import '../../shop/screens/account_privacy/account_privacy_screen.dart';
import '../../shop/screens/coupons/coupons_screen.dart';
import '../../shop/screens/order/order.dart';
import '../../shop/screens/wishlist/wishlist.dart';
import '../personalization/screens/address/address.dart';


class SettingsScreen extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;

  const SettingsScreen({
    Key? key,
    required this.isOpen,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserController());
    Get.lazyPut(() => PreviousScreenController());
    final previousScreenController = Get.find<PreviousScreenController>();

    return AnimatedPositioned(
      duration: Duration(milliseconds: 30),
      right: isOpen ? 0 : -400, // Adjust this value based on your drawer width
      top: 0,
      bottom: 0,
      width: 400, // Width of your drawer
      child: Material(
        color: Colors.white,
        elevation: 5,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyPrimaryHeaderContainer(
                child: Column(
                  children: [

                    MyUserProfileTile(
                      onPressed: () async {
                        var result = await Get.to(() => const EditProfileScreen());
                        if (result != null) {
                          previousScreenController.updateUIWithData(result);
                        }
                      },
                    ),
                    const SizedBox(
                      height: MySizes.spaceBtwSections,
                    ),
                  ],
                ),
              ),
              Padding(

                padding: const EdgeInsets.all(MySizes.defaultspace),
                child: Column(
                  children: [
                    const MySectionHeading(
                      title: 'Account Settings',
                      showActionButton: false,
                    ),
                    const SizedBox(height: MySizes.spaceBtwItems),
                    MySettingsMenuTile(
                        icon: Iconsax.safe_home,
                        title: 'My Addresses',
                        subTitle: 'Set shopping delivery address',
                        onTap: () => Get.to(() => UserAddressScreen())),
                    MySettingsMenuTile(
                        icon: Iconsax.safe_home,
                        title: 'My Cart',
                        subTitle: 'Add, remove products and move to checkout',
                        onTap: () => Get.to(() => CartScreen())),
                    MySettingsMenuTile(
                        icon: Iconsax.safe_home,
                        title: 'My Orders',
                        subTitle: 'In-progress and Completed Orders',
                        onTap: () => Get.to(() => OrderScreen())),
                    MySettingsMenuTile(
                        icon: Iconsax.safe_home,
                        title: 'My Wishlist',
                        subTitle: 'Add, Remove products to your wishlist',
                        onTap: () => Get.to(() => WishlistScreen())),
                    MySettingsMenuTile(
                        icon: Iconsax.safe_home,
                        title: 'My Coupons',
                        subTitle: 'List of all coupons',
                        onTap: () => Get.to(() => CouponScreen())),
                    MySettingsMenuTile(
                        icon: Iconsax.safe_home,
                        title: 'Account Privacy',
                        subTitle: 'Manage data usage and connected accounts',
                        onTap: () => Get.to(() => AccountPrivacyScreen())),
                    const SizedBox(height: MySizes.spaceBtwSections),
                    const MySectionHeading(
                      title: 'App Settings',
                      showActionButton: false,
                    ),
                    const SizedBox(height: MySizes.spaceBtwSections),
                    SizedBox(
                      width: 200,
                      child: OutlinedButton(
                        onPressed: () {
                          AuthenticationRepository.instance.logout();
                        },
                        child: const Text('Logout'),
                      ),
                    ),
                    const SizedBox(height: MySizes.spaceBtwSections * 2),
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
