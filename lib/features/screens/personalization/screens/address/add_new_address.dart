import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';

import '../../../../../common/widgets/appbar.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/validators/validation.dart';
import '../../controllers/address_controller.dart';

class AddNewAddressScreen extends StatelessWidget {
  const AddNewAddressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = AddressController.instance;

    return Align(
      alignment: Alignment.topCenter,
      child: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: 800,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(MySizes.defaultspace),
                child: Column(
                  children: [
                    Text(
                      'Add new Address',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: MySizes.spaceBtwItems),
                    Container(
                      child: Form(
                        key: controller.addressFormKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: controller.name,
                              validator: (value) =>
                                  MyValidator.validateEmptyText('Name', value),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Iconsax.user),
                                labelText: 'Name',
                              ),
                            ),
                            const SizedBox(height: MySizes.spaceBtwInputItems),
                            TextFormField(
                              controller: controller.phoneNumber,
                              validator: MyValidator.validatePhoneNumber,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Iconsax.mobile),
                                labelText: 'Phone Number',
                              ),
                            ),
                            const SizedBox(height: MySizes.spaceBtwInputItems),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: controller.street,
                                    validator: (value) => MyValidator.validateEmptyText('Street', value),
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Iconsax.building_31),
                                      labelText: 'Street',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: MySizes.spaceBtwInputItems),
                                Expanded(
                                  child: TextFormField(
                                    controller: controller.postalCode,
                                    validator: (value) => MyValidator.validateEmptyText('Postal Code', value),
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Iconsax.code),
                                      labelText: 'Postal Code',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: MySizes.spaceBtwInputItems),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: controller.city,
                                    validator: (value) => MyValidator.validateEmptyText('City', value),
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Iconsax.building),
                                      labelText: 'City',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: MySizes.spaceBtwInputItems),
                                Expanded(
                                  child: TextFormField(
                                    controller: controller.state,
                                    validator: (value) => MyValidator.validateEmptyText('State', value),
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Iconsax.activity),
                                      labelText: 'State',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: MySizes.spaceBtwInputItems),
                            TextFormField(
                              controller: controller.country,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Iconsax.global),
                                labelText: 'Country',
                              ),
                            ),
                            const SizedBox(height: MySizes.defaultspace),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  controller.addNewAddress(context);
                                },
                                child: Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
