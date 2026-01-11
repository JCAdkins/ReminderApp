import 'package:flutter/material.dart';
import 'package:mobile_app/api/notification/notification_service.dart';
import 'package:mobile_app/api/reminder/reminder_service.dart';
import 'package:provider/provider.dart';

import '../api/auth/auth_service.dart';
import '../api/models/reminder.dart';
import '../store/reminder_store.dart';
import '../widgets/reminder_list_tile.dart';
import '../widgets/sheets/edit_reminder_sheet.dart';
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
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadReminders() async {
    // Delay ensures context is fully available
    await Future.delayed(Duration.zero);

    if (!mounted || _loaded) return;
    _loaded = true;

    final reminderStore = Provider.of<ReminderStore>(context, listen: false);
    final reminderService =
        Provider.of<ReminderService>(context, listen: false);

    try {
      final reminders = await reminderService.fetchReminders();
      reminderStore.setReminders(reminders);
    } catch (e) {
      debugPrint('Failed to load reminders: $e');
    }
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

  void _openEditReminderSheet(Reminder reminder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditReminderSheet(reminder: reminder),
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
        onReminderEdit: (reminder) {
          Navigator.pop(context); // close list
          _openEditReminderSheet(reminder); // open edit sheet
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
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
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: NeonButton(
                        label: "Create New Reminder",
                        icon: Icons.add,
                        onTap: _openCreateReminderSheet,
                      ),
                    ),
                    const SizedBox(height: 10),
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
                                  itemCount:
                                      store.getUpcomingReminders().length,
                                  itemBuilder: (_, i) {
                                    final r = store.getUpcomingReminders()[i];
                                    return ReminderListTile(
                                      reminder: r,
                                      onTap: () => _openReminderDetails(r),
                                      onEdit: () => _openEditReminderSheet(r),
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
                                            (r) => isSameDay(
                                                r.startAt.toLocal(), selected),
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

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
