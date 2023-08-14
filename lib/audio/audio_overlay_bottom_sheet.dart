import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
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
                            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 65.0,
                                  child: TextFormField(
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                        alignLabelWithHint: true,
                                        labelText: 'Search',
                                        labelStyle: TextStyle(color: Colors.white, fontSize: 18.0),
                                        hintText: 'Any song, artist, or album',
                                        hintStyle: TextStyle(color: Colors.white70),
                                        enabled: true,
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.white),
                                            borderRadius: BorderRadius.all(Radius.circular(30.0)
                                            )
                                        ),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.white, width: 0.0),
                                            borderRadius: BorderRadius.all(Radius.circular(30.0)
                                            )
                                        )
                                    ),
                                    textAlign: TextAlign.center,
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
                        const Center(
                          child: Icon(Icons.directions_transit, color: Colors.white),
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
    );
  }
}