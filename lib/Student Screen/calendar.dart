// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'package:final_career_coaching/Student%20Screen/book_confirmation.dart';
import 'package:final_career_coaching/Student%20Screen/home_screen.dart';
import 'package:final_career_coaching/services/api_services.dart';
import 'package:final_career_coaching/Student%20Screen/student_header.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:final_career_coaching/model/time_slot.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarScreen extends StatefulWidget {
  final String coachName;
  final Map<String, List<TimeSlot>> availableTimeSlots;
  final String selectedService;

  const CalendarScreen({
    Key? key,
    required this.coachName,
    required this.availableTimeSlots,
    required this.selectedService,
  }) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<DateTime> _selectedDay;
  late final ValueNotifier<DateTime> _focusedDay;
  TimeSlot? _selectedSlot;
  bool _isLoading = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final headerHeight = 150.0;

  @override
  void initState() {
    super.initState();
    _selectedDay = ValueNotifier(DateTime.now());
    _focusedDay = ValueNotifier(DateTime.now());
  }

  @override
  void dispose() {
    _selectedDay.dispose();
    _focusedDay.dispose();
    super.dispose();
  }

  Future<void> _refreshSlots() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
          backgroundColor: Colors.white,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.warning, color: Colors.red, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Cancel Booking",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  "Are you sure you want to cancel this booking process?",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(
                          color: Colors.grey[400]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "No",
                        style: GoogleFonts.inter(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text(
                        "Yes",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAdvanceBookingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
          backgroundColor: Colors.white,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Plan Ahead",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Please schedule at least 3 days before your session",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Got It',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReviewDialog() {
    if (_selectedSlot == null) return;

    // Check if selected date is within 3 days
    if (_isWithinThreeDays(_selectedDay.value)) {
      _showAdvanceBookingDialog();
      return;
    }

    String selectedDate = DateFormat('MMMM d, yyyy').format(_selectedDay.value);
    String selectedTime =
        '${_selectedSlot!.startTime} - ${_selectedSlot!.endTime}';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    size: 32,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Review Booking",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      _buildBookingDetailRow("Coach", widget.coachName),
                      const SizedBox(height: 12),
                      _buildBookingDetailRow("Service", widget.selectedService),
                      const SizedBox(height: 12),
                      _buildBookingDetailRow("Date", selectedDate),
                      const SizedBox(height: 12),
                      _buildBookingDetailRow("Time", selectedTime),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "Note: The session duration is 30 minutes.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(
                          color: Colors.grey[400]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        bool success = await _bookAppointment();
                        if (success) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BookConfirmationScreen()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to book appointment.",
                                  style: GoogleFonts.inter()),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Confirm",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            "$label:",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: headerHeight),
            child: SingleChildScrollView(
              child: Container(
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Book Your ${widget.selectedService}',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Select an available date and time below',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                  child: TableCalendar(
                                    firstDay: DateTime.now(),
                                    lastDay: DateTime.now()
                                        .add(const Duration(days: 365)),
                                    focusedDay: _focusedDay.value,
                                    calendarFormat: _calendarFormat,
                                    selectedDayPredicate: (day) =>
                                        isSameDay(_selectedDay.value, day),
                                    onDaySelected: (selectedDay, focusedDay) {
                                      if (_isWithinThreeDays(selectedDay)) {
                                        _showAdvanceBookingDialog();
                                        return;
                                      }
                                      setState(() {
                                        _selectedDay.value = selectedDay;
                                        _focusedDay.value = focusedDay;
                                        _selectedSlot = null;
                                      });
                                    },
                                    onFormatChanged: (format) {
                                      setState(() {
                                        _calendarFormat = format;
                                      });
                                    },
                                    onPageChanged: (focusedDay) {
                                      _focusedDay.value = focusedDay;
                                    },
                                    eventLoader: (day) {
                                      final dateStr = DateFormat('MMMM d, yyyy')
                                          .format(day);
                                      return widget.availableTimeSlots
                                              .containsKey(dateStr)
                                          ? ['']
                                          : [];
                                    },
                                    calendarStyle: CalendarStyle(
                                      defaultDecoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.transparent,
                                      ),
                                      selectedDecoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      todayDecoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      markerDecoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      weekendTextStyle:
                                          TextStyle(color: Colors.grey),
                                      outsideDaysVisible: false,
                                    ),
                                    headerStyle: HeaderStyle(
                                      formatButtonVisible: false,
                                      titleCentered: true,
                                      leftChevronIcon: Icon(Icons.chevron_left,
                                          color: Colors.red),
                                      rightChevronIcon: Icon(
                                          Icons.chevron_right,
                                          color: Colors.red),
                                      titleTextStyle: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    daysOfWeekStyle: DaysOfWeekStyle(
                                      weekdayStyle: GoogleFonts.inter(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                      weekendStyle: GoogleFonts.inter(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 400,
                                color: Colors.grey[200],
                                margin: EdgeInsets.symmetric(horizontal: 16),
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (_selectedDay.value != null) ...[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Available Slots',
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  DateFormat('EEEE, MMMM d')
                                                      .format(
                                                          _selectedDay.value),
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            _isLoading
                                                ? CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(Colors.red),
                                                    strokeWidth: 2,
                                                  )
                                                : IconButton(
                                                    icon: Container(
                                                      padding:
                                                          EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.red
                                                            .withOpacity(0.1),
                                                      ),
                                                      child: Icon(Icons.refresh,
                                                          color: Colors.red,
                                                          size: 20),
                                                    ),
                                                    onPressed: _refreshSlots,
                                                  ),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        _buildAvailableSlots(),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: _showCancelDialog,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  side: BorderSide(
                                    color: Colors.grey[400]!,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.inter(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: _selectedSlot != null
                                    ? _showReviewDialog
                                    : null,
                                child: Text(
                                  'Book Session',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 4.0,
              color: Colors.white,
              child: const HeaderWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableSlots() {
    String selectedDateStr =
        DateFormat('MMMM d, yyyy').format(_selectedDay.value);
    final availableSlots = widget.availableTimeSlots[selectedDateStr] ?? [];

    if (availableSlots.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, size: 40, color: Colors.grey[400]),
              SizedBox(height: 8),
              Text(
                'No available slots for this day',
                style: GoogleFonts.inter(
                    color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: ListView.builder(
        itemCount: availableSlots.length,
        itemBuilder: (context, index) {
          final slot = availableSlots[index];
          bool isSelected = _selectedSlot == slot;
          bool isClickable = slot.clickable;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
            child: GestureDetector(
              onTap: isClickable
                  ? () {
                      if (_isWithinThreeDays(_selectedDay.value)) {
                        _showAdvanceBookingDialog();
                        return;
                      }
                      setState(() {
                        _selectedSlot = slot;
                      });
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isSelected ? Colors.red[100]! : Colors.white,
                      Colors.grey[50]!
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                  border: Border.all(
                    color: isSelected
                        ? Colors.red
                        : (isClickable ? Colors.grey[300]! : Colors.grey[400]!),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isClickable
                            ? Colors.red.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.access_time,
                          color: isClickable ? Colors.red : Colors.grey,
                          size: 18),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isClickable ? Colors.black : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          isClickable ? "Available" : "Unavailable",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isClickable
                                ? Colors.green[700]
                                : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTime(String time) {
    try {
      // Check if time already contains AM/PM
      if (time.contains('AM') || time.contains('PM')) {
        // Remove any existing AM/PM and whitespace
        final cleanedTime = time.replaceAll(RegExp(r'[AP]M'), '').trim();
        final period = time.contains('AM') ? 'AM' : 'PM';

        // Split the cleaned time
        final parts = cleanedTime.split(':');
        if (parts.length < 2) return time;

        return '${parts[0]}:${parts[1]} $period';
      }

      // Original 24-hour format handling
      final parts = time.split(':');
      if (parts.length < 2) return time;

      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return '$displayHour:${minute.padLeft(2, '0')} $period';
    } catch (e) {
      return time;
    }
  }

  bool _isWithinThreeDays(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    return difference < 3 && difference >= 0;
  }

  Future<bool> _bookAppointment() async {
    if (_selectedSlot == null) {
      print("Error: No time slot selected.");
      return false;
    }

    // Double-check the 3-day rule before booking
    if (_isWithinThreeDays(_selectedDay.value)) {
      _showAdvanceBookingDialog();
      return false;
    }

    String selectedDate = DateFormat('yyyy-MM-dd').format(_selectedDay.value);
    String selectedTime = _selectedSlot!.startTime;
    String? userId = await ApiService.getUserId();

    if (userId == null) {
      print("Error: No user ID found.");
      return false;
    }

    String coachId = _selectedSlot!.coachId.toString();

    Map<String, dynamic> requestData = {
      "user_id": userId,
      "date_requested": selectedDate,
      "time_requested": selectedTime,
      "coach_id": coachId,
      "service_type": widget.selectedService,
    };

    print("Sending Data to API: ${jsonEncode(requestData)}");

    return await ApiService.createAppointment(requestData);
  }
}
