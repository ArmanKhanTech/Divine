import 'package:divine/viewmodels/user/story_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../viewmodels/auth/login_view_model.dart';
import '../viewmodels/screens/edit_profile_view_model.dart';
import '../viewmodels/screens/posts_view_model.dart';
import '../viewmodels/auth/register_view_model.dart';
import '../viewmodels/theme/theme_provider.dart';
import '../viewmodels/user/user_view_model.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => LoginViewModel()),
  ChangeNotifierProvider(create: (_) => RegisterViewModel()),
  ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
  ChangeNotifierProvider(create: (_) => PostsViewModel()),
  ChangeNotifierProvider(create: (_) => StoryViewModel()),
  ChangeNotifierProvider(create: (_) => UserViewModel()),
  ChangeNotifierProvider(create: (_) => ThemeProvider()),
];
