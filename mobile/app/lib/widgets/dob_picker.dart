import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DOBPicker extends StatefulWidget {
  final DateTime initialDate;
  final void Function(DateTime) onDateChanged;

  const DOBPicker({
    super.key,
    required this.initialDate,
    required this.onDateChanged,
  });

  @override
  State<DOBPicker> createState() => _DOBPickerState();
}

class _DOBPickerState extends State<DOBPicker> {
  late int selectedMonth;
  late int selectedDay;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initialDate.month;
    selectedDay = widget.initialDate.day;
    selectedYear = widget.initialDate.year;
  }

  @override
  Widget build(BuildContext context) {
    final years = List.generate(
      DateTime.now().year - 1900 + 1,
      (i) => 1900 + i,
    );

    final daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
    final days = List.generate(daysInMonth, (i) => i + 1);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 200,
                child: Row(
                  children: [
                    // Month Picker
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedMonth - 1,
                        ),
                        itemExtent: 32,
                        onSelectedItemChanged: (index) {
                          setState(() => selectedMonth = index + 1);
                        },
                        children: List.generate(
                          12,
                          (i) => Center(
                            child: Text(
                              "${i + 1}",
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Day Picker
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedDay - 1,
                        ),
                        itemExtent: 32,
                        onSelectedItemChanged: (index) {
                          setState(() => selectedDay = index + 1);
                        },
                        children: days
                            .map((d) => Center(
                                  child: Text(
                                    "$d",
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    // Year Picker
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: years.indexOf(selectedYear),
                        ),
                        itemExtent: 32,
                        onSelectedItemChanged: (index) {
                          setState(() => selectedYear = years[index]);
                        },
                        children: years
                            .map((y) => Center(
                                  child: Text(
                                    "$y",
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final pickedDate =
                      DateTime(selectedYear, selectedMonth, selectedDay);
                  widget.onDateChanged(pickedDate);
                  Navigator.of(context).pop();
                },
                child: const Text("Done"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
