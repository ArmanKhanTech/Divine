import 'package:flutter/cupertino.dart';

class SearchPage extends StatefulWidget{
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>{
  @override
  Widget build(BuildContext context) {

    return const CupertinoPageScaffold(
      child: Center(
        child: Text('Activity Page'),
      ),
    );
  }

}