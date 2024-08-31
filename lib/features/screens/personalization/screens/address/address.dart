import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webedukid/features/screens/personalization/screens/address/widgets/single_address.dart';

import '../../../../../common/widgets/appbar.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/cloud_helper_functions.dart';
import '../../controllers/address_controller.dart';
import 'add_new_address.dart';

class UserAddressScreen extends StatelessWidget {
  const UserAddressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddressController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Center the AppBar title and back button
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0), // Add some top padding for spacing
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text(
                    'Addresses',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter, // Align to the top center
            child: Padding(
              padding: EdgeInsets.only(top: 20), // Adjust padding to avoid overlapping with AppBar
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(MySizes.defaultspace),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600), // Set a max width
                    child: Obx(
                          () => FutureBuilder(
                        key: Key(controller.refreshData.value.toString()),
                        future: controller.getAllUserAddresses(),
                        builder: (context, snapshot) {
                          final response = MyCloudHelperFunctions.checkMultiRecordState(snapshot: snapshot);
                          if (response != null) return Center(child: response);

                          final addresses = snapshot.data!;

                          if (addresses.isEmpty) {
                            return Center(
                              child: Text(
                                'No addresses found.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            );
                          }

                          return ListView.builder(

                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(), // Disable internal scrolling
                            itemCount: addresses.length,
                            itemBuilder: (__, index) => MySingleAddress(

                              address: addresses[index],
                              onTap: () => controller.selectAddress(addresses[index]),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Center the floating action button at the bottom
          Positioned(
            bottom: 16.0, // Position from the bottom
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: MyColors.primaryColor,
                onPressed: () => Get.to(() => const AddNewAddressScreen()),
                child: const Icon(Iconsax.add, color: MyColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
