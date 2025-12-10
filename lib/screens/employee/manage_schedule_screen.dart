// lib/screens/employee/manage_schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:salonapp/models/daily_schedule.dart'; 
// Assuming you have a Service model you can use (or we define a minimal one below)

// Since we don't have the Service model definition, let's assume a minimal structure for this screen:
class Service {
  final String id;
  final String name;
  Service({required this.id, required this.name});
  
  factory Service.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Service(
      id: doc.id,
      name: data['name'] ?? 'Unknown Service',
    );
  }
}

class ManageScheduleScreen extends StatefulWidget {
  const ManageScheduleScreen({super.key});

  @override
  State<ManageScheduleScreen> createState() => _ManageScheduleScreenState();
}

class _ManageScheduleScreenState extends State<ManageScheduleScreen> {
  final String _employeeId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_id';
  
  // Calendar state
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Data state: Map of Date (only year/month/day) to DailySchedule object
  Map<DateTime, DailySchedule> _scheduleMap = {};
  
  // Data state: Map of Date (only year/month/day) to a count of customer appointments
  Map<DateTime, int> _appointmentsCountMap = {};

  // *** NEW DATA STATE ***
  List<Service> _allServices = [];
  bool _isLoadingServices = true;


  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    if (_employeeId != 'unknown_id') {
      _fetchAllServices().then((_) {
        _fetchMonthlyData();
      });
    }
  }

  // Helper to normalize date to YYYY-MM-DD
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // --- NEW: Fetch All Services ---
  Future<void> _fetchAllServices() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('services').get();
      setState(() {
        _allServices = snapshot.docs.map((doc) => Service.fromFirestore(doc)).toList();
        _isLoadingServices = false;
      });
    } catch (e) {
      print('Error fetching services: $e');
      setState(() {
        _isLoadingServices = false;
      });
    }
  }

  // --- Firestore Fetching Logic ---

  Future<void> _fetchMonthlyData() async {
    final startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    // 1. Fetch Daily Schedules (Employee Availability)
    final scheduleSnapshot = await FirebaseFirestore.instance
        .collection('schedules')
        .where('employee_id', isEqualTo: _employeeId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    final Map<DateTime, DailySchedule> newScheduleMap = {};
    for (var doc in scheduleSnapshot.docs) {
      final schedule = DailySchedule.fromFirestore(doc);
      newScheduleMap[_normalizeDate(schedule.date)] = schedule;
    }
    
    // 2. Fetch Customer Appointments (Reserved Status)
    final appointmentsSnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('employee_id', isEqualTo: _employeeId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        // NOTE: Counting confirmed ('Approved') and pending ('Booked') to reflect current load
        .where('status', whereIn: ['Booked', 'Approved']) 
        .get();

    final Map<DateTime, int> newAppointmentsCountMap = {};
    for (var doc in appointmentsSnapshot.docs) {
      final Timestamp dateTimestamp = doc['date'] as Timestamp;
      final date = _normalizeDate(dateTimestamp.toDate());
      newAppointmentsCountMap.update(date, (value) => value + 1, ifAbsent: () => 1);
    }


    setState(() {
      _scheduleMap = newScheduleMap;
      _appointmentsCountMap = newAppointmentsCountMap;
    });
  }

  // --- Schedule Editing Modal ---

  void _editDaySchedule(DateTime day) {
    if (_employeeId == 'unknown_id' || _isLoadingServices) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Data is still loading. Please wait.')),
      );
      return;
    }
    
    final normalizedDay = _normalizeDate(day);
    final existingSchedule = _scheduleMap[normalizedDay];
    
    // Initial values
    bool isAvailable = existingSchedule?.isAvailable ?? true; 
    TimeOfDay startTime = TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = TimeOfDay(hour: 17, minute: 0);
    // *** NEW: Initial service IDs ***
    List<String> selectedServiceIds = List<String>.from(existingSchedule?.selectedServiceIds ?? []);


    // Parse existing times if they exist
    if (existingSchedule?.startTime != null && existingSchedule!.startTime!.contains(':')) {
      final parts = existingSchedule.startTime!.split(':');
      startTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 9, minute: int.tryParse(parts[1]) ?? 0);
    }
    if (existingSchedule?.endTime != null && existingSchedule!.endTime!.contains(':')) {
      final parts = existingSchedule.endTime!.split(':');
      endTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 17, minute: int.tryParse(parts[1]) ?? 0);
    }
    
    // Helper function to format TimeOfDay for Firestore
    String _formatTime(TimeOfDay time) => 
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            
            // Adjust height based on availability (to accommodate service list)
            double modalHeight = isAvailable ? 550 : 200; 

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(25),
                height: modalHeight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Set Availability for ${DateFormat('EEEE, MMM d').format(day)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    
                    // Availability Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('I am available', style: TextStyle(fontSize: 16)),
                        Switch(
                          value: isAvailable,
                          onChanged: (bool value) {
                            setModalState(() {
                              isAvailable = value;
                            });
                          },
                          activeColor: Colors.indigo,
                        ),
                      ],
                    ),
                    
                    // Time Pickers and Service Selection
                    if (isAvailable) ...[
                      const SizedBox(height: 15),
                      // Time Pickers Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start Time:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                              TextButton(
                                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                onPressed: () async {
                                  final picked = await showTimePicker(
                                    context: context, 
                                    initialTime: startTime,
                                    builder: (context, child) => MediaQuery(
                                      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                                      child: child!,
                                    ),
                                  );
                                  if (picked != null) setModalState(() => startTime = picked);
                                },
                                child: Text(startTime.format(context), style: const TextStyle(fontSize: 18, color: Colors.indigo, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('End Time:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                              TextButton(
                                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                onPressed: () async {
                                  final picked = await showTimePicker(
                                    context: context, 
                                    initialTime: endTime,
                                    builder: (context, child) => MediaQuery(
                                      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                                      child: child!,
                                    ),
                                  );
                                  if (picked != null) setModalState(() => endTime = picked);
                                },
                                child: Text(endTime.format(context), style: const TextStyle(fontSize: 18, color: Colors.indigo, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      const Text('Services Offered:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      // *** NEW: Service Checkboxes ***
                      Expanded(
                        child: ListView(
                          children: _allServices.map((service) {
                            final isSelected = selectedServiceIds.contains(service.id);
                            return CheckboxListTile(
                              title: Text(service.name),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setModalState(() {
                                  if (value == true) {
                                    selectedServiceIds.add(service.id);
                                  } else {
                                    selectedServiceIds.remove(service.id);
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: Colors.indigo,
                              contentPadding: EdgeInsets.zero,
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    // Save Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () async {
                        // 1. Validate (Start time must be before end time)
                        if (isAvailable) {
                           if (startTime.hour > endTime.hour || 
                                (startTime.hour == endTime.hour && startTime.minute >= endTime.minute)
                           ) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error: Start time must be before end time.')),
                              );
                              return;
                           }
                           // *** NEW: Validate at least one service is selected ***
                           if (selectedServiceIds.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error: Must select at least one service.')),
                              );
                              return;
                           }
                        }

                        // 2. Create/Update the DailySchedule object
                        final scheduleToSave = DailySchedule(
                          id: existingSchedule?.id ?? '',
                          employeeId: _employeeId,
                          date: normalizedDay,
                          isAvailable: isAvailable,
                          startTime: isAvailable ? _formatTime(startTime) : null,
                          endTime: isAvailable ? _formatTime(endTime) : null,
                          // *** NEW: Save selected service IDs ***
                          selectedServiceIds: isAvailable ? selectedServiceIds : [], 
                        );
                        
                        // 3. Save to Firestore
                        final collection = FirebaseFirestore.instance.collection('schedules');
                        
                        try {
                          if (existingSchedule != null) {
                            // Update existing document
                            await collection.doc(existingSchedule.id).update(scheduleToSave.toMap());
                          } else {
                            // Create new document
                            await collection.add(scheduleToSave.toMap());
                          }

                          // 4. Close modal, refresh data, and notify
                          Navigator.pop(context);
                          _fetchMonthlyData(); // Refresh the calendar view
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Schedule saved for ${DateFormat('MMM d').format(day)}')),
                          );
                        } catch (e) {
                          // Handle any Firestore errors (like permission denied) gracefully
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error saving schedule: ${e.toString()}')),
                          );
                        }
                      },
                      child: const Text('Save Schedule', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Calendar Marker Logic (Unchanged) ---

  Color _getMarkerColor(DateTime day) {
    final normalizedDay = _normalizeDate(day);
    final schedule = _scheduleMap[normalizedDay];
    final hasAppointment = _appointmentsCountMap.containsKey(normalizedDay);

    // Rule 1: Reserved appointments take precedence (Yellow)
    if (hasAppointment) {
      return Colors.amber.shade700; 
    }
    
    // Rule 2: Based on employee-set availability
    if (schedule != null) {
      return schedule.isAvailable ? Colors.green.shade600 : Colors.red.shade600;
    }

    // Rule 3: Default is grey (No explicit setting, treat as unavailable)
    return Colors.grey.shade400; 
  }

  // --- Main Build Method ---

@override
Widget build(BuildContext context) {
  if (_isLoadingServices) {
     return Scaffold( // Removed const
      appBar: AppBar(
        // Added const to Text
        title: const Text('Manage My Availability', style: TextStyle(color: Colors.white)), 
        backgroundColor: Colors.indigo
      ),
      // Added const to Center/CircularProgressIndicator
      body: const Center(child: CircularProgressIndicator(color: Colors.indigo)), 
     );
  }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage My Availability'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = _normalizeDate(selectedDay);
                      _focusedDay = focusedDay; // update `_focusedDay` as well
                    });
                    _editDaySchedule(selectedDay);
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                  _fetchMonthlyData(); // Refresh data when month changes
                },
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(color: Colors.indigo.shade200, shape: BoxShape.circle),
                  selectedDecoration: const BoxDecoration(color: Colors.indigo, shape: BoxShape.circle),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                // Custom Builder for colored markers
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final color = _getMarkerColor(day);
                    return Container(
                      margin: const EdgeInsets.all(6.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: isSameDay(day, DateTime.now()) ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    final color = _getMarkerColor(day);
                    return Container(
                      margin: const EdgeInsets.all(6.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.8), // Selected day gets a slightly different shade
                        border: Border.all(color: Colors.indigo.shade800, width: 2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const Divider(thickness: 1, indent: 20, endIndent: 20),
            
            // 📝 Legend
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Schedule Legend:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildLegendItem(Colors.green.shade600, 'Available (Open for Booking)'),
                  _buildLegendItem(Colors.red.shade600, 'Unavailable (Time off / Not Working)'),
                  _buildLegendItem(Colors.amber.shade700, 'Reserved (Customer Booked)'),
                  _buildLegendItem(Colors.grey.shade400, 'No Setting (Default Unavailable)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widget for the Legend (Unchanged)
Widget _buildLegendItem(Color color, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        Container(width: 15, height: 15, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 10),
        Text(text),
      ],
    ),
  );
}