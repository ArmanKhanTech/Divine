import 'package:divine/view_models/theme/theme_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
          iconSize: 30.0,
          color: Theme.of(context).colorScheme.secondary,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0.0,
        title: GradientText(
          'Settings',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w300,
          ), colors: const [
          Colors.blue,
          Colors.purple,
        ],
        ),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            const ListTile(
                title: Text(
                  "About",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                ),
                subtitle: Text(
                  "A social media made on Flutter by Arman Khan",
                  style: TextStyle(
                    fontSize: 15
                  ),
                ),
                trailing: Icon(Icons.error)),
            const Divider(),
            ListTile(
              title: const Text(
                "Dark Mode",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                ),
              ),
              subtitle: const Text(
                "Toggle dark mode",
                style: TextStyle(
                  fontSize: 15
                ),
              ),
              trailing: Consumer<ThemeViewModel>(
                builder: (context, notifier, child) =>
                    CupertinoSwitch(
                      onChanged: (val) {
                        notifier.toggleTheme();
                      },
                      value: notifier.dark,
                      activeColor: Colors.blue,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}