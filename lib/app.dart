import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

class RoutinyApp extends StatelessWidget {
  const RoutinyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'روتيني',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: MediaQuery.withClampedTextScaling(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.0,
          child: child!,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
