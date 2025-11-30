import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bionic Race',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueAccent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const GameScreen(),
    const StoreScreen(),
    const CoinChargingScreen(),
    const LeaderboardScreen(),
    const SettingsScreen(),
    const FriendsScreen(),
    const AchievementsScreen(),
    const RedeemScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.gamepad),
            label: 'Game',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Coins',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Achievements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.redeem),
            label: 'Redeem',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// Game Screen
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double playerX = 0;
  double playerY = 1; // Bottom of the screen
  int score = 0;
  int coins = 0;
  bool gameRunning = false;
  List<Offset> obstacles = [];
  List<Offset> coinPositions = [];
  final Random _random = Random();
  late Timer _timer;

  void startGame() {
    setState(() {
      playerX = 0;
      playerY = 1;
      score = 0;
      coins = 0;
      gameRunning = true;
      obstacles.clear();
      coinPositions.clear();
    });

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!gameRunning) {
        timer.cancel();
        return;
      }

      setState(() {
        score++;

        // Move obstacles down
        for (int i = 0; i < obstacles.length; i++) {
          obstacles[i] = obstacles[i].translate(0, 0.02);
        }
        // Move coins down
        for (int i = 0; i < coinPositions.length; i++) {
          coinPositions[i] = coinPositions[i].translate(0, 0.02);
        }

        // Remove off-screen objects
        obstacles.removeWhere((o) => o.dy > 1.1);
        coinPositions.removeWhere((c) => c.dy > 1.1);

        // Add new objects
        if (_random.nextDouble() < 0.1) {
          obstacles.add(Offset(_random.nextDouble() * 2 - 1, -1));
        }
        if (_random.nextDouble() < 0.05) {
          coinPositions.add(Offset(_random.nextDouble() * 2 - 1, -1));
        }

        // Collision detection
        final playerRect = Rect.fromCenter(
            center: Offset(playerX, playerY - 0.1), width: 0.1, height: 0.1);

        for (final obstacle in obstacles) {
          final obstacleRect = Rect.fromCenter(
              center: Offset(obstacle.dx, obstacle.dy),
              width: 0.1,
              height: 0.1);
          if (playerRect.overlaps(obstacleRect)) {
            endGame();
            break;
          }
        }

        coinPositions.removeWhere((coin) {
          final coinRect = Rect.fromCenter(
              center: Offset(coin.dx, coin.dy), width: 0.1, height: 0.1);
          if (playerRect.overlaps(coinRect)) {
            coins++;
            return true;
          }
          return false;
        });
      });
    });
  }

  void endGame() {
    setState(() {
      gameRunning = false;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Your score: $score\nCoins collected: $coins'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              startGame();
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  void movePlayer(double dx) {
    if (!gameRunning) return;
    setState(() {
      playerX += dx;
      if (playerX > 1) playerX = 1;
      if (playerX < -1) playerX = -1;
    });
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bionic Race - Score: $score - Coins: $coins'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          movePlayer(details.delta.dx / (context.size!.width / 2));
        },
        child: Container(
          color: Colors.black,
          child: gameRunning
              ? Stack(
                  children: [
                    // Player
                    Align(
                      alignment: Alignment(playerX, playerY - 0.1),
                      child:
                          const Icon(Icons.directions_run, color: Colors.white, size: 50),
                    ),
                    // Obstacles
                    ...obstacles.map((pos) => Align(
                          alignment: Alignment(pos.dx, pos.dy),
                          child: const Icon(Icons.block, color: Colors.red, size: 40),
                        )),
                    // Coins
                    ...coinPositions.map((pos) => Align(
                          alignment: Alignment(pos.dx, pos.dy),
                          child: const Icon(Icons.monetization_on,
                              color: Colors.yellow, size: 30),
                        )),
                  ],
                )
              : Center(
                  child: ElevatedButton(
                    onPressed: startGame,
                    child: const Text('Start Game'),
                  ),
                ),
        ),
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => movePlayer(-0.1)),
            IconButton(icon: const Icon(Icons.arrow_upward), onPressed: () {}), // Jump logic can be added here
            IconButton(icon: const Icon(Icons.arrow_downward), onPressed: () {}), // Crouch logic
            IconButton(icon: const Icon(Icons.arrow_forward), onPressed: () => movePlayer(0.1)),
          ],
        )
      ],
    );
  }
}

