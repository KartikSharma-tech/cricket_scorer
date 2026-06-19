import '../models/player_model.dart';
import '../models/ball_model.dart';

class MatchService {

  // =========================
  // TEAM INFO
  // =========================

  static String teamAName = "";

  static String teamBName = "";

  static int totalOvers = 0;

  // =========================
  // SCORE
  // =========================

  static int totalRuns = 0;

  static int wickets = 0;

  static int over = 0;

  static int ball = 0;

  // =========================
  // EXTRAS
  // =========================

  static int wides = 0;

  static int noBalls = 0;

  static int byes = 0;

  static int legByes = 0;

  // =========================
  // INNINGS
  // =========================

  static bool isSecondInnings = false;

  static bool isMatchEnded = false;

  static int firstInningsScore = 0;

  static int target = 0;

  // =========================
  // RESULT
  // =========================

  static String resultText = "";

  // =========================
  // PLAYERS
  // =========================

  static List<PlayerModel>
  battingPlayers = [];

  static List<PlayerModel>
  bowlingPlayers = [];

  static List<PlayerModel>
  outPlayers = [];

  static PlayerModel? striker;

  static PlayerModel? nonStriker;

  static PlayerModel? currentBowler;

  // =========================
  // RESET MATCH
  // =========================

  static void resetMatch(){

    totalRuns = 0;

    wickets = 0;

    over = 0;

    ball = 0;

    wides = 0;

    noBalls = 0;

    byes = 0;

    legByes = 0;

    firstInningsScore = 0;

    target = 0;

    resultText = "";

    isSecondInnings = false;

    isMatchEnded = false;

    outPlayers.clear();

    battingPlayers.clear();

    bowlingPlayers.clear();

    striker = null;

    nonStriker = null;

    currentBowler = null;
  }

  // =========================
  // RESET INNINGS
  // =========================

  static void resetInnings(){


    totalRuns = 0;

    wickets = 0;

    over = 0;

    ball = 0;

    wides = 0;

    noBalls = 0;

    byes = 0;

    legByes = 0;

    outPlayers.clear();

    striker = null;

    nonStriker = null;

    currentBowler = null;

    // RESET PLAYER STATS

    List<PlayerModel>
    allPlayers = [

      ...battingPlayers,

      ...bowlingPlayers,
    ];

    for(

    PlayerModel player
    in allPlayers

    ){

      player.runs = 0;

      player.balls = 0;

      player.runsGiven = 0;

      player.ballsBowled = 0;

      player.wickets = 0;
    }
  }
  static void resetPlayerStats(){

  List<PlayerModel>
  allPlayers = [

    ...battingPlayers,

    ...bowlingPlayers,
  ];

  for(

  PlayerModel player
  in allPlayers

  ){

    player.runs = 0;

    player.balls = 0;

    player.runsGiven = 0;

    player.ballsBowled = 0;

    player.wickets = 0;
  }
}

  // =========================
  // CURRENT RUN RATE
  // =========================

  static double getCurrentRunRate(){

    double oversPlayed =

        over + (ball / 6);

    if(oversPlayed == 0){

      return 0;
    }

    return totalRuns / oversPlayed;
  }

  // =========================
  // REQUIRED RUN RATE
  // =========================

  static double getRequiredRunRate(){

    if(!isSecondInnings){

      return 0;
    }

    int remainingRuns =

        target - totalRuns;

    int remainingBalls =

        (totalOvers * 6)

            -

            ((over * 6) + ball);

    if(remainingBalls <= 0){

      return 0;
    }

    double remainingOvers =

        remainingBalls / 6;

    return remainingRuns /
        remainingOvers;
  }

  // =========================
  // REMAINING BALLS
  // =========================

  static int getRemainingBalls(){

    return

        (totalOvers * 6)

            -

            ((over * 6) + ball);
  }

  // =========================
  // REMAINING RUNS
  // =========================

  static int getRemainingRuns(){

    return target - totalRuns;
  }

  // =========================
  // TOTAL EXTRAS
  // =========================

  static int getTotalExtras(){

    return

        wides +
            noBalls +
            byes +
            legByes;
  }

  // =========================
  // CHECK WINNER
  // =========================

  static void checkWinner(){

    // SECOND INNINGS ONLY

    if(!isSecondInnings){
      return;
    }

    // CHASE COMPLETE

    if(totalRuns >= target){

      int wicketsLeft =

          battingPlayers.length
              - wickets;

      resultText =

      "$teamBName won by "

          "$wicketsLeft wickets";

      isMatchEnded = true;

      return;
    }

    // OVERS COMPLETE

    bool oversFinished =

        over >= totalOvers;

    bool allOut =

        wickets >=
            battingPlayers.length;

    if(

    oversFinished ||
        allOut

    ){

      if(totalRuns == firstInningsScore){

        resultText =
        "Match Tied";

      }else{

        int runMargin =

            firstInningsScore
                - totalRuns;

        resultText =

        "$teamAName won by "

            "$runMargin runs";
      }

      isMatchEnded = true;
    }
  }
}