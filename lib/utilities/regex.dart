class Regex {
  static String? validateUsername(String? value) {
    if (value!.isEmpty) {

      return 'Your username is required.';
    }
    final RegExp nameExp = RegExp(r'^(?=.{8,20}$)(?![_.])(?!.*[_.]{2})[a-z0-9._]+(?<![_.])$');
    if (!nameExp.hasMatch(value)) {

      return 'Please enter a valid username.';
    }

    return null;
  }

  static String? validateEmail(String? value, [bool isRequired = true]) {
    if (value!.isEmpty && isRequired) {

      return 'Your email is required.';
    }
    final RegExp emailExp = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
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

  static String? validateName(String? value){
    if (value!.length > 100) {

      return 'Invalid name.';
    }

    return null;
  }

  static String? validateURL(String? value){
    final RegExp urlRegExp = RegExp(r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
    if (!urlRegExp.hasMatch(value!) && value != '') {

      return 'Please enter a valid URL.';
    } else if (value.length > 500) {

      return 'URL must be short.';
    } else if (value == '') {

      return null;
    }

    return null;
  }

  static String? validateGender(String? value){
    if (value!.length > 20 && value != ''){

      return 'Please enter a valid gender.';
    } else if (value == '') {

      return null;
    }

    return null;
  }

  static String? validateProfession(String? value){
    if (value!.length > 20 && value != '') {

      return 'Please enter a valid profession.';
    } else if (value == '') {

      return null;
    }

    return null;
  }
}
