import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../view_models/auth/login_view_model.dart';
import '../view_models/theme/theme_view_model.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => LoginViewModel()),
  ChangeNotifierProvider(create: (_) => ThemeProvider()),
];
