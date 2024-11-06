import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../common/data/repositories.authentication/authentication_repository.dart';
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
    final userController = Get.find<UserController>();

    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          left: isOpen ? 0 : 0,
          top: 0,
          bottom: 0,
          width: 400,
          child: Material(
            color: Colors.white,
            elevation: 5,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: MyColors.primaryColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: [
                        Obx(() {
                          if (userController.user.value.id.isNotEmpty) {
                            // User is logged in
                            return Column(
                              children: [
                                MyUserProfileTile(onPressed: onEditProfile),
                              ],
                            );
                          } else {
                            // User is not logged in (Guest view)
                            return Column(
                              children: [
                                const Text(
                                  'Guest User',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => context.go('/login'),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.white),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text('Login', style: TextStyle(color: Colors.white)),
                                    ),
                                    const SizedBox(width: 10),
                                    OutlinedButton(
                                      onPressed: () => context.go('/register'),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.white),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text('Register', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () => context.go('/forgotPassword'),
                                  child: const Text('Forgot Password?', style: TextStyle(color: Colors.white70)),
                                ),
                              ],
                            );
                          }
                        }),
                        const SizedBox(height: MySizes.spaceBtwSections),
                      ],
                    ),
                  ),

                  // Main Body
                  Padding(
                    padding: const EdgeInsets.all(MySizes.spaceBtwItems),
                    child: Obx(() {
                      if (userController.user.value.id.isEmpty) {
                        // Guest view options
                        return Column(
                          children: [
                            const SizedBox(height: 20),
                            const Text(
                              'Explore as a Guest',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Sign up to access more features, such as saving items to your wishlist, managing orders, and customizing your account.',
                              style: TextStyle(fontSize: 16, color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            OutlinedButton(
                              onPressed: () => context.go('/allProducts'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: MyColors.primaryColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text('Browse Products', style: TextStyle(color: Colors.teal)),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton(
                              onPressed: () => context.go('/aboutUs'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: MyColors.primaryColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text('Learn About Us', style: TextStyle(color: Colors.teal)),
                            ),
                          ],
                        );
                      } else {
                        // Logged-in user view options
                        return Column(
                          children: [
                            const MySectionHeading(title: 'Account Settings', showActionButton: false),
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
                              subTitle: 'List of available coupons',
                              onTap: onCoupon,
                            ),
                            MySettingsMenuTile(
                              icon: Icons.lock,
                              title: 'Account Privacy',
                              subTitle: 'Manage data usage and connected accounts',
                              onTap: onAccountPrivacy,
                            ),
                            const SizedBox(height: MySizes.spaceBtwSections),
                            const MySectionHeading(title: 'App Settings', showActionButton: false),
                            const SizedBox(height: MySizes.spaceBtwSections),
                            SizedBox(
                              width: 200,
                              child: OutlinedButton(
                                onPressed: () async {
                                  onClose();
                                  await AuthenticationRepository.instance.logout(context);
                                  userController.clearUser();
                                },
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
                                child: const Text('Logout', style: TextStyle(color: Colors.teal)),
                              ),
                            ),
                            const SizedBox(height: MySizes.spaceBtwSections * 2),
                          ],
                        );
                      }
                    }),
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
