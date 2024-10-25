import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../../../../common/widgets/loaders/circular_loader.dart';
import '../../../../common/widgets/loaders/loaders.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/cloud_helper_functions.dart';
import '../../../../utils/network manager/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../models/address_model.dart';
import '../../../../common/data/repositories.authentication/address/address_repository.dart';
import '../screens/address/widgets/single_address.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find();

  // Text Editing Controllers
  final name = TextEditingController();
  final phoneNumber = TextEditingController();
  final street = TextEditingController();
  final postalCode = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final country = TextEditingController();
  final GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();

  RxBool refreshData = true.obs;

  final Rx<AddressModel> selectedAddress = AddressModel.empty().obs;
  final AddressRepository addressRepository = Get.put(AddressRepository());

  /// Fetch all user-specific addresses
  Future<List<AddressModel>> getAllUserAddresses() async {
    try {
      final addresses = await addressRepository.fetchUserAddresses();
      selectedAddress.value = addresses.firstWhere(
            (element) => element.selectedAddress,
        orElse: () => AddressModel.empty(),
      );
      return addresses;
    } catch (e) {
      MyLoaders.errorSnackBar(
        title: 'Address not found',
        message: e.toString(),
      );
      return [];
    }
  }
  Future<void> selectAddress(BuildContext context, AddressModel newSelectedAddress) async {
    try {
      // Show Loader Dialog
      showDialog(
        context: context, // Use the context passed as an argument
        barrierDismissible: false,
        builder: (_) => MyCircularLoader(),
      );

      // Clear the "selected" field
      if (selectedAddress.value.id.isNotEmpty) {
        await addressRepository.updateSelectedField(
          selectedAddress.value.id,
          false,
        );
      }

      // Assign new selected address
      newSelectedAddress.selectedAddress = true;
      selectedAddress.value = newSelectedAddress;

      // Update the new selected field to true
      await addressRepository.updateSelectedField(
        selectedAddress.value.id,
        true,
      );

      // Close the loader
      Navigator.pop(context);
    } catch (e) {
      MyLoaders.errorSnackBar(
        title: 'Error in Selection',
        message: e.toString(),
      );
    }
  }


  /// Show Modal Bottom Sheet at Checkout
  Future<dynamic> selectNewAddressPopup(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(MySizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MySectionHeading(
                title: 'Select Address',
                showActionButton: false,
              ),
              const SizedBox(height: MySizes.spaceBtwSections),
              FutureBuilder(
                future: getAllUserAddresses(),
                builder: (_, snapshot) {
                  final response = MyCloudHelperFunctions.checkMultiRecordState(
                    snapshot: snapshot,
                  );
                  if (response != null) return response;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) => MySingleAddress(
                      address: snapshot.data![index],
                      onTap: () async {
                        await selectAddress(context, snapshot.data![index]);
                        context.pop(); // Close the bottom sheet
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: MySizes.defaultspace * 2),
              // Add new address button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context != null) {
                        context.push('/addNewAddress'); // Ensure context is non-null
                      } else {
                        print("Context is null, cannot navigate.");
                      }
                    });
                  },
                  child: const Text('Add new address'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Add new Address
  Future<void> addNewAddress() async {
    try {
      // Start Loading
      MyFullScreenLoader.openLoadingDialog(
        'Storing Address...',
        MyImages.loaders,
      );

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!addressFormKey.currentState!.validate()) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      // Save Address Data
      final address = AddressModel(
        id: '',
        name: name.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        street: street.text.trim(),
        city: city.text.trim(),
        state: state.text.trim(),
        postalCode: postalCode.text.trim(),
        country: country.text.trim(),
        selectedAddress: true,
      );

      final id = await addressRepository.addAddress(address);

      // Update Selected Address Status
      address.id = id;
      await selectAddress(Get.context!, address);



      // Remove Loader
      MyFullScreenLoader.stopLoading();

      // Show Success Message
      MyLoaders.successSnackBar(
        title: 'Congratulations',
        message: 'Your address has been saved successfully.',
      );

      // Refresh Addresses Data
      refreshData.toggle();

      // Reset fields
      resetFormFields();

      // Redirect or close screen
      Navigator.of(Get.context!).pop();
    } catch (e) {
      // Remove Loader
      MyFullScreenLoader.stopLoading();
      MyLoaders.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    }
  }

  /// Reset form fields
  void resetFormFields() {
    name.clear();
    phoneNumber.clear();
    street.clear();
    postalCode.clear();
    city.clear();
    state.clear();
    country.clear();
    addressFormKey.currentState?.reset();
  }
}