// Store Screen
class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        children: List.generate(20, (index) {
          return Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield, size: 50, color: Colors.primaries[index % Colors.primaries.length]),
                const SizedBox(height: 10),
                Text('Item ${index + 1}'),
                Text('${(index + 1) * 100} Coins'),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Purchase Successful (Mock)')),
                    );
                  },
                  child: const Text('Buy'),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// Coin Charging Screen
class CoinChargingScreen extends StatelessWidget {
  const CoinChargingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buy Coins')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildCoinPackage(context, '1,000 Coins', '\$0.99'),
          _buildCoinPackage(context, '5,500 Coins', '\$4.99'),
          _buildCoinPackage(context, '12,000 Coins', '\$9.99'),
          _buildCoinPackage(context, '30,000 Coins', '\$19.99'),
          _buildCoinPackage(context, '80,000 Coins', '\$49.99'),
          _buildCoinPackage(context, '200,000 Coins', '\$99.99'),
        ],
      ),
    );
  }

  Widget _buildCoinPackage(BuildContext context, String title, String price) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.monetization_on, color: Colors.yellow, size: 40),
        title: Text(title),
        subtitle: Text(price),
        trailing: ElevatedButton(
          onPressed: () {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Real payment not implemented. This is a mock purchase for $title.')),
            );
          },
          child: const Text('Buy'),
        ),
      ),
    );
  }
}

// Leaderboard Screen
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Global Leaderboard')),
      body: ListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Text('#${index + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              title: Text('Player_${(50 - index) * 12345}'),
              trailing: Text('${(50 - index) * 10000}'),
            ),
          );
        },
      ),
    );
  }
}

// Settings Screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEffects = true;
  bool _music = true;
  double _volume = 0.5;
  String _theme = 'Dark';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Sound Effects'),
            value: _soundEffects,
            onChanged: (bool value) {
              setState(() {
                _soundEffects = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Music'),
            value: _music,
            onChanged: (bool value) {
              setState(() {
                _music = value;
              });
            },
          ),
          ListTile(
            title: const Text('Volume'),
            subtitle: Slider(
              value: _volume,
              onChanged: (newVolume) {
                setState(() {
                  _volume = newVolume;
                });
              },
            ),
          ),
           DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Theme'),
            value: _theme,
            items: <String>['Dark', 'Light', 'Desert', 'Snow']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _theme = newValue!;
              });
            },
          ),
        ],
      ),
    );
  }
}

// Friends Screen
class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Friends List'),
                Tab(text: 'Friend Requests'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView.builder(
                    itemCount: 15,
                    itemBuilder: (context, index) => ListTile(
                      leading: const Icon(Icons.person),
                      title: Text('Friend ${index + 1}'),
                      subtitle: const Text('Online'),
                      trailing: IconButton(icon: const Icon(Icons.chat), onPressed: () {}),
                    ),
                  ),
                   ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) => ListTile(
                      leading: const Icon(Icons.person_add),
                      title: Text('Player ${index + 50}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () {}),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Achievements Screen
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: ListView(
        children: const [
          AchievementTile(title: 'First Run', description: 'Complete your first game.', progress: 1.0),
          AchievementTile(title: 'Coin Collector', description: 'Collect 1,000 coins.', progress: 0.35),
          AchievementTile(title: 'Marathoner', description: 'Reach a score of 50,000.', progress: 0.8),
          AchievementTile(title: 'Obstacle Dodger', description: 'Dodge 500 obstacles.', progress: 0.6),
          AchievementTile(title: 'Shopaholic', description: 'Buy 10 items from the store.', progress: 0.1),
        ],
      ),
    );
  }
}

class AchievementTile extends StatelessWidget {
  final String title;
  final String description;
  final double progress;

  const AchievementTile({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  progress == 1.0 ? Icons.check_circle : Icons.star_border,
                  color: progress == 1.0 ? Colors.green : Colors.amber,
                ),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 5),
            Text(description),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[700],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text('${(progress * 100).toInt()}%'),
            )
          ],
        ),
      ),
    );
  }
}


// Redeem Screen
class RedeemScreen extends StatelessWidget {
  const RedeemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Redeem Coins')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'You can redeem your in-game coins here. This is a simulation and does not involve real money.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Amount of Coins to Redeem',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'PayPal Email (Mock)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Request Sent'),
                    content: const Text('Your redemption request has been sent! Payment will be processed within 24 hours (simulation).'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}
