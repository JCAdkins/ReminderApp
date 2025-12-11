import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:table_calendar/table_calendar.dart';
import '../api/auth_service.dart';
import './open_screen.dart';
import '../widgets/blurred_panel.dart';
import '../widgets/neon_button.dart';
import '../widgets/swipeable_panel.dart';
import '../widgets/reminder_calendar.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = AuthService();
  final PageController _pageController = PageController(viewportFraction: 1.1);

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Your Reminders",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await auth.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => OpenScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("home_image.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 120),
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 0),
                          blurRadius: 10,
                          color: Colors.black54,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Here are your reminders for today.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Create Reminder Button
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child:
                        NeonButton(
                            label: "Create New Reminder",
                            icon: Icons.add,
                            onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                content: Text("Create Reminder tapped"),
                                ),
                            );
                            },
                        ),
                  ),
                  const SizedBox(height: 30),

                  // Swipeable panel
                    Expanded(
                    child: SwipeablePanel(
                        pages: [
                        BlurredPanel(
                            outerPadding: const EdgeInsets.all(12),
                            child: const Center(
                            child: Text(
                                "No reminders yet.\nTap the + button to add one!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                ),
                            ),
                            ),
                        ),

                        Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(20),
                            ),
                            child: ReminderCalendar(
                                focusedDay: _focusedDay,
                                selectedDay: _selectedDay,
                                onDaySelected: (selected, focused) {
                                    setState(() {
                                    _selectedDay = selected;
                                    _focusedDay = focused;
                                    });
                                },
                                ),

                            ),
                        ),
                        ],
                    ),
                    )

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
