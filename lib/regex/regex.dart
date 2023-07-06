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

  static String? validateEmail(String? value, [bool isRequired = true]) {
    if (value!.isEmpty && isRequired) {
      return 'Your email is required.';
    }
    final RegExp emailExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (!emailExp.hasMatch(value) && isRequired) {
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

  static String? validateCountry(String? value){
    if (value!.isEmpty) {
      return 'Please enter your country.';
    }
    return null;
  }

  static String? validateBio(String? value){
    if (value!.length > 1000) {
      return 'Bio must be short.';
    }
    return null;
  }

  static String? validateURL(String? value){
    final urlRegExp = RegExp(
        r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
    if (!urlRegExp.hasMatch(value!)) {
      return 'Please enter a valid URL.';
    }
    return null;
  }
}
