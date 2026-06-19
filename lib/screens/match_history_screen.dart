
import 'package:flutter/material.dart';

import '../models/match_history_model.dart';
import '../services/hive_service.dart';

class MatchHistoryScreen
    extends StatefulWidget {

  const MatchHistoryScreen({
    super.key,
  });

  @override
  State<MatchHistoryScreen>
  createState() =>

      _MatchHistoryScreenState();
}

class _MatchHistoryScreenState
    extends State<MatchHistoryScreen> {

  // =========================
  // MATCHES
  // =========================

  List<MatchHistoryModel>
  matches = [];

  // =========================
  // INIT
  // =========================

  @override
  void initState() {
    super.initState();

    loadMatches();
  }

  // =========================
  // LOAD MATCHES
  // =========================

  void loadMatches(){

    matches =
        HiveService
            .getMatchHistory();

    setState(() {});
  }

  // =========================
  // MATCH CARD
  // =========================

  Widget matchCard(
      MatchHistoryModel match,
      ){

    return Card(

      elevation: 4,

      margin:
      const EdgeInsets.only(
        bottom: 15,
      ),

      shape:
      RoundedRectangleBorder(

        borderRadius:
        BorderRadius.circular(
          18,
        ),
      ),

      child: Padding(

        padding:
        const EdgeInsets.all(18),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // TEAMS

            Text(

              "${match.teamAName}"

                  " vs "

                  "${match.teamBName}",

              style: const TextStyle(

                fontSize: 22,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            // SCORE

            Text(

              "${match.teamAName} : "

                  "${match.teamAScore}"

                  "/"

                  "${match.teamAWickets}",

              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(

              "${match.teamBName} : "

                  "${match.teamBScore}"

                  "/"

                  "${match.teamBWickets}",

              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            // RESULT

            Text(

              match.result,

              style: const TextStyle(

                fontSize: 18,

                fontWeight:
                FontWeight.bold,

                color: Colors.green,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            // DATE

            Text(

              "Date : "

                  "${match.matchDate.day}/"

                  "${match.matchDate.month}/"

                  "${match.matchDate.year}",
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              "Overs : ${match.overs}",
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Match History",
        ),

        centerTitle: true,
      ),

      body: matches.isEmpty

          ? const Center(

        child: Text(

          "No Match History",

          style: TextStyle(
            fontSize: 20,
          ),
        ),
      )

          : ListView.builder(

        padding:
        const EdgeInsets.all(20),

        itemCount:
        matches.length,

        itemBuilder:
            (context, index){

          return matchCard(
            matches[index],
          );
        },
      ),
    );
  }
}
