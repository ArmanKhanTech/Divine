import 'package:audioplayers/audioplayers.dart';
import 'package:divine/view_models/user/audio_view_model.dart';
import 'package:divine/widgets/progress_indicators.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/wave_slider.dart';

class AudioOverlayBottomSheet extends StatefulWidget {
  final Function onDone;

  const AudioOverlayBottomSheet({
    super.key, required this.onDone,
  });

  @override
  State<AudioOverlayBottomSheet> createState() => _AudioOverlayBottomSheetState();
}

class _AudioOverlayBottomSheetState extends State<AudioOverlayBottomSheet> {
  double slider = 0.0;

  String buttonText = 'Play';
  String currentPosition = '00:00';

  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AudioViewModel viewModel = Provider.of<AudioViewModel>(context);

    return WillPopScope(
      onWillPop: () async {
        viewModel.resetAudio();
        return true;
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20)),
            border: Border(
              top: BorderSide(width: 1, color: Colors.white),
              bottom: BorderSide(width: 0, color: Colors.white),
              left: BorderSide(width: 0, color: Colors.white),
              right: BorderSide(width: 0, color: Colors.white),
            )
        ),
        child: Column(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(
                    top: 15.0,
                    bottom: 10.0,
                  ),
                  child: Center(
                    child:Text(
                      'Choose',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
            ),
            const Divider(
              color: Colors.white,
              thickness: 1,
            ),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 550.0,
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(
                          left: 10,
                          right: 10
                      ),
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black,
                      ),
                      child: TabBar(
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.white,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        tabs: const [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: EdgeInsets.all(2),
                                    child: Icon(Icons.audiotrack, size: 20)
                                ),
                                Text('Audio', style: TextStyle(fontSize: 18))
                              ]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: EdgeInsets.all(2),
                                  child: Icon(Icons.upload, size: 20)
                              ),
                              Text('Upload', style: TextStyle(fontSize: 18))
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: <Widget>[
                          Center(
                            child: Container(
                                height: double.infinity,
                                margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                                child: Column(
                                    children: [
                                      SizedBox(
                                        height: 50.0,
                                        child: TextFormField(
                                          style: const TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            alignLabelWithHint: true,
                                            labelText: 'Search',
                                            labelStyle: const TextStyle(color: Colors.white, fontSize: 18.0),
                                            hintText: 'Any song, artist, or album',
                                            hintStyle: const TextStyle(color: Colors.white70),
                                            enabled: true,
                                            enabledBorder: const OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white),
                                                borderRadius: BorderRadius.all(Radius.circular(30.0)
                                                )
                                            ),
                                            border: const OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white, width: 0.0),
                                                borderRadius: BorderRadius.all(Radius.circular(30.0)
                                                )
                                            ),
                                            focusedBorder:OutlineInputBorder(
                                              borderSide: const BorderSide(color: Colors.white, width: 1.0),
                                              borderRadius: BorderRadius.circular(30.0),
                                            ),
                                            isDense: true,                      // Added this
                                            contentPadding: const EdgeInsets.all(10),
                                            isCollapsed: true,
                                          ),
                                          textAlignVertical: TextAlignVertical.center,
                                          cursorColor: Colors.white,
                                          maxLines: null,
                                          onChanged: (val) {
                                            // do something
                                          },
                                        ),
                                      )
                                    ]

                                )
                            ),
                          ),
                          SizedBox(
                            height: double.infinity,
                            child: Stack(
                                children : [
                                  viewModel.audioLoading == false && viewModel.audioLoaded == false ? Center(
                                    child: Container(
                                      height: 200,
                                      width: 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.black,
                                      ),
                                      child: Center(
                                          child: Column(
                                            children: [
                                              const Icon(Icons.upload, size: 50, color: Colors.white),
                                              const SizedBox(height: 10),
                                              const Text(
                                                'Upload Your Own Audio',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              TextButton(
                                                onPressed: () async {
                                                  viewModel.chooseAudio(context).then((value) async {
                                                    await player.play(
                                                      DeviceFileSource(value),
                                                      position: Duration(seconds: viewModel.start.toInt()),
                                                      mode: PlayerMode.mediaPlayer,
                                                    );
                                                    viewModel.setAudioDuration(await player.getDuration());
                                                    player.onPositionChanged.listen((Duration duration) {
                                                      setState(() {
                                                        slider = duration.inSeconds.toDouble();
                                                        if (slider == viewModel.end) {
                                                          player.pause();
                                                          setState(() {
                                                            buttonText = 'Play';
                                                          });
                                                        }
                                                        if (duration.inSeconds < 10) {
                                                          currentPosition = '00:0${duration.inSeconds}';
                                                        } else if (duration.inSeconds < 60) {
                                                          currentPosition = '00:${duration.inSeconds}';
                                                        } else if (duration.inSeconds < 600) {
                                                          if (duration.inSeconds % 60 < 10) {
                                                            currentPosition = '0${duration.inSeconds ~/ 60}:0${duration.inSeconds % 60}';
                                                          } else {
                                                            currentPosition = '0${duration.inSeconds ~/ 60}:${duration.inSeconds % 60}';
                                                          }
                                                        } else {
                                                          if (duration.inSeconds % 60 < 10) {
                                                            currentPosition = '${duration.inSeconds ~/ 60}:0${duration.inSeconds % 60}';
                                                          } else {
                                                            currentPosition = '${duration.inSeconds ~/ 60}:${duration.inSeconds % 60}';
                                                          }
                                                        }
                                                      });
                                                    });
                                                  });

                                                },
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                                    color: Colors.white,
                                                  ),
                                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                                                  child: const Text(
                                                    'Upload',
                                                    style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                      ),
                                    ),
                                  ) : Visibility(
                                    visible: viewModel.audioLoading == true && viewModel.audioLoaded == false,
                                    child: Center(
                                      child: circularProgress(context, const Color(0xffffffff)),
                                    ),
                                  ),
                                  viewModel.audioLoaded == true ? Center(
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        Text(
                                          viewModel.audioName,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        WaveSlider(
                                          backgroundColor: Colors.black,
                                          heightWaveSlider: 100,
                                          sliderColor: Colors.red,
                                          wavActiveColor: Colors.blue,
                                          wavDeactiveColor: Colors.white,
                                          duration: viewModel.audioDuration!.inSeconds.toDouble(),
                                          callbackStart: (duration) {
                                            viewModel.setStart(duration);
                                          },
                                          callbackEnd: (duration) {
                                            viewModel.setEnd(duration);
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 20),
                                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                                            color: Colors.black,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${viewModel.start} to ${viewModel.end} seconds',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        ),
                                        const SizedBox(height: 10),
                                        TextButton(
                                          onPressed: () async {
                                            if(player.state == PlayerState.paused) {
                                              player.resume();
                                              setState(() {
                                                buttonText = 'Pause';
                                              });
                                            } else if (player.state == PlayerState.playing) {
                                              player.pause();
                                              setState(() {
                                                buttonText = 'Play';
                                              });
                                            }
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 10),
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(20)),
                                              color: Colors.white,
                                            ),
                                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  buttonText,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20.0,
                                                      fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Container(
                                                  color: Colors.black,
                                                  height: 20,
                                                  width: 1,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  currentPosition,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20.0,
                                                      fontWeight: FontWeight.bold
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          height: 40,
                                          margin: const EdgeInsets.symmetric(horizontal: 20),
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                                            color: Colors.black,
                                          ),
                                          child: Row(
                                            children: [
                                              const Text(
                                                '00:00',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              SizedBox(
                                                height: 20,
                                                child: Slider(
                                                  value: slider,
                                                  onChanged: (value) {
                                                    player.seek(Duration(seconds: value.toInt()));
                                                    setState(() {
                                                      slider = value;
                                                    });
                                                  },
                                                  min: 0,
                                                  max: viewModel.audioDuration!.inSeconds.toDouble(),
                                                  activeColor: Colors.white,
                                                  inactiveColor: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                '0${viewModel.audioDuration?.inMinutes}:${viewModel.audioDuration!.inSeconds - (viewModel.audioDuration!.inMinutes * 60)}',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                        TextButton(
                                          onPressed: () {
                                            //
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 10),
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(20)),
                                              color: Colors.white,
                                            ),
                                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                                            child: const Text(
                                              'Upload & Use',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ) : Container(),
                                ]
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}