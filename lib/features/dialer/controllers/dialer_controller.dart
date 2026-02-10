import 'package:get/get.dart';

class DialerController extends GetxController {
  final phoneNumber = ''.obs;

  void appendDigit(String digit) {
    if (digit.isEmpty) {
      return;
    }

    if (digit == '+') {
      if (phoneNumber.value.isEmpty) {
        phoneNumber.value = '+';
      }
      return;
    }

    if (phoneNumber.value.length >= 18) {
      return;
    }

    phoneNumber.value = phoneNumber.value + digit;
  }

  void backspace() {
    if (phoneNumber.value.isEmpty) {
      return;
    }
    phoneNumber.value =
        phoneNumber.value.substring(0, phoneNumber.value.length - 1);
  }

  void clear() {
    phoneNumber.value = '';
  }

  bool validateNumber() {
    final value = phoneNumber.value.trim();
    if (value.isEmpty) {
      Get.snackbar('Invalid number', 'Enter a phone number to continue.');
      return false;
    }

    final regex = RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value);
    if (!regex) {
      Get.snackbar('Invalid number', 'Use 7 to 15 digits, optional + prefix.');
      return false;
    }

    return true;
  }
}
