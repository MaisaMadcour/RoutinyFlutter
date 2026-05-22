import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.I.init();
  await initializeDateFormatting('ar');
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFFF7E6DE),
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFFFDF5F1),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]);
  runApp(const RoutinyApp());
}
