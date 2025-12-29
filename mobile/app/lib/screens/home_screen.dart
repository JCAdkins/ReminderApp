import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../api/auth/auth_service.dart';
import '../api/models/reminder.dart';
import '../store/reminder_store.dart';
import '../widgets/reminder_list_tile.dart';
import '../widgets/sheets/reminder_details_sheet.dart';
import '../widgets/sheets/reminder_list_sheet.dart';
import './open_screen.dart';
import '../widgets/blurred_panel.dart';
import '../widgets/buttons/neon_button.dart';
import '../widgets/swipeable_panel.dart';
import '../widgets/reminder_calendar.dart';
import '../widgets/sheets/create_reminder_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 1.1);
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openCreateReminderSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateReminderSheet(),
    );
  }

  void _openReminderDetails(Reminder reminder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReminderDetailsSheet(reminder: reminder),
    );
  }

  void _openReminderListSheet(List<Reminder> reminders) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReminderListSheet(
        reminders: reminders,
        onReminderTap: (reminder) {
          Navigator.pop(context); // close list
          _openReminderDetails(reminder); // open details
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return GestureDetector(
      behavior:
          HitTestBehavior.opaque, // ensures taps on empty space are detected
      onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard
      child: Scaffold(
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
                if (!context.mounted) return;
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
                  image: AssetImage("assets/home_image.png"),
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
                      child: NeonButton(
                        label: "Create New Reminder",
                        icon: Icons.add,
                        onTap: _openCreateReminderSheet,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Swipeable panel
                    Expanded(
                      child: SwipeablePanel(
                        pages: [
                          BlurredPanel(
                            outerPadding: const EdgeInsets.all(12),
                            child: Consumer<ReminderStore>(
                              builder: (_, store, __) {
                                if (store.reminders.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      "No reminders yet.\nTap the + button to add one!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  itemCount: store.reminders.length,
                                  itemBuilder: (_, i) {
                                    final r = store.reminders[i];
                                    return ReminderListTile(
                                      reminder: r,
                                      onTap: () => _openReminderDetails(r),
                                    );
                                  },
                                );
                              },
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
                              child: Consumer<ReminderStore>(
                                builder: (_, store, __) {
                                  return ReminderCalendar(
                                    reminders: store.reminders,
                                    focusedDay: _focusedDay,
                                    selectedDay: _selectedDay,
                                    onDaySelected: (selected, focused) {
                                      setState(() {
                                        _selectedDay = selected;
                                        _focusedDay = focused;
                                      });

                                      final dayReminders = store.reminders
                                          .where(
                                            (r) =>
                                                isSameDay(r.startAt, selected),
                                          )
                                          .toList();

                                      if (dayReminders.isNotEmpty) {
                                        _openReminderListSheet(dayReminders);
                                      }
                                    },
                                  );
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
      ),
    );
  }
}
