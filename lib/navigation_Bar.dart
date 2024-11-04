import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webedukid/features/screens/profilescreen/widgets/editprofile.dart';
import 'package:webedukid/utils/constants/colors.dart';
import 'common/data/repositories.authentication/authentication_repository.dart';
import 'common/widgets/customShapes/containers/search_container.dart';
import 'features/screens/navigation_controller.dart';
import 'features/screens/profilescreen/settings.dart';
import 'features/shop/cart/cart.dart';

class NavigationBarMenu extends StatefulWidget implements PreferredSizeWidget {
  NavigationBarMenu();

  @override
  NavigationBarMenuState createState() => NavigationBarMenuState();

  @override
  Size get preferredSize =>
      const Size.fromHeight(50); // Set appropriate height for the AppBar
}

class NavigationBarMenuState extends State<NavigationBarMenu> {
  bool _isEditProfileDrawerOpen = false;

  void toggleEditProfileDrawer() {
    setState(() {
      _isEditProfileDrawerOpen = !_isEditProfileDrawerOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => AuthenticationRepository());
    Get.lazyPut(() => NavigationController());
    final NavigationController navigationController = Get.find();

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
            Scaffold.of(context)
                .openEndDrawer();
          },
          icon: Icon(Iconsax.user),
        ),

      ],
      iconTheme: IconThemeData(color: Colors.white),
      // Set drawer icon to white

      automaticallyImplyLeading: false,
      foregroundColor: Colors.transparent,
      backgroundColor: MyColors.primaryColor,
      titleSpacing: 0,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: GestureDetector(
              onTap: () => context.go('/home'), // Navigate to home
              child: Image.asset('assets/EdukidLogo.jpg', height: 50),
            ),
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
    String currentLocation =
        GoRouter.of(context).routerDelegate.currentConfiguration?.fullPath ??
            '/';

    return TextButton.icon(
      icon: Icon(
        icon,
        color: currentLocation == screenKey
            ? Colors.yellow
            : Colors.white, // Active screen is yellow
      ),
      label: Text(
        label,
        style: TextStyle(
          color: currentLocation == screenKey
              ? Colors.yellow
              : Colors.white, // Active screen is yellow
        ),
      ),
      onPressed: () {
        context.go(screenKey);
      },
    );
  }
}
