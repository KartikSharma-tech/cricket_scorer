// ```dart id="bzy0g4"
import 'package:flutter/material.dart';

import '../services/match_storage_service.dart';

import 'add_player_screen.dart';
import 'live_score_screen.dart';
import 'match_history_screen.dart';
import 'start_match_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  // =========================
  // INDEX
  // =========================

  int currentIndex = 0;

  bool hasLiveMatch = false;

  bool isLoading = true;

  // =========================
  // INIT
  // =========================

  @override
  void initState() {
    super.initState();

    checkLiveMatch();
  }

  // =========================
  // CHECK MATCH
  // =========================

  Future<void> checkLiveMatch() async {
    bool matchExists = await MatchStorageService.hasSavedMatch();

    setState(() {
      hasLiveMatch = matchExists;

      isLoading = false;
    });
  }

  // =========================
  // PAGES
  // =========================

  List<Widget> get pages => [
    homePage(),

    const AddPlayerScreen(),

    const MatchHistoryScreen(),
  ];

  // =========================
  // HOME PAGE
  // =========================

  Widget homePage() {
    return Padding(
      padding: const EdgeInsets.all(20),

      child: Column(
        children: [
          const SizedBox(height: 20),

          // RESUME MATCH
          if (hasLiveMatch)
            homeButton(
              title: "Resume Match",

              icon: Icons.play_circle,

              color: Colors.orange,

              onTap: () async {
                await MatchStorageService.loadMatch();

                if (context.mounted) {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (context) {
                        return const LiveScoreScreen();
                      },
                    ),
                  ).then((value) {
                    checkLiveMatch();
                  });
                }
              },
            ),

          if (hasLiveMatch) const SizedBox(height: 20),

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
                    return const StartMatchScreen();
                  },
                ),
              ).then((value) {
                checkLiveMatch();
              });
            },
          ),

          const Spacer(),

          const Icon(Icons.sports_cricket, size: 90, color: Colors.green),

          const SizedBox(height: 20),

          const Text(
            "Cricket Scorer App",

            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(
            hasLiveMatch ? "Live Match Available" : "No Active Match",

            style: TextStyle(
              fontSize: 18,

              color: hasLiveMatch ? Colors.orange : Colors.grey,
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // =========================
  // BUTTON
  // =========================

  Widget homeButton({
    required String title,

    required IconData icon,

    required Color color,

    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,

      height: 75,

      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        onPressed: onTap,

        icon: Icon(icon, color: Colors.white),

        label: Text(
          title,

          style: const TextStyle(
            fontSize: 20,

            color: Colors.white,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cricket Scorer"), centerTitle: true),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        selectedItemColor: Colors.green,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),

          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Players"),

          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
      ),
    );
  }
}
