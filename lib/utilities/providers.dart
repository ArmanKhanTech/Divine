import 'package:divine/view_models/user/story_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../view_models/auth/login_view_model.dart';
import '../view_models/screens/edit_profile_view_model.dart';
import '../view_models/screens/posts_view_model.dart';
import '../view_models/auth/register_view_model.dart';
import '../view_models/theme/theme_provider.dart';
import '../view_models/user/audio_view_model.dart';
import '../view_models/user/user_view_model.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => LoginViewModel()),
  ChangeNotifierProvider(create: (_) => RegisterViewModel()),
  ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
  ChangeNotifierProvider(create: (_) => PostsViewModel()),
  ChangeNotifierProvider(create: (_) => StoryViewModel()),
  ChangeNotifierProvider(create: (_) => UserViewModel()),
  ChangeNotifierProvider(create: (_) => AudioViewModel()),
  ChangeNotifierProvider(create: (_) => ThemeProvider()),
];
