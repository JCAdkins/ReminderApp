import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DOBField extends StatefulWidget {
  final TextEditingController controller;
  const DOBField({super.key, required this.controller});

  @override
  _DOBFieldState createState() => _DOBFieldState();
}

class _DOBFieldState extends State<DOBField> {
  int _selectedDay = 1;
  int _selectedMonth = 1;
  int _selectedYear = 2000;

  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _yearController;

  static const int _virtualItemCount = 10000;

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
    final currentYear = DateTime.now().year;
    final totalYears = currentYear - 1900 + 1;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(16),
          width: MediaQuery.of(context).size.width * 0.8,
          height: 180,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Month picker
                    Expanded(
                      child: CupertinoPicker.builder(
                        scrollController: _monthController,
                        itemExtent: 32,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedMonth = (index % 12) + 1;
                          });
                        },
                        childCount: _virtualItemCount,
                        itemBuilder: (context, index) {
                          final month = (index % 12) + 1;
                          return Center(child: Text(month.toString()));
                        },
                      ),
                    ),
                    // Day picker
                    Expanded(
                      child: CupertinoPicker.builder(
                        scrollController: _dayController,
                        itemExtent: 32,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedDay = (index % 31) + 1;
                          });
                        },
                        childCount: _virtualItemCount,
                        itemBuilder: (context, index) {
                          final day = (index % 31) + 1;
                          return Center(child: Text(day.toString()));
                        },
                      ),
                    ),
                    // Year picker
                    Expanded(
                      child: CupertinoPicker.builder(
                        scrollController: _yearController,
                        itemExtent: 32,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedYear = 1900 + (index % totalYears);
                          });
                        },
                        childCount: _virtualItemCount,
                        itemBuilder: (context, index) {
                          final year = 1900 + (index % totalYears);
                          return Center(child: Text(year.toString()));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  widget.controller.text =
                      "${_selectedYear.toString().padLeft(4, '0')}-${_selectedMonth.toString().padLeft(2, '0')}-${_selectedDay.toString().padLeft(2, '0')}";
                  Navigator.pop(context);
                },
                child: const Text("Done"),
              )
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
