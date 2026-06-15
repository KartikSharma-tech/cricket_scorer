import 'package:flutter/material.dart';

import 'add_player_screen.dart';
import 'home_screen.dart';
import 'start_match_screen.dart';

class NavigationScreen
    extends StatefulWidget {

  const NavigationScreen({
    super.key,
  });

  @override
  State<NavigationScreen> createState() =>
      _NavigationScreenState();
}

class _NavigationScreenState
    extends State<NavigationScreen> {

  int currentIndex = 0;

  List<Widget> pages = [

    const HomeScreen(),

    const AddPlayerScreen(),

    const StartMatchScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: pages[currentIndex],

      bottomNavigationBar:

      BottomNavigationBar(

        currentIndex:
        currentIndex,

        backgroundColor:
        const Color(0xff1E293B),

        selectedItemColor:
        Colors.green,

        unselectedItemColor:
        Colors.grey,

        onTap: (index){

          setState(() {

            currentIndex = index;
          });
        },

        items: const [

          BottomNavigationBarItem(

            icon: Icon(Icons.home),

            label: "Home",
          ),

          BottomNavigationBarItem(

            icon: Icon(Icons.people),

            label: "Players",
          ),

          BottomNavigationBarItem(

            icon: Icon(Icons.sports_cricket),

            label: "Match",
          ),
        ],
      ),
    );
  }
}