import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

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
      height: 620,
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
              length: 3,
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
                                  child: Icon(Icons.audiotrack, size: 18)
                              ),
                              Text('Audio', style: TextStyle(fontSize: 15))
                            ]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                                padding: EdgeInsets.all(2),
                                child: Icon(Icons.mic, size: 18)
                            ),
                            Text('Voiceover', style: TextStyle(fontSize: 15))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                                padding: EdgeInsets.all(2),
                                child: Icon(Icons.upload, size: 18)
                            ),
                            Text('Upload', style: TextStyle(fontSize: 15))
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
                            height: 400.0,
                            margin: const EdgeInsets.all(10.0),
                            child: const Column(
                              children: [
                                /*TypeAheadField(
                                  textFieldConfiguration: TextFieldConfiguration(
                                      autofocus: true,
                                      style: DefaultTextStyle.of(context).style.copyWith(
                                          fontStyle: FontStyle.italic
                                      ),
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder()
                                      )
                                  ),
                                  suggestionsCallback: (pattern) async {
                                    return await BackendService.getSuggestions(pattern);
                                  },
                                  itemBuilder: (context, suggestion) {
                                    return ListTile(
                                      title: Text(suggestion.toString()),
                                    );
                                  },
                                  onSuggestionSelected: (suggestion) {
                                    //
                                  },
                                )*/
                              ]

                            )
                          ),
                        ),
                        const Center(
                          child: Icon(Icons.directions_transit, color: Colors.white),
                        ),
                        const Center(
                          child: Icon(Icons.directions_bike, color: Colors.white),
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