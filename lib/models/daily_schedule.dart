// lib/models/daily_schedule.dart (UPDATED)

import 'package:cloud_firestore/cloud_firestore.dart';

class DailySchedule {
  final String id;
  final String employeeId;
  final DateTime date;
  final bool isAvailable;
  final String? startTime;
  final String? endTime;
  // *** NEW FIELD ***
  final List<String> selectedServiceIds; 

  DailySchedule({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.isAvailable,
    this.startTime,
    this.endTime,
    // *** NEW FIELD ***
    required this.selectedServiceIds,
  });

  factory DailySchedule.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final dateTimestamp = data['date'] as Timestamp;
    
    return DailySchedule(
      id: doc.id,
      employeeId: data['employee_id'] as String,
      date: dateTimestamp.toDate(),
      isAvailable: data['is_available'] as bool,
      // Note: Using snake_case for Firestore reading
      startTime: data['start_time'] as String?, 
      endTime: data['end_time'] as String?,
      // *** NEW FIELD READING ***
      selectedServiceIds: List<String>.from(data['selected_service_ids'] ?? []), 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employee_id': employeeId,
      'date': Timestamp.fromDate(date),
      'is_available': isAvailable,
      'start_time': startTime,
      'end_time': endTime,
      // *** NEW FIELD WRITING ***
      'selected_service_ids': selectedServiceIds, 
    };
  }
}