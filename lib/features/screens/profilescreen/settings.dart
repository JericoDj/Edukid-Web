import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/data/repositories.authentication/authentication_repository.dart';
import '../../../common/widgets/appbar/myAppBarController.dart';
import '../../../common/widgets/customShapes/containers/primary_header_container.dart';
import '../../../common/widgets/list_tiles/settings.dart';
import '../../../common/widgets/list_tiles/user_profile_tile.dart';
import '../../../common/widgets/texts/section_heading.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../personalization/controllers/user_controller.dart';

class SettingsScreen extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final VoidCallback onEditProfile;
  final VoidCallback onUserAddress;
  final VoidCallback onCart;
  final VoidCallback onOrder;
  final VoidCallback onWishlist;
  final VoidCallback onCoupon;
  final VoidCallback onAccountPrivacy;

  const SettingsScreen({
    Key? key,
    required this.isOpen,
    required this.onClose,
    required this.onEditProfile,
    required this.onUserAddress,
    required this.onCart,
    required this.onOrder,
    required this.onWishlist,
    required this.onCoupon,
    required this.onAccountPrivacy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserController());
    Get.lazyPut(() => PreviousScreenController());
    final previousScreenController = Get.find<PreviousScreenController>();

    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          left: isOpen ? 0 : 0,
          top: 0,
          bottom: 0,
          width: 300,
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
                          onPressed: onEditProfile,
                        ),
                        const SizedBox(height: MySizes.spaceBtwSections),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(MySizes.spaceBtwItems / 2),
                    child: Column(
                      children: [
                        const MySectionHeading(
                          title: 'Account Settings',
                          showActionButton: false,
                        ),
                        const SizedBox(height: MySizes.spaceBtwItems),
                        MySettingsMenuTile(
                          icon: Icons.home,
                          title: 'My Addresses',
                          subTitle: 'Set shopping delivery address',
                          onTap: onUserAddress,
                        ),
                        MySettingsMenuTile(
                          icon: Icons.card_travel,
                          title: 'My Cart',
                          subTitle: 'Add, remove products and move to checkout',
                          onTap: onCart,
                        ),
                        MySettingsMenuTile(
                          icon: Icons.book,
                          title: 'My Orders',
                          subTitle: 'In-progress and Completed Orders',
                          onTap: onOrder,
                        ),
                        MySettingsMenuTile(
                          icon: Icons.discount,
                          title: 'My Coupons',
                          subTitle: 'List of all coupons',
                          onTap: onCoupon,
                        ),
                        MySettingsMenuTile(
                          icon: Icons.lock,
                          title: 'Account Privacy',
                          subTitle: 'Manage data usage and connected accounts',
                          onTap: onAccountPrivacy,
                        ),
                        const SizedBox(height: MySizes.spaceBtwSections),
                        const MySectionHeading(
                          title: 'App Settings',
                          showActionButton: false,
                        ),
                        const SizedBox(height: MySizes.spaceBtwSections),
                        SizedBox(
                          width: 200,
                          child: OutlinedButton(
                            onPressed: () async {
                              onClose(); // Close the drawer immediately
                              await AuthenticationRepository.instance.logout(context); // Trigger logout with context for redirect
                            },
                            child: const Text('Logout'),
                            style: ButtonStyle(
                              side: MaterialStateProperty.all(
                                const BorderSide(color: Colors.teal, width: 1.5),
                              ),
                              foregroundColor: MaterialStateProperty.all(Colors.teal),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
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
        ),
      ],
    );
  }
}
