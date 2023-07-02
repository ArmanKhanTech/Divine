// This class is input validator.
// It will check if the input is valid or not.
class Regex {
  static String? validateName(String? value) {
    if (value!.isEmpty) return 'Your username is required.';
    final RegExp nameExp = RegExp(r'^[A-za-zğüşöçİĞÜŞÖÇ ]+$');
    if (!nameExp.hasMatch(value)) {
      return 'Please enter only alphabetical characters.';
    }
    return null;
  }

  static String? validateEmail(String? value, [bool isRequried = true]) {
    if (value!.isEmpty && isRequried) {
      return 'Your email is required.';
    }
    final RegExp nameExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (!nameExp.hasMatch(value) && isRequried) {
      return 'Invalid email address.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value!.isEmpty || value.length < 6) {
      return 'Please enter a valid password.';
    }
    return null;
  }
}
