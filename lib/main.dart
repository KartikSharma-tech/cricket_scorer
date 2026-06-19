import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'services/hive_service.dart';
import 'screens/navigation_screen.dart';

void main() async {

  WidgetsFlutterBinding
      .ensureInitialized();

  // HIVE INIT

  await Hive.initFlutter();
  await HiveService.openBoxes();

  runApp(
    const CricketScorerApp(),
  );
}

class CricketScorerApp
    extends StatelessWidget {

  const CricketScorerApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner:
      false,

      theme: ThemeData.dark().copyWith(

        scaffoldBackgroundColor:
        const Color(0xff0F172A),

        appBarTheme:
        const AppBarTheme(

          backgroundColor:
          Color(0xff1E293B),
        ),

        elevatedButtonTheme:
        ElevatedButtonThemeData(

          style:
          ElevatedButton.styleFrom(

            backgroundColor:
            const Color(0xff2563EB),

            foregroundColor:
            Colors.white,
          ),
        ),

        inputDecorationTheme:
        InputDecorationTheme(

          filled: true,

          fillColor:
          const Color(0xff1E293B),

          border:
          OutlineInputBorder(

            borderRadius:
            BorderRadius.circular(
              15,
            ),

            borderSide:
            BorderSide.none,
          ),
        ),
      ),

      home:
      NavigationScreen(),
    );
  }
}