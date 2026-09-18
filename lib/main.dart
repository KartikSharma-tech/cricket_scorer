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

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff2563EB),
          brightness: Brightness.dark,
          surface: const Color(0xff1E293B),
        ),

        appBarTheme:
        const AppBarTheme(

          backgroundColor:
          Color(0xff1E293B),

          elevation: 0,

          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),

        cardTheme: CardThemeData(
          color: const Color(0xff1E293B),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.06)),
          ),
        ),

        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xff1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        elevatedButtonTheme:
        ElevatedButtonThemeData(

          style:
          ElevatedButton.styleFrom(

            backgroundColor:
            const Color(0xff2563EB),

            foregroundColor:
            Colors.white,

            elevation: 0,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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