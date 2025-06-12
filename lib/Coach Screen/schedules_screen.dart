import 'package:final_career_coaching/Coach%20Screen/coach_home_screen.dart';
import 'package:final_career_coaching/Coach%20Screen/coach_header.dart';
import 'package:final_career_coaching/model/request_appointment_model.dart';
import 'package:final_career_coaching/services/api_services.dart';
import 'package:final_career_coaching/services/coach_cancellation_request_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'request_schedule_screen.dart';
import 'reschedule_request_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Updated color constants (darker versions)
const Color darkAcceptColor = Color(0xFF0D8E4B); // Darker green
const Color darkDeclineColor = Color(0xFFB71C1C); // Darker red
const Color darkMessageColor = Color(0xFF1565C0); // Darker blue
const Color darkAcceptShadowColor = Color(0xFF2E7D32); // Darker green shadow
const Color darkDeclineShadowColor = Color(0xFFC62828); // Darker red shadow
const Color darkMessageShadowColor = Color(0xFF0D47A1); // Darker blue shadow

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  _SchedulesScreenState createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  String _selectedText = 'Schedules';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  List<Appointment> appointments = [];
  List<Appointment> filteredAppointments = [];
  bool isLoading = true;
  bool isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterAppointments);
    fetchScheduledAppointments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _filterAppointments() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredAppointments = List.from(appointments);
      } else {
        filteredAppointments = appointments.where((appointment) {
          return appointment.studentName.toLowerCase().contains(query) ||
              appointment.dateRequested.toLowerCase().contains(query) ||
              appointment.timeRequested.toLowerCase().contains(query) ||
              appointment.serviceType.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> fetchScheduledAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Appointment> fetchedAppointments =
          await ApiService.getScheduledAppointments();

      setState(() {
        appointments = fetchedAppointments;
        filteredAppointments = List.from(appointments);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching appointments: $e");
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to load appointments. Please try again."),
      ));
    }
  }

  String formatDateString(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final monthNames = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String formatTimeString(String timeString) {
    try {
      final timeParts = timeString.split(':');
      if (timeParts.length >= 2) {
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);

        int endHour = hour;
        int endMinute = minute + 30;
        if (endMinute >= 60) {
          endHour += 1;
          endMinute -= 60;
        }

        String formatTime(int hour, int minute) {
          String period = hour >= 12 ? 'PM' : 'AM';
          int displayHour = hour > 12 ? hour - 12 : hour;
          if (displayHour == 0) displayHour = 12;
          return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
        }

        return '${formatTime(hour, minute)} - ${formatTime(endHour, endMinute)}';
      }
    } catch (e) {
      return timeString;
    }
    return timeString;
  }

  String formatServiceType(String serviceType) {
    return serviceType
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Future<void> _showCompletionConfirmationDialog(
      Appointment appointment) async {
    String formattedDate = formatDateString(appointment.dateRequested);
    String formattedTime = formatTimeString(appointment.timeRequested);
    String formattedService = formatServiceType(appointment.serviceType);

    bool confirm = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder(
                    tween: ColorTween(
                      begin: Colors.grey[300],
                      end: darkAcceptColor,
                    ),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, color, child) => Icon(
                      Icons.check_circle_rounded,
                      size: 48,
                      color: color as Color?,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Mark as Completed",
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[200] ?? Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          Icons.person_outline,
                          "Student:",
                          appointment.studentName,
                        ),
                        const Divider(height: 16, thickness: 0.5),
                        _buildDetailRow(
                          Icons.work_outline,
                          "Service:",
                          formattedService,
                        ),
                        const Divider(height: 16, thickness: 0.5),
                        _buildDetailRow(
                          Icons.calendar_today_outlined,
                          "Date:",
                          formattedDate,
                        ),
                        const Divider(height: 16, thickness: 0.5),
                        _buildDetailRow(
                          Icons.access_time_outlined,
                          "Time:",
                          formattedTime,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "This session will be marked as completed.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              foregroundColor: Colors.grey[700],
                            ),
                            child: Text(
                              "Not Now",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 1, end: 1),
                        duration: const Duration(milliseconds: 150),
                        builder: (context, scale, child) => Transform.scale(
                          scale: scale as double,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkAcceptColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 1,
                              shadowColor: darkAcceptShadowColor,
                            ),
                            child: Text(
                              "Mark Completed",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;

    if (!confirm) return;

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final coachId = await ApiService.getCoachId(userId!);

      await CancellationRequestService.markAsCompleted(
        appointmentId: appointment.id,
        coachId: coachId,
        studentName: appointment.studentName,
        originalDate: appointment.dateRequested,
        originalTime: appointment.timeRequested,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment completed successfully'),
        ),
      );

      await fetchScheduledAppointments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _showRescheduleDialog(Appointment appointment) async {
    String formattedDate = formatDateString(appointment.dateRequested);
    String formattedTime = formatTimeString(appointment.timeRequested);
    String formattedService = formatServiceType(appointment.serviceType);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder(
                      tween: ColorTween(
                        begin: Colors.grey[300],
                        end: darkDeclineColor,
                      ),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, color, child) => Icon(
                        Icons.warning_amber_rounded,
                        size: 48,
                        color: color as Color?,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Cancel Session",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[200] ?? Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            Icons.person_outline,
                            "Student:",
                            appointment.studentName,
                          ),
                          const Divider(height: 16, thickness: 0.5),
                          _buildDetailRow(
                            Icons.work_outline,
                            "Service:",
                            formattedService,
                          ),
                          const Divider(height: 16, thickness: 0.5),
                          _buildDetailRow(
                            Icons.calendar_today_outlined,
                            "Date:",
                            formattedDate,
                          ),
                          const Divider(height: 16, thickness: 0.5),
                          _buildDetailRow(
                            Icons.access_time_outlined,
                            "Time:",
                            formattedTime,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Reason for cancellation:",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 4,
                      minLines: 3,
                      decoration: InputDecoration(
                        hintText: "Explain why you need to cancel...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please provide a reason";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "This will cancel the current appointment.",
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            child: TextButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                foregroundColor: Colors.grey[700],
                              ),
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 1, end: 1),
                          duration: const Duration(milliseconds: 150),
                          builder: (context, scale, child) => Transform.scale(
                            scale: scale as double,
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        setState(() => isSubmitting = true);
                                        try {
                                          final reason = _reasonController.text;
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          final userId =
                                              prefs.getString('user_id');
                                          final coachId =
                                              await ApiService.getCoachId(
                                                  userId!);

                                          await CancellationRequestService
                                              .createRequest(
                                            appointmentId: appointment.id,
                                            coachId: coachId,
                                            studentName:
                                                appointment.studentName,
                                            originalDate:
                                                appointment.dateRequested,
                                            originalTime:
                                                appointment.timeRequested,
                                            reason: reason,
                                          );

                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Appointment cancelled successfully'),
                                              ),
                                            );
                                            await fetchScheduledAppointments();
                                            Navigator.pop(context);
                                            _reasonController.clear();
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Error: ${e.toString().replaceAll('Exception: ', '')}'),
                                              ),
                                            );
                                          }
                                        } finally {
                                          if (mounted) {
                                            setState(
                                                () => isSubmitting = false);
                                          }
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkDeclineColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 1,
                                shadowColor: darkDeclineShadowColor,
                              ),
                              child: Text(
                                isSubmitting
                                    ? "Processing..."
                                    : "Confirm Cancellation",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const headerHeight = 150.0;

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: headerHeight),
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildTextWithUnderline(
                              'Dashboard', 16, context, _selectedText),
                          SizedBox(width: 20),
                          _buildTextWithUnderline(
                              'Request Schedules', 16, context, _selectedText),
                          SizedBox(width: 20),
                          _buildTextWithUnderline(
                              'Reschedule Request', 16, context, _selectedText),
                          SizedBox(width: 20),
                          _buildTextWithUnderline(
                              'Schedules', 16, context, _selectedText),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Color(0xFFE5E7EB), width: 1),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.search,
                                    color: Color(0xFF9CA3AF)),
                                hintText: 'Search students...',
                                hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Scheduled Appointments',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          isLoading
                              ? Center(child: CircularProgressIndicator())
                              : filteredAppointments.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _searchController.text.isEmpty
                                                ? Icons.calendar_today_outlined
                                                : Icons.search_off_rounded,
                                            size: 64,
                                            color: Colors.blueGrey[300],
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            _searchController.text.isEmpty
                                                ? 'No Scheduled Appointments'
                                                : 'No Student Found',
                                            style: GoogleFonts.inter(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blueGrey[800],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 40),
                                            child: Text(
                                              _searchController.text.isEmpty
                                                  ? 'There are currently no scheduled appointments'
                                                  : 'We couldn\'t find any students matching your search',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                color: Colors.blueGrey[500],
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                          if (_searchController
                                              .text.isNotEmpty) ...[
                                            const SizedBox(height: 24),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.red[700],
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _searchController.clear();
                                                  _filterAppointments();
                                                });
                                              },
                                              child: Text(
                                                'Clear Search',
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    )
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                        childAspectRatio: 3.9,
                                      ),
                                      itemCount: filteredAppointments.length,
                                      itemBuilder: (context, index) {
                                        return buildRequestCard(
                                            filteredAppointments[index]);
                                      },
                                    ),
                        ],
                      ),
                    ),
                  ],
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
              child: const CoachHeader(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRequestCard(Appointment appointment) {
    bool isCompleted = appointment.status == 'Completed';
    bool hasPendingReschedule = appointment.hasPendingReschedule ?? false;
    String formattedDate = formatDateString(appointment.dateRequested);
    String formattedTime = formatTimeString(appointment.timeRequested);
    String formattedService = formatServiceType(appointment.serviceType);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasPendingReschedule)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time,
                        size: 14, color: Colors.orange[800]),
                    const SizedBox(width: 4),
                    Text(
                      'Reschedule Pending',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: hasPendingReschedule ? 0 : 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage('assets/student_profile.jpg'),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              appointment.studentName,
                              style: GoogleFonts.inter(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Text(
                              formattedService.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.red[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Date: $formattedDate",
                        style: GoogleFonts.inter(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Time: $formattedTime",
                        style: GoogleFonts.inter(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: isCompleted
                      ? null
                      : () async {
                          await _showCompletionConfirmationDialog(appointment);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompleted
                        ? Colors.grey
                        : const Color.fromARGB(255, 60, 138, 63),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.check, color: Colors.white),
                  label: Text(
                    isCompleted ? "Completed" : "Complete",
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: hasPendingReschedule
                      ? null
                      : () async {
                          await _showRescheduleDialog(appointment);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        hasPendingReschedule ? Colors.grey : Color(0xFFC62828),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.loop, color: Colors.white),
                  label: Text(
                    hasPendingReschedule ? "Reschedule Pending" : "Reschedule",
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextWithUnderline(
      String text, double fontSize, BuildContext context, String selectedText) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedText = text;
        });
        _navigateToScreen(text, context);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight:
                  selectedText == text ? FontWeight.bold : FontWeight.normal,
              color: selectedText == text ? Colors.red : Colors.black,
            ),
          ),
          if (_selectedText == text)
            Positioned(
              bottom: -3,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                color: const Color(0xFFFF0000),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToScreen(String screenName, BuildContext context) {
    Widget screen;

    switch (screenName) {
      case 'Dashboard':
        screen = CoachScreen();
        break;
      case 'Request Schedules':
        screen = RequestScheduleScreen();
        break;
      case 'Reschedule Request':
        screen = RescheduleRequestScreen();
        break;
      case 'Schedules':
        screen = SchedulesScreen();
        break;
      default:
        screen = SchedulesScreen();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
