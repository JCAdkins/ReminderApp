import 'package:flutter/cupertino.dart';

class DOBPicker extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime>? onConfirm;

  const DOBPicker({
    super.key,
    required this.initialDate,
    required this.onConfirm,
  });

  @override
  State<DOBPicker> createState() => _DOBPickerState();
}

class _DOBPickerState extends State<DOBPicker> {
  late int _year;
  late int _month;
  late int _day;

  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;

  static const int _minYear = 1900;
  static const int _maxYear = 2100;

  @override
  void initState() {
    super.initState();

    _year = widget.initialDate.year;
    _month = widget.initialDate.month;
    _day = widget.initialDate.day;

    _yearController =
        FixedExtentScrollController(initialItem: _year - _minYear);
    _monthController = FixedExtentScrollController(initialItem: _month - 1);
    _dayController = FixedExtentScrollController(initialItem: _day - 1);
  }

  int _daysInMonth(int year, int month) {
    if (month == 2) {
      final isLeap = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeap ? 29 : 28;
    }

    const daysPerMonth = [31, 0, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysPerMonth[month - 1];
  }

  void _clampDayIfNeeded() {
    final maxDay = _daysInMonth(_year, _month);

    if (_day > maxDay) {
      setState(() => _day = maxDay);
      _dayController.jumpToItem(maxDay - 1);
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Action bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoButton(
                child: const Text('Done'),
                onPressed: () {
                  widget.onConfirm!(DateTime(_year, _month, _day));
                },
              ),
            ],
          ),

          SizedBox(
            height: 125,
            child: Row(
              children: [
                // Month
                Expanded(
                  child: CupertinoPicker(
                    scrollController: _monthController,
                    itemExtent: 32,
                    onSelectedItemChanged: (index) {
                      setState(() => _month = index + 1);
                      _clampDayIfNeeded();
                    },
                    children: List.generate(
                      12,
                      (i) => Center(child: Text('${i + 1}')),
                    ),
                  ),
                ),

                // Day (dynamic)
                Expanded(
                  child: CupertinoPicker(
                    scrollController: _dayController,
                    itemExtent: 32,
                    onSelectedItemChanged: (index) {
                      setState(() => _day = index + 1);
                    },
                    children: List.generate(
                      _daysInMonth(_year, _month),
                      (i) => Center(child: Text('${i + 1}')),
                    ),
                  ),
                ),

                // Year
                Expanded(
                  child: CupertinoPicker(
                    scrollController: _yearController,
                    itemExtent: 32,
                    onSelectedItemChanged: (index) {
                      setState(() => _year = _minYear + index);
                      _clampDayIfNeeded();
                    },
                    children: List.generate(
                      _maxYear - _minYear + 1,
                      (i) => Center(child: Text('${_minYear + i}')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
