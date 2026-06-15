import 'package:flutter/material.dart';

import '../services/match_storage_service.dart';

import 'live_score_screen.dart';
import 'start_match_screen.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  bool hasSavedMatch = false;

  @override
  void initState() {

    super.initState();

    checkSavedMatch();
  }

  // CHECK SAVED MATCH

  void checkSavedMatch() async {

    bool loaded =

    await MatchStorageService
        .loadMatch();

    setState(() {

      hasSavedMatch = loaded;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Cricket Scorer",
        ),
      ),

      body: Padding(

        padding:
        const EdgeInsets.all(20),

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            // LOGO

            const Icon(

              Icons.sports_cricket,

              size: 120,

              color: Colors.green,
            ),

            const SizedBox(
              height: 30,
            ),

            const Text(

              "Live Cricket Scoring App",

              style: TextStyle(

                fontSize: 28,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            const Text(

              "Create matches, "
                  "track scores, "
                  "manage players "
                  "and continue saved games.",

              textAlign:
              TextAlign.center,

              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 50,
            ),

            // START NEW MATCH

            SizedBox(

              width:
              double.infinity,

              height: 65,

              child: ElevatedButton(

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.green,

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(
                      18,
                    ),
                  ),
                ),

                onPressed: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder:
                          (context) =>

                      const StartMatchScreen(),
                    ),
                  );
                },

                child: const Text(

                  "Start New Match",

                  style: TextStyle(

                    fontSize: 22,

                    color:
                    Colors.white,

                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // CONTINUE MATCH

            if(hasSavedMatch)

              SizedBox(

                width:
                double.infinity,

                height: 65,

                child: ElevatedButton(

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    Colors.orange,

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                    ),
                  ),

                  onPressed: () async {

                    await MatchStorageService
                        .loadMatch();

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder:
                            (context) =>

                        const LiveScoreScreen(),
                      ),
                    );
                  },

                  child: const Text(

                    "Continue Match",

                    style: TextStyle(

                      fontSize: 22,

                      color:
                      Colors.white,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}