import 'package:flutter/material.dart';
import 'package:salonapp/components/custom_app_bar.dart';
import 'package:salonapp/components/my_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:salonapp/models/service.dart'; 


class ReservationScreen extends StatefulWidget {
  final String stylistName;
  final String employeeId; // The employee ID is crucial for checking the schedule
  final Service selectedService; // The service is crucial for duration/price

  const ReservationScreen({
    super.key,
    required this.stylistName,
    required this.employeeId,
    required this.selectedService,
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  // Calendar state
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  
  // Schedule data map: Date(normalized) -> {startTime: "9:00", endTime: "17:00"} or null
  Map<DateTime, Map<String, dynamic>> _employeeSchedule = {};
  List<String> _availableTimeSlots = [];

  String? selectedTimeSlot;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _focusedDay = _normalizeDate(DateTime.now());
    _selectedDay = _normalizeDate(DateTime.now());
    _fetchEmployeeSchedule(DateTime.now());
  }
  
  // Helper to normalize date to YYYY-MM-DD
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Helper to get service duration from the widget
  int get serviceDurationMinutes => widget.selectedService.durationMinutes;


  // --- Schedule and Time Slot Generation Logic ---

  Future<void> _fetchEmployeeSchedule(DateTime monthDate) async {
    final startOfMonth = _normalizeDate(DateTime(monthDate.year, monthDate.month, 1));
    final endOfMonth = _normalizeDate(DateTime(monthDate.year, monthDate.month + 1, 0));

    // 1. Fetch Daily Schedules (Employee Availability)
    final scheduleSnapshot = await FirebaseFirestore.instance
        .collection('schedules')
        .where('employee_id', isEqualTo: widget.employeeId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    final Map<DateTime, Map<String, dynamic>> newSchedule = {};
    for (var doc in scheduleSnapshot.docs) {
      final data = doc.data();
      final dateTimestamp = data['date'] as Timestamp;
      final normalizedDate = _normalizeDate(dateTimestamp.toDate());
      
      // *** FIX: Use Firestore field name 'is_available' ***
      if (data['is_available'] == true) {
        newSchedule[normalizedDate] = {
          // *** FIX: Use Firestore field names 'start_time' and 'end_time' ***
          'startTime': data['start_time'], 
          'endTime': data['end_time'],
        };
      }
    }

    setState(() {
      _employeeSchedule = newSchedule;
      // Recalculate time slots for the currently selected day
      _generateAvailableTimeSlots(_selectedDay);
    });
  }
  
  void _generateAvailableTimeSlots(DateTime day) async {
    final normalizedDay = _normalizeDate(day);
    final schedule = _employeeSchedule[normalizedDay];
    
    // Check 1: Is the employee scheduled to work this day AND do we have valid times?
    if (schedule == null || schedule['startTime'] == null || schedule['endTime'] == null) {
      setState(() {
        _availableTimeSlots = [];
        selectedTimeSlot = null;
      });
      // This will cause _buildTimeSlotView to show the "Not scheduled" message, solving the buffering
      return; 
    }
    
    // Safely parse the start and end times
    final startTimeString = schedule['startTime'] as String;
    final endTimeString = schedule['endTime'] as String;
    
    final workingStartTimeComponents = startTimeString.split(':').map(int.parse).toList();
    final workingEndTimeComponents = endTimeString.split(':').map(int.parse).toList();
    
    // Ensure we have valid time components
    if (workingStartTimeComponents.length < 2 || workingEndTimeComponents.length < 2) {
        setState(() {
            _availableTimeSlots = [];
            selectedTimeSlot = null;
        });
        print("ERROR: Schedule times are not in 'HH:MM' format.");
        return;
    }

    final serviceDuration = serviceDurationMinutes; 
    
    // Convert times to DateTime objects for calculation on the selected date
    DateTime currentTime = normalizedDay.add(Duration(hours: workingStartTimeComponents[0], minutes: workingStartTimeComponents[1]));
    DateTime endTime = normalizedDay.add(Duration(hours: workingEndTimeComponents[0], minutes: workingEndTimeComponents[1]));
    
    final List<String> potentialSlots = [];

    // 2. Fetch existing appointments for the selected day
    final appointmentsSnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('employee_id', isEqualTo: widget.employeeId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedDay))
        .where('date', isLessThan: Timestamp.fromDate(normalizedDay.add(const Duration(days: 1)))) // Fetch only today
        // FIX: Check 'Booked' AND 'Approved' status to prevent double-booking
        .where('status', whereIn: ['Booked', 'Approved']) 
        .orderBy('date')
        .get();

    final List<Map<String, DateTime>> bookedRanges = appointmentsSnapshot.docs.map((doc) {
      final docData = doc.data();
      final startTime = (docData['date'] as Timestamp).toDate(); // Assuming 'date' holds the start time
      final durationMinutes = docData['duration_minutes'] as int;
      final endTime = startTime.add(Duration(minutes: durationMinutes));
      return {'start': startTime, 'end': endTime};
    }).toList();

    // 3. Generate slots and check against working hours and existing bookings
    while (!currentTime.add(Duration(minutes: serviceDuration)).isAfter(endTime)) {
      final slotEndTime = currentTime.add(Duration(minutes: serviceDuration));
      bool isBooked = false;

      // Check if the potential slot overlaps with any existing booking
      for (var booking in bookedRanges) {
        // Check for overlap: Slot starts before booking ends AND slot ends after booking starts
        if (currentTime.isBefore(booking['end']!) && slotEndTime.isAfter(booking['start']!)) {
          isBooked = true;
          break;
        }
      }

      if (!isBooked) {
        // Only show slots that are in the future (today or later)
        // isSameDay is from table_calendar, no change needed here
        if (currentTime.isAfter(DateTime.now()) || isSameDay(currentTime, DateTime.now())) {
            potentialSlots.add(DateFormat.jm().format(currentTime));
        }
      }
      
      // Move to the next potential slot (using a fixed 30-minute interval for time slot display)
      currentTime = currentTime.add(const Duration(minutes: 30)); 
    }

    setState(() {
      _availableTimeSlots = potentialSlots;
      selectedTimeSlot = null;
    });
  }

  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    // Determine if the booking button should be enabled
    final isBookingEnabled = selectedTimeSlot != null && _auth.currentUser != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Book with ${widget.stylistName}'),
      // The body now contains ALL content, including the button
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Selected Service and Price
            _buildSummaryRow("Service:", widget.selectedService.name, isHeader: true),
            _buildSummaryRow("Duration:", '${serviceDurationMinutes} mins'),
            _buildSummaryRow("Price:", "\$${widget.selectedService.price.toStringAsFixed(2)}"),
            const Divider(height: 20),

            const Text("1. Select Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // 📅 Calendar Widget Implementation
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: TableCalendar(
                firstDay: _normalizeDate(DateTime.now()),
                lastDay: DateTime.now().add(const Duration(days: 365)), // Up to 1 year
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  // Only allow selecting dates in the future or today
                  if (selectedDay.isBefore(_normalizeDate(DateTime.now()))) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Cannot book appointments in the past.")),
                      );
                      return;
                  }
                  
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = _normalizeDate(selectedDay);
                      _focusedDay = focusedDay;
                    });
                    _generateAvailableTimeSlots(_selectedDay);
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                  _fetchEmployeeSchedule(focusedDay); // Fetch schedule for the new month
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final normalizedDay = _normalizeDate(day);
                    // Disable past days visually
                    if (day.isBefore(_normalizeDate(DateTime.now()))) {
                        return Center(child: Text('${day.day}', style: TextStyle(color: Colors.grey[400])));
                    }
                    
                    final isWorking = _employeeSchedule.containsKey(normalizedDay);
                    
                    if (isWorking) {
                        return Container(
                            margin: const EdgeInsets.all(6.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: isSameDay(day, DateTime.now()) ? Colors.deepPurple.shade200 : Colors.deepPurple.shade100,
                                borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                                '${day.day}',
                                style: TextStyle(color: isSameDay(day, DateTime.now()) ? Colors.black : Colors.deepPurple),
                            ),
                        );
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // ⏰ Time Slot Selection
            const Text("2. Select Time Slot", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            _buildTimeSlotView(),
            
            const SizedBox(height: 30),

            // 📝 Booking Summary
            const Text("3. Final Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildSummaryRow("Stylist:", widget.stylistName),
            _buildSummaryRow("Selected Date:", DateFormat('EEEE, MMM d, y').format(_selectedDay)),
            _buildSummaryRow("Selected Time:", selectedTimeSlot ?? "---"),
            const Divider(height: 15),
            _buildSummaryRow("TOTAL PRICE:", "\$${widget.selectedService.price.toStringAsFixed(2)}", isTotal: true),
            
            // --- Confirmation Button MOVED inside SingleChildScrollView ---
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0), // Reduced horizontal padding as parent column has 25.0
              child: MyButton(
                // Use a ternary operator to conditionally set the text based on status
                text: isBookingEnabled ? "Confirm Booking" : "Select a Time Slot to Continue",
                // Pass null to onTap to automatically disable the button
                onTap: isBookingEnabled ? () => _confirmBooking(context) : null,
              ),
            ),
            const SizedBox(height: 20), // Add bottom padding after the button
          ],
        ),
      ),
      // --- bottomNavigationBar REMOVED ---
      // Removed: bottomNavigationBar: Padding(...)
    );
  }
  
  // --- Helper Widgets and Methods ---
  
  Widget _buildTimeSlotView() {
    // If the schedule map is empty for the selected day, it will eventually display the "Not scheduled" message.
    // The loading indicator is correctly shown only when the schedule is empty AND the day is in the future.
    if (_employeeSchedule.isEmpty && _selectedDay.isAfter(_normalizeDate(DateTime.now()))) {
      return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
    }
    
    if (_availableTimeSlots.isEmpty) {
      final normalizedDay = _normalizeDate(_selectedDay);
      final isWorking = _employeeSchedule.containsKey(normalizedDay);
      
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          isWorking 
            ? "No available slots for this service on ${DateFormat.MMMd().format(_selectedDay)}. Try a different time or date."
            : "${widget.stylistName} is not scheduled to work on ${DateFormat.MMMd().format(_selectedDay)}.",
          style: const TextStyle(color: Colors.black87),
        ),
      );
    }
    
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _availableTimeSlots.map((time) {
        bool isSelected = selectedTimeSlot == time;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedTimeSlot = time;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.deepPurple : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSelected ? Colors.deepPurple : Colors.grey[300]!),
            ),
            child: Text(
              time,
              style: TextStyle(color: isSelected ? Colors.white : Colors.black87),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isHeader ? 18 : 16, color: isHeader ? Colors.deepPurple : Colors.grey[700], fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontSize: isHeader ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.deepPurple : isHeader ? Colors.deepPurple : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
  
  // --- Booking Confirmation Logic ---

  void _confirmBooking(BuildContext context) async {
    // Final check for selected time slot (though button should be disabled if null)
    if (selectedTimeSlot == null || _auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a time slot and ensure you are logged in.")),
      );
      return;
    }

    try {
      // Parse the selected time slot string (e.g., "3:30 PM")
      final DateFormat inputFormat = DateFormat.jm();
      final timeOfDay = inputFormat.parse(selectedTimeSlot!);
      
      // Combine selected date and time
      final appointmentStartTime = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
      
      // 1. Create the appointment data object
      final newAppointment = {
        'customer_id': _auth.currentUser!.uid,
        'employee_id': widget.employeeId,
        'employee_name': widget.stylistName,
        'service_id': widget.selectedService.id,
        'service_name': widget.selectedService.name,
        'date': Timestamp.fromDate(appointmentStartTime), // Use the full timestamp for start time
        'duration_minutes': serviceDurationMinutes, // Use the property
        'price': widget.selectedService.price,
        'status': 'Booked', // Key status: Appointment requested, waiting for stylist approval
        'created_at': FieldValue.serverTimestamp(),
      };

      // 2. Write to Firestore
      await FirebaseFirestore.instance.collection('appointments').add(newAppointment);

      // 3. Success notification and navigation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Appointment requested! Waiting for ${widget.stylistName}'s approval.")),
      );
      // Navigate back to the home screen (or wherever you want the user to land post-booking)
      Navigator.popUntil(context, (route) => route.isFirst); 

    } catch (e) {
      print("Booking error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create booking. Please try again.")),
      );
    }
  }
}