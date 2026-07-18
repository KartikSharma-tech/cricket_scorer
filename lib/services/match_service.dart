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

  static int firstInningsWickets = 0;

  static int target = 0;

  // =========================
  // RESULT
  // =========================

  static String resultText = "";
  // =========================
  // BALL HISTORY
  // =========================

  static List<BallModel> ballHistory = [];

  // BALLS BOWLED IN THE CURRENT OVER (reset every over, used for UI only)

  static List<BallModel> thisOverBalls = [];

  // =========================
  // PLAYERS
  // =========================

  static List<PlayerModel> battingPlayers = [];

  static List<PlayerModel> bowlingPlayers = [];

  static List<PlayerModel> outPlayers = [];

  static PlayerModel? striker;

  static PlayerModel? nonStriker;

  static PlayerModel? currentBowler;

  // BOWLER WHO BOWLED THE PREVIOUS OVER (cannot bowl consecutive overs)

  static PlayerModel? previousBowler;

  // LAST MAN BATTING RULE (team continues with solo batsman on final wicket)

  static bool lastManBatting = true;

  // =========================
  // RESET MATCH
  // =========================

  static void resetMatch() {
    totalRuns = 0;

    wickets = 0;

    over = 0;

    ball = 0;

    wides = 0;

    noBalls = 0;

    byes = 0;

    legByes = 0;

    firstInningsScore = 0;

    firstInningsWickets = 0;

    target = 0;

    resultText = "";

    isSecondInnings = false;

    isMatchEnded = false;

    outPlayers = [];
    battingPlayers = [];
    bowlingPlayers = [];

    striker = null;
    nonStriker = null;
    currentBowler = null;

    previousBowler = null;

    ballHistory = [];

    thisOverBalls = [];
  }

  // =========================
  // RESET INNINGS
  // =========================

  static void resetInnings() {
    ballHistory = [];

    thisOverBalls = [];

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

    previousBowler = null;

    // RESET PLAYER STATS

    List<PlayerModel> allPlayers = [...battingPlayers, ...bowlingPlayers];

    for (PlayerModel player in allPlayers) {
      player.runs = 0;

      player.balls = 0;

      player.runsGiven = 0;

      player.ballsBowled = 0;

      player.wickets = 0;
    }
  }

  // =========================
  // START SECOND INNINGS
  // =========================
  // Swaps batting/bowling teams, locks in the target,
  // and resets all live-innings state for the chase.

  static void startSecondInnings() {
    firstInningsScore = totalRuns;

    firstInningsWickets = wickets;

    target = totalRuns + 1;

    isSecondInnings = true;

    final List<PlayerModel> temp = battingPlayers;

    battingPlayers = bowlingPlayers;

    bowlingPlayers = temp;

    resetInnings();
  }

  // =========================
  // RECORD A LEGAL BALL
  // =========================
  // Call this for every ball that counts toward the over
  // (normal balls, byes, leg byes, wickets — NOT wides/no-balls).
  // Returns true if the over just completed.

  static bool recordLegalBall() {
    ball++;

    if (currentBowler != null) {
      currentBowler!.ballsBowled++;
    }

    if (ball >= 6) {
      over++;

      ball = 0;

      previousBowler = currentBowler;

      currentBowler = null;

      thisOverBalls = [];

      return true;
    }

    return false;
  }

  // =========================
  // LAST MAN STANDING
  // =========================

  static bool get isLastManStanding {
    return lastManBatting && (battingPlayers.length - wickets) == 1;
  }

  static void resetPlayerStats() {
    List<PlayerModel> allPlayers = [...battingPlayers, ...bowlingPlayers];

    for (PlayerModel player in allPlayers) {
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

  static double getCurrentRunRate() {
    double oversPlayed = over + (ball / 6);

    if (oversPlayed == 0) {
      return 0;
    }

    return totalRuns / oversPlayed;
  }

  // =========================
  // REQUIRED RUN RATE
  // =========================

  static double getRequiredRunRate() {
    if (!isSecondInnings) {
      return 0;
    }

    int remainingRuns = target - totalRuns;

    int remainingBalls = (totalOvers * 6) - ((over * 6) + ball);

    if (remainingBalls <= 0) {
      return 0;
    }

    double remainingOvers = remainingBalls / 6;

    return remainingRuns / remainingOvers;
  }

  // =========================
  // REMAINING BALLS
  // =========================

  static int getRemainingBalls() {
    return (totalOvers * 6) - ((over * 6) + ball);
  }

  // =========================
  // REMAINING RUNS
  // =========================

  static int getRemainingRuns() {
    return (target - totalRuns).clamp(0, 999999);
  }

  // =========================
  // TOTAL EXTRAS
  // =========================

  static int getTotalExtras() {
    return wides + noBalls + byes + legByes;
  }

  // =========================
  // CHECK WINNER
  // =========================
  // =========================
  // MATCH HELPERS
  // =========================

  static bool get oversCompleted {
    return over >= totalOvers;
  }

  static bool get allOut {
    return wickets >= battingPlayers.length;
  }

  static bool get inningsCompleted {
    return oversCompleted || allOut;
  }

  static int get wicketsRemaining {
    int remaining = battingPlayers.length - wickets;
    return remaining < 0 ? 0 : remaining;
  }

  static bool get targetAchieved {
    if (!isSecondInnings) {
      return false;
    }

    return totalRuns >= target;
  }

  static void checkWinner() {
    // SECOND INNINGS ONLY

    if (!isSecondInnings) {
      return;
    }

    // CHASE COMPLETE

    if (totalRuns >= target) {
      int wicketsLeft = wicketsRemaining;

      resultText =
          "$teamBName won by "
          "$wicketsLeft wickets";

      isMatchEnded = true;

      return;
    }

    // OVERS COMPLETE

    bool oversFinished = oversCompleted;

    bool teamAllOut = allOut;

    if (oversFinished || teamAllOut) {
      if (totalRuns == firstInningsScore) {
        resultText = "Match Tied";
      } else {
        int runMargin = firstInningsScore - totalRuns;

        resultText =
            "$teamAName won by "
            "$runMargin runs";
      }

      isMatchEnded = true;
    }
  }
}
