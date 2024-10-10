import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DisponibilitesPage extends StatefulWidget {
  const DisponibilitesPage({Key? key}) : super(key: key);

  @override
  State<DisponibilitesPage> createState() => _DisponibilitesPageState();
}

class _DisponibilitesPageState extends State<DisponibilitesPage> {
  late List<List<int>> _dayButtonState;
  late List<List<int>> _nightButtonState;
  String? _selectedRangeText;

  @override
  void initState() {
    super.initState();
    _dayButtonState =
        List.generate(4, (_) => List.filled(7, 0)); // Only 4 weeks
    _nightButtonState = List.generate(4, (_) => List.filled(7, 0));
  }

  void _toggleAvailability(
      int weekIndex, int dayIndex, bool isNightAvailability) {
    setState(() {
      if (isNightAvailability) {
        _nightButtonState[weekIndex][dayIndex] =
            (_nightButtonState[weekIndex][dayIndex] + 1) % 3;
      } else {
        _dayButtonState[weekIndex][dayIndex] =
            (_dayButtonState[weekIndex][dayIndex] + 1) % 3;
      }
    });
  }

  Widget _buildAvailabilityButton(
      int weekIndex, int dayIndex, bool isNightAvailability) {
    final buttonState = isNightAvailability
        ? _nightButtonState[weekIndex][dayIndex]
        : _dayButtonState[weekIndex][dayIndex];

    var buttonColor = Colors.white;
    String buttonText = isNightAvailability ? 'Nuit' : 'Jour';

    if (buttonState == 1) {
      buttonColor = Colors.green;
    } else if (buttonState == 2) {
      buttonColor = Colors.red;
    }

    return ElevatedButton(
      onPressed: () {
        _toggleAvailability(weekIndex, dayIndex, isNightAvailability);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 16),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWeekAvailabilityRow(int weekIndex, List<DateTime> weekDates) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (final day in weekDates)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          '${DateFormat('E').format(day)}\n${DateFormat('d').format(day)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: List.generate(7, (dayIndex) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Column(
                        children: [
                          Center(
                            child: _buildAvailabilityButton(
                                weekIndex, dayIndex, false),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: Column(
                  children: List.generate(7, (dayIndex) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Column(
                        children: [
                          Center(
                            child: _buildAvailabilityButton(
                                weekIndex, dayIndex, true),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<List<DateTime>> _generateDatesForMonth() {
    DateTime now = DateTime.now();
    List<List<DateTime>> datesByWeek = [];
    List<DateTime> currentWeek = [];

    for (int i = 1; i <= 28; i++) {
      DateTime date = now.add(Duration(days: i));
      currentWeek.add(date);

      if (currentWeek.length == 7) {
        datesByWeek.add(currentWeek);
        currentWeek = [];
      }
    }

    return datesByWeek;
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (result != null) {
      setState(() {
        _selectedRangeText =
            "De ${DateFormat('dd/MM/yyyy').format(result.start)} à ${DateFormat('dd/MM/yyyy').format(result.end)}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<List<DateTime>> monthDates = _generateDatesForMonth();

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Text(
              "${DateFormat('MMMM').format(DateTime.now())} - ${DateFormat('MMMM').format(DateTime.now().add(const Duration(days: 30)))}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          if (_selectedRangeText != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Text(
                _selectedRangeText!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: monthDates.length,
              itemBuilder: (context, index) {
                return _buildWeekAvailabilityRow(index, monthDates[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickDateRange(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.date_range),
      ),
    );
  }
}
