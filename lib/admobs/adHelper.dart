import 'dart:io';

class adHelper {

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return '<ca-app-pub-8676869226236884/9325581556>';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_BANNER_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}