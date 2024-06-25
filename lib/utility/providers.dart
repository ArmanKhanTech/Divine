import 'package:divine/viewmodel/user/story_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../viewmodel/auth/login_view_model.dart';
import '../viewmodel/screens/edit_profile_view_model.dart';
import '../viewmodel/screens/posts_view_model.dart';
import '../viewmodel/auth/register_view_model.dart';
import '../viewmodel/theme/theme_provider.dart';
import '../viewmodel/user/user_view_model.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => LoginViewModel()),
  ChangeNotifierProvider(create: (_) => RegisterViewModel()),
  ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
  ChangeNotifierProvider(create: (_) => PostsViewModel()),
  ChangeNotifierProvider(create: (_) => StoryViewModel()),
  ChangeNotifierProvider(create: (_) => UserViewModel()),
  ChangeNotifierProvider(create: (_) => ThemeProvider()),
];
