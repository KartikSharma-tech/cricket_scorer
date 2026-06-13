import 'package:flutter/material.dart';
import '../models/player_model.dart';

class LiveScoreScreen extends StatefulWidget {
  const LiveScoreScreen({super.key});

  @override
  State<LiveScoreScreen> createState() => _LiveScoreScreenState();
}

class _LiveScoreScreenState extends State<LiveScoreScreen> {

  int totalRuns = 0;
  int wickets = 0;

  int over = 0;
  int ball = 0;

  PlayerModel striker =
  PlayerModel(name: "Virat");

  PlayerModel nonStriker =
  PlayerModel(name: "Rohit");

  int bowlerRuns = 0;
  int bowlerBalls = 0;

  void swapStrike(){

    PlayerModel temp = striker;

    striker = nonStriker;
    nonStriker = temp;
  }

  void addRun(int run){

    setState(() {

      totalRuns += run;

      striker.runs += run;
      striker.balls++;

      bowlerRuns += run;
      bowlerBalls++;

      ball++;

      if(run == 1 || run == 3){
        swapStrike();
      }

      if(ball == 6){

        over++;
        ball = 0;

        swapStrike();
      }
    });
  }

  void addWide(){

    setState(() {

      totalRuns += 1;
      bowlerRuns += 1;
    });
  }

  void addNoBall(){

    setState(() {

      totalRuns += 1;
      bowlerRuns += 1;
    });
  }

  void addWicket(){

    setState(() {

      wickets++;

      striker.balls++;

      bowlerBalls++;

      ball++;

      if(ball == 6){

        over++;
        ball = 0;

        swapStrike();
      }
    });
  }

  double getEconomy(){

    double oversBowled =
        over + (ball / 6);

    if(oversBowled == 0){
      return 0;
    }

    return bowlerRuns / oversBowled;
  }

  double getStrikeRate(PlayerModel player){

    if(player.balls == 0){
      return 0;
    }

    return (player.runs / player.balls) * 100;
  }

  Widget runButton(String text, VoidCallback onTap){

    return SizedBox(
      width: 80,
      height: 60,

      child: ElevatedButton(

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff1E293B),
        ),

        onPressed: onTap,

        child: Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Live Score"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                color: const Color(0xff1E293B),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                children: [

                  Text(
                    "$totalRuns/$wickets",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Overs: $over.$ball",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: const Color(0xff1E293B),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Batsmen",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    striker.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Runs: ${striker.runs}",
                    style: const TextStyle(fontSize: 18),
                  ),

                  Text(
                    "Balls: ${striker.balls}",
                    style: const TextStyle(fontSize: 18),
                  ),

                  Text(
                    "Strike Rate: ${getStrikeRate(striker).toStringAsFixed(1)}",
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    nonStriker.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Runs: ${nonStriker.runs}",
                    style: const TextStyle(fontSize: 18),
                  ),

                  Text(
                    "Balls: ${nonStriker.balls}",
                    style: const TextStyle(fontSize: 18),
                  ),

                  Text(
                    "Strike Rate: ${getStrikeRate(nonStriker).toStringAsFixed(1)}",
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: const Color(0xff1E293B),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Bowler",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "Runs Given: $bowlerRuns",
                    style: const TextStyle(fontSize: 18),
                  ),

                  Text(
                    "Overs: $over.$ball",
                    style: const TextStyle(fontSize: 18),
                  ),

                  Text(
                    "Economy: ${getEconomy().toStringAsFixed(1)}",
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Wrap(
              spacing: 12,
              runSpacing: 12,

              children: [

                runButton("0", (){
                  addRun(0);
                }),

                runButton("1", (){
                  addRun(1);
                }),

                runButton("2", (){
                  addRun(2);
                }),

                runButton("4", (){
                  addRun(4);
                }),

                runButton("6", (){
                  addRun(6);
                }),

                runButton("W", (){
                  addWicket();
                }),

                runButton("WD", (){
                  addWide();
                }),

                runButton("NB", (){
                  addNoBall();
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}