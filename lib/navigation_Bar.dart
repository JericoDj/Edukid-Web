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
  Size get preferredSize => NavigationBarMenuState().dynamicPreferredSize.value;
}

class NavigationBarMenuState extends State<NavigationBarMenu> {
  final Rx<Size> dynamicPreferredSize = Rx<Size>(
    _getPreferredSize(MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width),
  );

  final NavigationController navigationController = Get.find();
  final MyDrawerController drawerController = Get.put(MyDrawerController());
  final NavigationController navController = Get.put(NavigationController());
  final AuthenticationRepository authRepo = Get.find<AuthenticationRepository>();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1200;
    final logoHeight = isMobile ? 80.0 : 80.0;

    return AppBar(
      actions: [
        IconButton(
          icon: const Icon(Iconsax.shopping_cart, color: Colors.white),
          onPressed: () => context.go('/cart'),
        ),
        IconButton(
          onPressed: () {
            drawerController.openDrawer();
            Scaffold.of(context).openEndDrawer();
          },
          icon: const Icon(Iconsax.user, color: Colors.white),
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
            onTap: () => _navigateToHome(context),
            child: Image.asset(
              'assets/logos/EdukidLogo.png',
              height: logoHeight,
            ),
          ),
          if (!isMobile) const SizedBox(width: 16),
          if (!isMobile)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: _buildNavButtons(context, isMobile),
              ),
            ),
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Dynamically calculate the width based on the screen width
                  final screenWidth = MediaQuery.of(context).size.width;
                  final containerWidth = screenWidth * 0.3; // Adjust percentage as needed
                  return Center(
                    child: SizedBox(
                      width: containerWidth,
                      child: MySearchContainer(text: 'Search for Items'),
                    ),
                  );
                },
              ),
            ),
          if (isMobile)
            IconButton(
              icon: const Icon(Iconsax.search_favorite, color: Colors.white),
              onPressed: () => context.go('/search'),
            ),
        ],
      ),
      bottom:  PreferredSize(
          preferredSize: dynamicPreferredSize.value,
          child: isMobile
              ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildNavButtons(context, isMobile),
            ),
          )
              : const SizedBox.shrink(), // Placeholder for desktop screens
        )

    );
  }

  @override
  Size get preferredSize => dynamicPreferredSize.value;

  static Size _getPreferredSize(double screenWidth) {
    if (screenWidth < 600) {
      return const Size.fromHeight(100.0); // Mobile screen
    } else if (screenWidth >= 600 && screenWidth < 1200) {
      return const Size.fromHeight(100.0); // Tablet screen
    } else {
      return const Size.fromHeight(60.0); // Desktop screen
    }
  }

  List<Widget> _buildNavButtons(BuildContext context, bool isMobile) {
    final navItems = [
      {'key': '/home', 'icon': Iconsax.home, 'label': 'Home'},
      {'key': '/store', 'icon': Iconsax.shop, 'label': 'Store'},
      {'key': '/bookings', 'icon': Iconsax.task, 'label': 'Bookings'},
      {'key': '/order', 'icon': Iconsax.note, 'label': 'Worksheets'},
      {'key': '/games', 'icon': Iconsax.game, 'label': 'Games'},
    ];

    return navItems.map((item) {
      final isSelected = _isCurrentScreen(context, item['key'] as String);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: isMobile
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item['icon'] as IconData,
              color: isSelected ? Colors.yellow : Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item['label'] as String,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.yellow : Colors.white,
              ),
            ),
          ],
        )
            : TextButton.icon(
          icon: Icon(
            item['icon'] as IconData,
            color: isSelected ? Colors.yellow : Colors.white,
          ),
          label: Text(
            item['label'] as String,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.yellow : Colors.white,
            ),
          ),
          onPressed: () => _handleNavigation(context, item['key'] as String),
        ),
      );
    }).toList();
  }

  void _handleNavigation(BuildContext context, String screenKey) {
    if (screenKey == '/home') {
      _navigateToHome(context);
    } else if (screenKey == '/bookings') {
      if (authRepo.authUser != null) {
        navController.fetchUserBookings().then((_) => context.go(screenKey));
      } else {
        context.go(screenKey);
      }
    } else {
      context.go(screenKey);
    }
  }

  bool _isCurrentScreen(BuildContext context, String screenKey) {
    final currentLocation = GoRouter.of(context).routerDelegate.currentConfiguration?.fullPath ?? '/';
    return currentLocation == screenKey;
  }

  void _navigateToHome(BuildContext context) {
    navigationController.clearSelectedCategory();
    context.go('/home');
  }
}
