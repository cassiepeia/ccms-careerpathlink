import 'package:final_career_coaching/services/coach_cancellation_request_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_career_coaching/model/coach_cancellation_request.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Map<int, TextEditingController> _replyControllers = {};
  List<CoachCancellationRequest> _messages = [];
  List<CoachCancellationRequest> _filteredMessages = [];
  bool _isLoading = true;
  final Map<int, bool> _isSendingMap = {};

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _searchController.addListener(_filterMessages);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _replyControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    try {
      final requests = await CancellationRequestService.getRequests();
      setState(() {
        _messages = requests;
        _filteredMessages = requests;
        _isLoading = false;
        // Initialize reply controllers for each message
        for (var message in requests) {
          _replyControllers[message.id!] = TextEditingController();
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load messages: $e')),
      );
    }
  }

  void _filterMessages() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMessages = _messages
          .where((message) =>
              (message.studentName ?? '').toLowerCase().contains(query) ||
              (message.coachName ?? '').toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _submitReply(int messageId) async {
    final replyText = _replyControllers[messageId]?.text.trim() ?? '';
    if (replyText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reply')),
      );
      return;
    }

    setState(() {
      _isSendingMap[messageId] = true;
    });

    try {
      final updatedRequest = await CancellationRequestService.submitStudentReply(
        cancellationId: messageId,
        studentReply: replyText,
      );

      // Update the message in our list
      setState(() {
        final index = _messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          _messages[index] = updatedRequest;
          _filteredMessages = List.from(_messages);
        }
        _replyControllers[messageId]?.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply sent successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send reply: $e')),
      );
    } finally {
      setState(() {
        _isSendingMap[messageId] = false;
      });
    }
  }

  Widget _buildStudentAvatar(String name, double radius) {
    final initials = name.isEmpty 
        ? '?' 
        : name.split(' ').length > 1 
            ? '${name.split(' ')[0][0]}${name.split(' ').last[0]}'.toUpperCase()
            : name[0].toUpperCase();
    
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blue.shade800,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.6,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'No date';
    
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final month = _getMonthName(dateTime.month);
      final day = dateTime.day;
      final year = dateTime.year;
      final hour = dateTime.hour;
      final minute = dateTime.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
      
      return '$month $day, $year | $displayHour:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'January';
      case 2: return 'February';
      case 3: return 'March';
      case 4: return 'April';
      case 5: return 'May';
      case 6: return 'June';
      case 7: return 'July';
      case 8: return 'August';
      case 9: return 'September';
      case 10: return 'October';
      case 11: return 'November';
      case 12: return 'December';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Text(
                'Messages',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFFE5E7EB), width: 1),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                    hintText: 'Search by name...',
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12, horizontal: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _filteredMessages.isEmpty
                        ? SizedBox(
                            height: 200,
                            child: Center(
                              child: Text(
                                'No results found',
                                style: GoogleFonts.inter(
                                  fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          )
                        : Column(
                            children: _filteredMessages.map((message) {
                              final isSending = _isSendingMap[message.id] ?? false;
                              final replyController = _replyControllers[message.id] ?? TextEditingController();
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Color(0xFFE5E7EB), width: 1),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          _buildStudentAvatar(
                                            message.coachName ?? 'Coach',
                                            20,
                                          ),
                                          SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                message.coachName ?? 'Coach Name',
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                _formatDateTime(message.requestDate),
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        message.reason ?? 'No reason provided',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      if (message.studentReply != null) ...[
  SizedBox(height: 10),
  Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CircleAvatar(
        radius: 20,
        backgroundColor: Colors.green.shade800, // Different color for student
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 20,
        ),
      ),
      SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You', // Or use student name if available
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            Text(
              _formatDateTime(message.replyDate),
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                message.studentReply!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
],
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: Color(0xFFE5E7EB),
                                                  width: 1,
                                                ),
                                              ),
                                              child: TextField(
                                                controller: replyController,
                                                enabled: message.studentReply == null,
                                                decoration: InputDecoration(
                                                  hintText: message.studentReply == null 
                                                      ? 'Type your reply...' 
                                                      : 'Reply already submitted',
                                                  hintStyle: TextStyle(
                                                    color: Color(0xFF9CA3AF)),
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          ElevatedButton(
                                            onPressed: message.studentReply == null && !isSending
                                                ? () => _submitReply(message.id!)
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              shape: CircleBorder(),
                                              padding: EdgeInsets.all(12),
                                              backgroundColor: Colors.blue,
                                            ),
                                            child: isSending
                                                ? SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : Icon(
                                                    Icons.send,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}