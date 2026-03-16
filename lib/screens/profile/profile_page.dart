import 'package:flutter/material.dart';
import '../../utils/workout_stats.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.black,
      ),

      body: Column(
        children: [

          const SizedBox(height: 30),

          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 40),
          ),

          const SizedBox(height: 15),

          const Text(
            "User",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              Column(
                children: [
                  Text(
                    "${WorkoutStats.totalWorkouts()}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Total Workouts",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const Column(
                children: [
                  Text(
                    "120",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Text("Followers", style: TextStyle(color: Colors.grey)),
                ],
              ),

              const Column(
                children: [
                  Text(
                    "80",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Text("Following", style: TextStyle(color: Colors.grey)),
                ],
              ),

            ],
          ),

        ],
      ),
    );
  }
}