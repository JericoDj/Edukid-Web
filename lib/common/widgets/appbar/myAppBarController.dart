
import 'package:get/get.dart';


class PreviousScreenController extends GetxController {
  RxString updatedName = ''.obs;

  void updateUIWithData(String newData) {
    updatedName.value = newData;
  }
}