import 'package:flutter/material.dart';
import 'live_score_screen.dart';

class StartMatchScreen extends StatefulWidget {
  const StartMatchScreen({super.key});

  @override
  State<StartMatchScreen> createState() => _StartMatchScreenState();
}

class _StartMatchScreenState extends State<StartMatchScreen> {
  final TextEditingController teamAController = TextEditingController();
  final TextEditingController teamBController = TextEditingController();
  final TextEditingController oversController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Start Match")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: teamAController,

              decoration: InputDecoration(
                hintText: "Enter Team A Name",

                filled: true,
                fillColor: const Color(0xff1E293B),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: teamBController,

              decoration: InputDecoration(
                hintText: "Enter Team B Name",

                filled: true,
                fillColor: const Color(0xff1E293B),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: oversController,
              keyboardType: TextInputType.number,

              decoration: InputDecoration(
                hintText: "Enter Overs",

                filled: true,
                fillColor: const Color(0xff1E293B),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 65,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                onPressed: () {
                  if (teamAController.text.isEmpty ||
                      teamBController.text.isEmpty ||
                      oversController.text.isEmpty) {
                    return;
                  }

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (context) => const LiveScoreScreen(),
                    ),
                  );
                  (const SnackBar(content: Text("Match Started")),);
                },

                child: const Text(
                  "Start Match",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
