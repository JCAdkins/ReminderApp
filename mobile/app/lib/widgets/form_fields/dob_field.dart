import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DOBField extends StatefulWidget {
  final TextEditingController controller;
  const DOBField({super.key, required this.controller});

  @override
  DOBFieldState createState() => DOBFieldState();
}

class DOBFieldState extends State<DOBField> {
  int _selectedDay = 1;
  int _selectedMonth = 1;
  int _selectedYear = 2000;

  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _yearController;

  static const int _virtualItemCount = 10000;

  int _daysInMonth(int month, int year) {
    // February
    if (month == 2) {
      final isLeapYear =
          (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }

    // April, June, September, November
    const monthsWith30Days = [4, 6, 9, 11];
    if (monthsWith30Days.contains(month)) {
      return 30;
    }

    // All others
    return 31;
  }

  void _snapDayIfNeeded() {
    final maxDay = _daysInMonth(_selectedMonth, _selectedYear);

    if (_selectedDay > maxDay) {
      _selectedDay = maxDay;

      // Snap the wheel visually
      final baseIndex =
          _dayController.selectedItem - (_dayController.selectedItem % 31);
      _dayController.animateToItem(
        baseIndex + (maxDay - 1),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Parse controller text if available
    if (widget.controller.text.isNotEmpty) {
      try {
        final date = DateTime.parse(widget.controller.text);
        _selectedDay = date.day;
        _selectedMonth = date.month;
        _selectedYear = date.year;
      } catch (_) {}
    }

    // Center the initial index to the middle of the virtual list
    _monthController = FixedExtentScrollController(
        initialItem: (_virtualItemCount ~/ 2) -
            (_virtualItemCount ~/ 2) % 12 +
            (_selectedMonth - 1));
    _dayController = FixedExtentScrollController(
        initialItem: (_virtualItemCount ~/ 2) -
            (_virtualItemCount ~/ 2) % 31 +
            (_selectedDay - 1));
    _yearController = FixedExtentScrollController(
        initialItem: (_virtualItemCount ~/ 2) -
            (_virtualItemCount ~/ 2) % (DateTime.now().year - 1900 + 1) +
            (_selectedYear - 1900));
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _openDOBPicker() {
    final now = DateTime.now();
    final currentYear = now.year;
    final totalYears = currentYear - 1900 + 1;

    // STEP 1: Re-read the controller text
    if (widget.controller.text.isNotEmpty) {
      try {
        final parts = widget.controller.text.split('-'); // MM-DD-YYYY format
        if (parts.length == 3) {
          _selectedMonth = int.parse(parts[0]);
          _selectedDay = int.parse(parts[1]);
          _selectedYear = int.parse(parts[2]);
        }
      } catch (_) {}
    }

    // STEP 2: Recreate scroll controllers using updated values
    _monthController = FixedExtentScrollController(
      initialItem: (_virtualItemCount ~/ 2) -
          (_virtualItemCount ~/ 2) % 12 +
          (_selectedMonth - 1),
    );

    _dayController = FixedExtentScrollController(
      initialItem: (_virtualItemCount ~/ 2) -
          (_virtualItemCount ~/ 2) % 31 +
          (_selectedDay - 1),
    );

    _yearController = FixedExtentScrollController(
      initialItem: (_virtualItemCount ~/ 2) -
          (_virtualItemCount ~/ 2) % totalYears +
          (_selectedYear - 1900),
    );

    // STEP 3: Show dialog
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(16),
          width: MediaQuery.of(context).size.width * 0.8,
          height: 180,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker.builder(
                        scrollController: _monthController,
                        itemExtent: 32,
                        childCount: _virtualItemCount,
                        onSelectedItemChanged: (i) {
                          _selectedMonth = (i % 12) + 1;
                          _snapDayIfNeeded();
                        },
                        itemBuilder: (_, i) =>
                            Center(child: Text("${(i % 12) + 1}")),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker.builder(
                        scrollController: _dayController,
                        itemExtent: 32,
                        childCount: _virtualItemCount,
                        onSelectedItemChanged: (index) {
                          final day = (index % 31) + 1;
                          final maxDay =
                              _daysInMonth(_selectedMonth, _selectedYear);

                          if (day <= maxDay) {
                            setState(() {
                              _selectedDay = day;
                            });
                          } else {
                            // Snap back to last valid day
                            final safeIndex = (_virtualItemCount ~/ 2) -
                                (_virtualItemCount ~/ 2) % 31 +
                                (maxDay - 1);

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _dayController.animateToItem(
                                safeIndex,
                                duration: const Duration(milliseconds: 150),
                                curve: Curves.easeOut,
                              );
                            });
                          }
                        },
                        itemBuilder: (context, index) {
                          final day = (index % 31) + 1;
                          final maxDay =
                              _daysInMonth(_selectedMonth, _selectedYear);
                          final isValid = day <= maxDay;

                          return Center(
                            child: Text(
                              day.toString(),
                              style: TextStyle(
                                color: isValid
                                    ? Colors.black
                                    : Colors.grey.withValues(alpha: 0.4),
                                fontWeight: isValid
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker.builder(
                        scrollController: _yearController,
                        itemExtent: 32,
                        childCount: _virtualItemCount,
                        onSelectedItemChanged: (i) {
                          _selectedYear = 1900 + (i % totalYears);
                          _snapDayIfNeeded();
                        },
                        itemBuilder: (_, i) =>
                            Center(child: Text("${1900 + (i % totalYears)}")),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  widget.controller.text =
                      "${_selectedMonth.toString().padLeft(2, '0')}-"
                      "${_selectedDay.toString().padLeft(2, '0')}-"
                      "${_selectedYear.toString()}";
                  Navigator.pop(context);
                },
                child: const Text("Done"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: const InputDecoration(
        labelText: "Date of Birth",
        border: UnderlineInputBorder(),
      ),
      readOnly: true,
      onTap: _openDOBPicker,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please select your date of birth";
        }
        return null;
      },
    );
  }
}
