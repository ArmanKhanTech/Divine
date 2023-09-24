import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../data/models/gallery_params_model.dart';
import '../../pages/gallery_media_picker_controller.dart';
import 'change_path_widget.dart';
import 'dropdown.dart';

class SelectedPathDropdownButton extends StatelessWidget {
  final GalleryMediaPickerController provider;

  final MediaPickerParamsModel mediaPickerParams;

  const SelectedPathDropdownButton({
    Key? key,
    required this.provider,
    required this.mediaPickerParams
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arrowDownNotifier = ValueNotifier(false);

    return AnimatedBuilder(
      animation: provider.currentAlbumNotifier,
      builder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: DropDown<AssetPathEntity>(
            relativeKey: GlobalKey(),
            child: ((context) => buildButton(context, arrowDownNotifier))(context),
            dropdownWidgetBuilder: (BuildContext context, close) {
              return ChangePathWidget(
                provider: provider,
                close: close,
                mediaPickerParams: mediaPickerParams,
              );
            },
            onResult: (AssetPathEntity? value) {
              if (value != null) {
                provider.currentAlbum = value;
              }
            },
            onShow: (value) {
              arrowDownNotifier.value = value;
            },
          ),
        ),
      )
    );
  }

  Widget buildButton(
    BuildContext context,
    ValueNotifier<bool> arrowDownNotifier,
  ) {
    final decoration = BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
    );

    if (provider.pathList.isEmpty || provider.currentAlbum == null) {
      return Container();
    }

    if (provider.currentAlbum == null) {
      return Container();
    } else {
      return Container(
        decoration: decoration,
        alignment: Alignment.center,
        child: Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            SizedBox(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  provider.currentAlbum!.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: mediaPickerParams.appBarTextColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
              )
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
            ),
            const SizedBox(
              width: 10,
            )
          ],
        ),
      );
    }
  }
}
