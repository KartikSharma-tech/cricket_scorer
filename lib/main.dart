import 'package:flutter/material.dart';

import 'screens/navigation_screen.dart';

void main() {

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

      title: "Cricket Scorer",

      theme: ThemeData(

        brightness:
        Brightness.dark,

        scaffoldBackgroundColor:
        const Color(0xff0F172A),

        appBarTheme:
        const AppBarTheme(

          backgroundColor:
          Color(0xff1E293B),

          centerTitle: true,
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
      const NavigationScreen(),
    );
  }
}