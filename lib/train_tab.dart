import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attention Training',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const AttentionTrainingCenterScreen(),
    );
  }
}

class AttentionTrainingCenterScreen extends StatelessWidget {
  const AttentionTrainingCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attention Training Center"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Baseline Test Card ===
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.teal[50],
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.fingerprint,
                      size: 64,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Attention Baseline Test",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Start your daily 90-second focus fingerprint",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Placeholder action — later you can start the real test
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Starting baseline test...")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Begin Baseline",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // === Micro-Task Library Title ===
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                "Micro-Task Library",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // === Task Items ===
            _buildMicroTaskCard(
              icon: Icons.remove_red_eye_outlined,
              color: Colors.blue,
              title: "Visual Spot-the-Change",
              duration: "1.5 min",
              adaptive: true,
            ),

            const SizedBox(height: 12),

            _buildMicroTaskCard(
              icon: Icons.grid_view_outlined,
              color: Colors.purple,
              title: "Logic Puzzle",
              duration: "2 min",
              adaptive: true,
            ),

            const SizedBox(height: 12),

            _buildMicroTaskCard(
              icon: Icons.speed_outlined,
              color: Colors.orange,
              title: "Speed Reading",
              duration: "1 min",
              adaptive: true,
              extra: "• Reco-Focus",
            ),

            const SizedBox(height: 12),

            _buildMicroTaskCard(
              icon: Icons.memory_outlined,
              color: Colors.red,
              title: "Memory Burst",
              duration: "1.5 min",
              adaptive: true,
            ),

            const SizedBox(height: 32),

            const Center(
              child: Text(
                "More exercises coming soon...",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicroTaskCard({
    required IconData icon,
    required Color color,
    required String title,
    required String duration,
    required bool adaptive,
    String extra = "",
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color, size: 32),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          "$duration ${adaptive ? "• Adaptive" : ""} $extra",
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        onTap: () {
          // Later: open the specific exercise
        },
      ),
    );
  }
}