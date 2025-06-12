import 'package:final_career_coaching/model/student_request_reschedule_model.dart';
import 'package:final_career_coaching/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coach_header.dart';
import 'coach_home_screen.dart';
import 'request_schedule_screen.dart';
import 'schedules_screen.dart';

// Color constants
const Color darkAcceptColor = Color(0xFF0F9D58);
const Color darkDeclineColor = Color(0xFFC62828);
const Color darkAcceptShadowColor = Color(0xFF81C784);
const Color darkDeclineShadowColor = Color(0xFFE57373);

class RescheduleRequestScreen extends StatefulWidget {
  const RescheduleRequestScreen({super.key});

  @override
  _RescheduleRequestScreenState createState() =>
      _RescheduleRequestScreenState();
}

class _RescheduleRequestScreenState extends State<RescheduleRequestScreen> {
  String _selectedText = 'Reschedule Request';
  final TextEditingController _searchController = TextEditingController();
  List<RescheduleRequest> requests = [];
  List<RescheduleRequest> filteredRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterRequests);
    fetchRescheduleRequests();
  }

  void _filterRequests() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredRequests = List.from(requests);
      } else {
        filteredRequests = requests.where((request) {
          return request.studentName.toLowerCase().contains(query) ||
              request.dateRequest.toLowerCase().contains(query) ||
              request.timeRequest.toLowerCase().contains(query) ||
              request.message.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> fetchRescheduleRequests() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<RescheduleRequest> fetchedRequests =
          await ApiService.getPendingRescheduleRequests();

      setState(() {
        requests = fetchedRequests;
        filteredRequests = List.from(requests);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching reschedule requests: $e");
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Failed to load reschedule requests: ${e.toString().replaceAll('Exception: ', '')}"),
        duration: Duration(seconds: 4),
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

  Future<bool> _showAcceptConfirmationDialog(RescheduleRequest request) async {
    String formattedDate = formatDateString(request.dateRequest);
    String formattedTime = formatTimeString(request.timeRequest);
    String formattedService = formatServiceType(request.serviceType);

    return await showDialog<bool>(
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
                    "Accept Reschedule Request",
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
                          request.studentName,
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
                    "This will notify ${request.studentName.split(' ')[0]} "
                    "that you've accepted their reschedule request.",
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
                              HapticFeedback.lightImpact();
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
                              "Accept Request",
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
  }

  Future<bool> showDeclineConfirmationDialog(RescheduleRequest request) async {
    String formattedDate = formatDateString(request.dateRequest);
    String formattedTime = formatTimeString(request.timeRequest);
    String formattedService = formatServiceType(request.serviceType);

    return await showDialog<bool>(
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
                    "Decline Reschedule Request?",
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
                          request.studentName,
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
                    "This will notify ${request.studentName.split(' ')[0]} that "
                    "you're unavailable. They'll be encouraged to request another time.",
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
                              "Go Back",
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
                              HapticFeedback.lightImpact();
                              Navigator.pop(context, true);
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
                              "Decline",
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

  Widget buildRequestCard(RescheduleRequest request) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
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
                              request.studentName,
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
                              formatServiceType(request.serviceType)
                                  .toUpperCase(),
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
                        "Date: ${formatDateString(request.dateRequest)}",
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                      Text(
                        "Time: ${formatTimeString(request.timeRequest)}",
                        style: GoogleFonts.inter(fontSize: 13),
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
                  onPressed: () => _handleViewMessage(request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: Icon(Icons.message, color: Colors.white),
                  label: Text("View", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _handleDeclineRequest(request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkDeclineColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: Icon(Icons.close, color: Colors.white),
                  label: Text("Decline", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _handleAcceptRequest(request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkAcceptColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: Icon(Icons.check, color: Colors.white),
                  label: Text("Accept", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleViewMessage(RescheduleRequest request) async {
    String formattedDate = formatDateString(request.dateRequest);
    String formattedTime = formatTimeString(request.timeRequest);
    String formattedService = formatServiceType(request.serviceType);

    await showDialog(
      context: context,
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
                  end: Colors.blue.shade800,
                ),
                duration: const Duration(milliseconds: 500),
                builder: (context, color, child) => Icon(
                  Icons.message_rounded,
                  size: 48,
                  color: color as Color?,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Reschedule Reason",
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
                      request.studentName,
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Message:",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      request.message,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 1,
                        ),
                        child: Text(
                          "Close",
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
    );
  }

  Future<void> _handleAcceptRequest(RescheduleRequest request) async {
    bool confirm = await _showAcceptConfirmationDialog(request);
    if (!confirm) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final coachId = await ApiService.getCoachId(userId!);

      final success = await ApiService.acceptRescheduleRequest(
        requestId: request.id.toString(),
        coachId: coachId,
        coachReply: "Your reschedule request has been accepted",
      );

      if (success) {
        setState(() {
          requests.removeWhere((r) => r.id == request.id);
          filteredRequests.removeWhere((r) => r.id == request.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Reschedule request accepted!'),
        ));
      } else {
        throw Exception('Failed to accept reschedule request');
      }
    } catch (e) {
      print('Error in _handleAcceptRequest: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
      ));
    }
  }

  Future<void> _handleDeclineRequest(RescheduleRequest request) async {
    bool confirm = await showDeclineConfirmationDialog(request);
    if (!confirm) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final coachId = await ApiService.getCoachId(userId!);

      final success = await ApiService.declineRescheduleRequest(
        requestId: request.id.toString(),
        coachId: coachId,
        coachReply: "Your reschedule request has been declined",
      );

      if (success) {
        setState(() {
          requests.removeWhere((r) => r.id == request.id);
          filteredRequests.removeWhere((r) => r.id == request.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Reschedule request declined!'),
        ));
      } else {
        throw Exception('Failed to decline reschedule request');
      }
    } catch (e) {
      print('Error in _handleDeclineRequest: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
      ));
    }
  }

  Widget _buildTextWithUnderline(
      String text, double fontSize, BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedText = text;
        });
        if (text == 'Dashboard') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CoachScreen()),
          );
        } else if (text == 'Request Schedules') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RequestScheduleScreen()),
          );
        } else if (text == 'Reschedule Request') {
          // Stay on current screen
        } else if (text == 'Schedules') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SchedulesScreen()),
          );
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight:
                  _selectedText == text ? FontWeight.bold : FontWeight.normal,
              color: _selectedText == text ? Colors.red : Colors.black,
            ),
          ),
          if (_selectedText == text)
            Positioned(
              bottom: -3,
              left: 0,
              right: 0,
              child: Container(height: 2, color: Color(0xFFFF0000)),
            ),
        ],
      ),
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
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildTextWithUnderline('Dashboard', 16, context),
                        SizedBox(width: 20),
                        _buildTextWithUnderline(
                            'Request Schedules', 16, context),
                        SizedBox(width: 20),
                        _buildTextWithUnderline(
                            'Reschedule Request', 16, context),
                        SizedBox(width: 20),
                        _buildTextWithUnderline('Schedules', 16, context),
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
                            border:
                                Border.all(color: Color(0xFFE5E7EB), width: 1),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              prefixIcon:
                                  Icon(Icons.search, color: Color(0xFF9CA3AF)),
                              hintText: 'Search students...',
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Reschedule Requests',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : filteredRequests.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _searchController.text.isEmpty
                                        ? Icons.assignment_outlined
                                        : Icons.search_off_rounded,
                                    size: 64,
                                    color: Colors.blueGrey[300],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    _searchController.text.isEmpty
                                        ? 'No Pending Requests'
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
                                          ? 'There are currently no reschedule requests from students'
                                          : 'We couldn\'t find any students matching your search',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: Colors.blueGrey[500],
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  if (_searchController.text.isNotEmpty) ...[
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[700],
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          // Add your filter function here if needed
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
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 3.9,
                                ),
                                itemCount: filteredRequests.length,
                                itemBuilder: (context, index) {
                                  return buildRequestCard(
                                      filteredRequests[index]);
                                },
                              ),
                            ),
                ],
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
