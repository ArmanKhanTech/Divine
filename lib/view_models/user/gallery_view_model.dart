import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../components/gallery_media_picker/src/data/models/picked_asset_model.dart';

class GalleryViewModel extends ChangeNotifier {
  List<PickedAssetModel> pickedFile = [];

  bool exceedsLimit = false;

  void reset() {
    pickedFile.clear();
  }

  void pickPath(PickedAssetModel path) {
    File file = File(path.path);
    if (file.lengthSync() > 4000000) {
      exceedsLimit = true;
      notifyListeners();

      return;
    } else {
      exceedsLimit = false;
      notifyListeners();
    }

    if (pickedFile.where((element) => element.id == path.id).isNotEmpty) {
      pickedFile.removeWhere((val) => val.id == path.id);
    } else {
      pickedFile.add(path);
    }
    notifyListeners();
  }

  showSnackBar(String message, BuildContext context) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(
        message: message,
      ),
    );
  }
}