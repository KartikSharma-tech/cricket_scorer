import 'package:flutter/material.dart';

import '../services/match_storage_service.dart';

import 'add_player_screen.dart';
import 'live_score_screen.dart';
import 'start_match_screen.dart';

class NavigationScreen extends StatefulWidget {

  const NavigationScreen({
    super.key,
  });

  @override
  State<NavigationScreen> createState() =>
      _NavigationScreenState();
}

class _NavigationScreenState
    extends State<NavigationScreen> {

  bool hasLiveMatch = false;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    checkLiveMatch();
  }

  // =========================
  // CHECK LIVE MATCH
  // =========================

  Future<void> checkLiveMatch() async {

    bool matchExists =

    await MatchStorageService
        .loadMatch();

    setState(() {

      hasLiveMatch =
          matchExists;

      isLoading = false;
    });
  }

  // =========================
  // BUTTON
  // =========================

  Widget homeButton({

    required String title,

    required IconData icon,

    required VoidCallback onTap,

    Color color = Colors.blue,

  }) {

    return SizedBox(

      width: double.infinity,

      height: 70,

      child: ElevatedButton.icon(

        style:
        ElevatedButton.styleFrom(

          backgroundColor: color,

          shape:
          RoundedRectangleBorder(

            borderRadius:
            BorderRadius.circular(
              18,
            ),
          ),
        ),

        onPressed: onTap,

        icon: Icon(
          icon,
          color: Colors.white,
        ),

        label: Text(

          title,

          style: const TextStyle(

            fontSize: 20,

            color: Colors.white,

            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Cricket Scorer",
        ),

        centerTitle: true,
      ),

      body: isLoading

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : Padding(

        padding:
        const EdgeInsets.all(20),

        child: Column(

          children: [

            const SizedBox(
              height: 20,
            ),

            // RESUME MATCH

            if(hasLiveMatch)

              homeButton(

                title: "Resume Match",

                icon: Icons.play_circle,

                color: Colors.orange,

                onTap: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (context) {

                        return const
                        LiveScoreScreen();
                      },
                    ),
                  ).then((value){

                    checkLiveMatch();
                  });
                },
              ),

            if(hasLiveMatch)

              const SizedBox(
                height: 20,
              ),

            // START MATCH

            homeButton(

              title: "Start Match",

              icon: Icons.sports_cricket,

              color: Colors.green,

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (context) {

                      return const
                      StartMatchScreen();
                    },
                  ),
                ).then((value){

                  checkLiveMatch();
                });
              },
            ),

            const SizedBox(
              height: 20,
            ),

            // ADD PLAYERS

            homeButton(

              title: "Add Players",

              icon: Icons.person_add,

              color: Colors.blue,

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (context) {

                      return const
                      AddPlayerScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}