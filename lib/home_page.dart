import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Random random = Random();
  int currentImageIndex = 0;
  int counter = 1;
  int currentPlayer = 1;
  int round = 1;
  List<String> images = [
    'assets/images/dice_1.png',
    'assets/images/dice_2.png',
    'assets/images/dice_3.png',
    'assets/images/dice_4.png',
    'assets/images/dice_5.png',
    'assets/images/dice_6.png',
  ];
  AudioPlayer player = AudioPlayer();
  Map<int, List<int>> playerRolls = {1: [], 2: []};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '| ROLL THE DICE |',
          style: TextStyle(fontFamily: 'MyHeadlineFont', fontSize: 40),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 239, 236, 206),
              Color.fromARGB(255, 232, 226, 166),
              const Color.fromARGB(255, 77, 70, 10)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPlayerInfo(1),
                  _buildPlayerInfo(2),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Round $round',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 207, 48, 48),
                    fontFamily: 'MyHeadlineFont'),
              ),
              const SizedBox(height: 40),
              Transform.rotate(
                angle: random.nextDouble() * 180,
                child: Image.asset(
                  images[currentImageIndex],
                  height: 100,
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () async {
                  await player.setAsset('assets/audios/rolling-dice.mp3');
                  player.play();

                  Timer.periodic(const Duration(milliseconds: 80), (timer) {
                    counter++;
                    setState(() {
                      currentImageIndex = random.nextInt(6);
                    });

                    if (counter >= 13) {
                      timer.cancel();

                      setState(() {
                        counter = 1;
                        round++;
                        playerRolls[currentPlayer]!.add(currentImageIndex + 1);

                        if (round > 5) {
                          round = 1;
                          currentPlayer = 3 - currentPlayer;
                          if (currentPlayer == 1) {
                            displayWinner();
                          }
                        }
                      });
                    }
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Roll',
                    style: TextStyle(fontSize: 50, fontFamily: 'MyFont'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  resetGame();
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Reset',
                    style: TextStyle(fontSize: 20, fontFamily: 'MyFont'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(int player) {
    int totalValue = calculateTotalValueForPlayer(player);
    List<Widget> rounds = [];
    for (int i = 1; i <= 5; i++) {
      rounds.add(
        Text(
          'Round $i: ${playerRolls[player]!.length >= i ? playerRolls[player]![i - 1] : "-"}',
          style: TextStyle(
              fontFamily: 'MyFont',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(238, 101, 16, 1)),
        ),
      );
    }
    return Column(
      children: [
        Text(
          'Player $player',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'Total: $totalValue',
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
        ),
        ...rounds,
      ],
    );
  }

  void displayWinner() {
    int player1Total = calculateTotalValueForPlayer(1);
    int player2Total = calculateTotalValueForPlayer(2);

    String winnerMessage =
        'Player ${player1Total > player2Total ? 1 : 2} wins!';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Game Over'),
        content: Text(winnerMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resetGame();
            },
            child: Text('Play Again'),
          ),
        ],
      ),
    );
  }

  int calculateTotalValueForPlayer(int player) {
    return playerRolls[player]!
        .fold(0, (previousValue, element) => previousValue + element);
  }

  void resetGame() {
    setState(() {
      round = 1;
      currentPlayer = 1;
      playerRolls = {1: [], 2: []};
    });
  }
}
