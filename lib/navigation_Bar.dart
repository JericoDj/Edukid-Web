import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webedukid/utils/constants/colors.dart';
import 'common/data/repositories.authentication/authentication_repository.dart';
import 'common/widgets/customShapes/containers/search_container.dart';
import 'drawer_controller.dart';
import 'features/screens/navigation_controller.dart';

class NavigationBarMenu extends StatefulWidget implements PreferredSizeWidget {
  @override
  NavigationBarMenuState createState() => NavigationBarMenuState();

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class NavigationBarMenuState extends State<NavigationBarMenu> {
  final MyDrawerController drawerController = Get.put(MyDrawerController());
  final NavigationController navController = Get.put(NavigationController()); // Initialize NavigationController
  final AuthenticationRepository authRepo = Get.find<AuthenticationRepository>();

  @override
  Widget build(BuildContext context) {
    // Check if a user is already logged in
    final user = authRepo.authUser;
    if (user != null) {
      print("User is logged in with ID: ${user.uid}, Email: ${user.email}");
    } else {
      print("No user logged in.");
    }

    return AppBar(
      actions: [
        IconButton(
          icon: const Icon(Iconsax.shopping_cart, color: Colors.white),
          onPressed: () {
            context.go('/cart');
          },
        ),
        IconButton(
          onPressed: () {
            drawerController.openDrawer();
            Scaffold.of(context).openEndDrawer();
          },
          icon: Icon(Iconsax.user),
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.white),
      automaticallyImplyLeading: false,
      backgroundColor: MyColors.primaryColor,
      titleSpacing: 0,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Image.asset('assets/EdukidLogo.jpg', height: 50),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildNavButton(context, '/home', Iconsax.home, 'Home'),
                _buildNavButton(context, '/store', Iconsax.shop, 'Store'),
                _buildNavButton(context, '/bookings', Iconsax.task, 'Bookings'),
                _buildNavButton(context, '/order', Iconsax.note, 'Worksheets'),
                _buildNavButton(context, '/games', Iconsax.game, 'Games'),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: MySearchContainer(text: 'Search for Items'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(
      BuildContext context, String screenKey, IconData icon, String label) {
    String currentLocation = GoRouter.of(context).routerDelegate.currentConfiguration?.fullPath ?? '/';

    return TextButton.icon(
      icon: Icon(
        icon,
        color: currentLocation == screenKey ? Colors.yellow : Colors.white,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: currentLocation == screenKey ? Colors.yellow : Colors.white,
        ),
      ),
      onPressed: () {
        if (screenKey == '/bookings') {
          // Check if the user is logged in
          if (AuthenticationRepository.instance.authUser != null) {
            // Fetch bookings before navigating
            navController.fetchUserBookings().then((_) {
              context.go(screenKey); // Navigate after bookings are fetched
            });
          } else {
            context.go(screenKey); // Just navigate if no user
          }
        } else {
          context.go(screenKey);
        }
      },
    );
  }}
