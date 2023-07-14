import 'dart:convert';
import 'package:deepar_flutter/deepar_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Filters extends StatefulWidget{
  const Filters({Key? key}) : super(key: key);

  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  late final DeepArController _controller;
  String version = '';
  bool _isFaceMask = false;
  bool _isFilter = false;

  final List<String> _effectsList = [];
  final List<String> _maskList = [];
  final List<String> _filterList = [];
  int _effectIndex = 0;
  int _maskIndex = 0;
  int _filterIndex = 0;

  final String _assetEffectsPath = 'assets/effects/';

  @override
  void initState() {
    _controller = DeepArController();
    _controller.initialize(
      androidLicenseKey: "f60357bfedbebef5fce8f6e88e477734da73f030baa53027ed537001b07991eb2493e0a0f45b14d6",
      iosLicenseKey: "---iOS key---",
      resolution: Resolution.high,
    ).then((value) => setState(() {}));
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _initEffects();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.black,
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarDividerColor: null,
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Material(
          color: Colors.black,
          child: Stack(
            children: [
              _controller.isInitialized
                  ? DeepArPreview(_controller)
                  : const Center(
                child: Text("Loading...", style: TextStyle(color: Colors.white),),
              ),
              _topMediaOptions(),
              _bottomMediaOptions(),
            ],
          ),
        ),
      )
    );
  }

  Positioned _topMediaOptions() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () async {
                await _controller.toggleFlash();
                setState(() {});
              },
              color: Colors.white70,
              iconSize: 30,
              icon:
              Icon(_controller.flashState ? Icons.flash_on : Icons.flash_off),
            ),
            IconButton(
              onPressed: () async {
                _isFaceMask = !_isFaceMask;
                if (_isFaceMask) {
                  _controller.switchFaceMask(_maskList[_maskIndex]);
                } else {
                  _controller.switchFaceMask("null");
                }

                setState(() {});
              },
              color: Colors.white70,
              iconSize: 30,
              icon: Icon(
                _isFaceMask
                    ? Icons.face_retouching_natural_rounded
                    : Icons.face_retouching_off,
              ),
            ),
            IconButton(
              onPressed: () async {
                _isFilter = !_isFilter;
                if (_isFilter) {
                  _controller.switchFilter(_filterList[_filterIndex]);
                } else {
                  _controller.switchFilter("null");
                }
                setState(() {});
              },
              color: Colors.white70,
              iconSize: 30,
              icon: Icon(
                _isFilter ? Icons.filter_hdr : Icons.filter_hdr_outlined,
              ),
            ),
            IconButton(
                onPressed: () {
                  _controller.flipCamera();
                },
                iconSize: 30,
                color: Colors.white70,
                icon: const Icon(Icons.cameraswitch))
          ],
        ),
      )
    );
  }

  Positioned _bottomMediaOptions() {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
              iconSize: 30,
              onPressed: () {
                if (_isFaceMask) {
                  String prevMask = _getPrevMask();
                  _controller.switchFaceMask(prevMask);
                } else if (_isFilter) {
                  String prevFilter = _getPrevFilter();
                  _controller.switchFilter(prevFilter);
                } else {
                  String prevEffect = _getPrevEffect();
                  _controller.switchEffect(prevEffect);
                }
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white70,
              )),
          IconButton(
              onPressed: () {
                _controller.takeScreenshot().then((file) {
                  _controller.destroy();
                  Navigator.of(context).pop(file.path);
                });
              },
              color: Colors.white70,
              iconSize: 30,
              icon: const Icon(Icons.photo_camera)),
          IconButton(
              iconSize: 30,
              onPressed: () {
                if (_isFaceMask) {
                  String nextMask = _getNextMask();
                  _controller.switchFaceMask(nextMask);
                } else if (_isFilter) {
                  String nextFilter = _getNextFilter();
                  _controller.switchFilter(nextFilter);
                } else {
                  String nextEffect = _getNextEffect();
                  _controller.switchEffect(nextEffect);
                }
              },
              icon: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
              )),
        ],
      ),
    );
  }

  /// Add effects which are rendered via DeepAR sdk
  void _initEffects() {
    _getEffectsFromAssets(context).then((values) {
      _effectsList.clear();
      _effectsList.addAll(values);

      _maskList.clear();
      _maskList.add('${_assetEffectsPath}flower_face.deepar');
      _maskList.add('${_assetEffectsPath}viking_helmet.deepar');

      _filterList.clear();
      _filterList.add('${_assetEffectsPath}burning_effect.deepar');
      _filterList.add('${_assetEffectsPath}Hope.deepar');

      _effectsList.removeWhere((element) => _maskList.contains(element));

      _effectsList.removeWhere((element) => _filterList.contains(element));
    });
  }

  Future<List<String>> _getEffectsFromAssets(BuildContext context) async {
    final manifestContent =
    await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final filePaths = manifestMap.keys
        .where((path) => path.startsWith(_assetEffectsPath))
        .toList();
    return filePaths;
  }

  /// Get next effect
  String _getNextEffect() {
    _effectIndex < _effectsList.length ? _effectIndex++ : _effectIndex = 0;
    return _effectsList[_effectIndex];
  }

  /// Get previous effect
  String _getPrevEffect() {
    _effectIndex > 0 ? _effectIndex-- : _effectIndex = _effectsList.length;
    return _effectsList[_effectIndex];
  }

  /// Get next mask
  String _getNextMask() {
    _maskIndex < _maskList.length ? _maskIndex++ : _maskIndex = 0;
    return _maskList[_maskIndex];
  }

  /// Get previous mask
  String _getPrevMask() {
    _maskIndex > 0 ? _maskIndex-- : _maskIndex = _maskList.length;
    return _maskList[_maskIndex];
  }

  /// Get next filter
  String _getNextFilter() {
    _filterIndex < _filterList.length ? _filterIndex++ : _filterIndex = 0;
    return _filterList[_filterIndex];
  }

  /// Get previous filter
  String _getPrevFilter() {
    _filterIndex > 0 ? _filterIndex-- : _filterIndex = _filterList.length;
    return _filterList[_filterIndex];
  }
}