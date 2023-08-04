import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divine/models/user_model.dart';
import 'package:divine/utilities/firebase.dart';
import 'package:divine/view_models/theme/theme_provider.dart';
import 'package:divine/widgets/progress_indicators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../../view_models/screens/edit_profile_view_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>{
  @override
  Widget build(BuildContext context) {
    EditProfileViewModel viewModel = Provider.of<EditProfileViewModel>(context);

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
            fontSize: 30,
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
          shrinkWrap: true,
          children: <Widget>[
            const ListTile(
                title: Text(
                  "About",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
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
                    fontSize: 18
                ),
              ),
              subtitle: const Text(
                "Toggle dark mode",
                style: TextStyle(
                  fontSize: 15
                ),
              ),
              trailing: SizedBox(
                width: 50,
                height: 40,
                child: Consumer<ThemeProvider>(
                  builder: (context, notifier, child) =>
                  CupertinoSwitch(
                    onChanged: (val) {
                      notifier.toggleTheme();
                    },
                    value: notifier.dark,
                    activeColor: Colors.blue,
                  ),
                ),
              )
            ),
            const Divider(),
            ListTile(
              title: const Text(
                "Private Account",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                ),
              ),
              subtitle: const Text(
                "Make your account private",
                style: TextStyle(
                    fontSize: 15
                ),
              ),
              trailing: SizedBox(
                width: 50,
                height: 40,
                child: StreamBuilder(
                  stream: usersRef.doc(auth.currentUser?.uid).snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasData) {
                      UserModel user = UserModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);

                      if(user.type == 'public'){

                        return CupertinoSwitch(
                          onChanged: (val) {
                            viewModel.updateProfileStatus(context, 'private');
                          },
                          value: false,
                          activeColor: Colors.blue,
                        );
                      } else {

                        return CupertinoSwitch(
                          onChanged: (val) {
                            viewModel.updateProfileStatus(context, 'public');
                          },
                          value: true,
                          activeColor: Colors.blue,
                        );
                      }
                    } else {

                      return circularProgress(context, const Color(0xff00c6ff));
                    }
                  },
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}