import 'package:flutter/cupertino.dart';

class ReelsPage extends StatefulWidget{
  const ReelsPage({super.key});

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage>{
  @override
  Widget build(BuildContext context) {

    return const CupertinoPageScaffold(
      child: Center(
        child: Text('Activity Page'),
      ),
    );
  }
}