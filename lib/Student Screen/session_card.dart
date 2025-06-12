import 'package:final_career_coaching/Student%20Screen/cancellation_reason_dialog.dart';
import 'package:final_career_coaching/model/session_model.dart';
import 'package:final_career_coaching/services/coach_cancellation_request_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_career_coaching/services/reschedule_request_service.dart';

class SessionCard extends StatefulWidget {
  final Session session;
  final Future<void> Function()? onReschedule;

  const SessionCard({
    Key? key,
    required this.session,
    this.onReschedule,
  }) : super(key: key);

  @override
  _SessionCardState createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
  bool _hasPendingReschedule = false;
  bool _isLoading = true;
  bool _isRescheduled = false;

  @override
  void initState() {
    super.initState();
    _checkRescheduleStatus();
    _checkIfRescheduled();
  }

  Future<void> _checkRescheduleStatus() async {
    try {
      final hasPending = await RescheduleRequestService.hasPendingReschedule(
        int.parse(widget.session.appointmentId),
      );
      if (mounted) {
        setState(() {
          _hasPendingReschedule = hasPending;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error checking reschedule status: $e');
    }
  }

  Future<void> _checkIfRescheduled() async {
    try {
      final isRescheduled = await RescheduleRequestService.hasAcceptedReschedule(
        int.parse(widget.session.appointmentId),
      );
      if (mounted) {
        setState(() {
          _isRescheduled = isRescheduled;
        });
      }
    } catch (e) {
      debugPrint('Error checking rescheduled status: $e');
    }
  }

  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      final monthNames = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
      ];
      return "${monthNames[parsedDate.month-1]} ${parsedDate.day.toString().padLeft(2, '0')}, ${parsedDate.year}";
    } catch (e) {
      return date;
    }
  }

  String _formatTime(String time) {
    try {
      DateTime parsedTime = DateTime.parse("1970-01-01 $time");
      String startHour = parsedTime.hour % 12 == 0 ? '12' : (parsedTime.hour % 12).toString();
      String startMinute = parsedTime.minute.toString().padLeft(2, '0');
      String startAmPm = parsedTime.hour < 12 ? 'AM' : 'PM';
      String startTime = '$startHour:$startMinute $startAmPm';

      DateTime endTime = parsedTime.add(const Duration(minutes: 30));
      String endHour = endTime.hour % 12 == 0 ? '12' : (endTime.hour % 12).toString();
      String endMinute = endTime.minute.toString().padLeft(2, '0');
      String endAmPm = endTime.hour < 12 ? 'AM' : 'PM';
      String formattedEndTime = '$endHour:$endMinute $endAmPm';

      return '$startTime - $formattedEndTime';
    } catch (e) {
      return time;
    }
  }

  Widget _buildStatusIndicator() {
    // Handle both accepted reschedules and RESCHEDULE status
    if (_isRescheduled || widget.session.status == 'RESCHEDULE') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.red),
        ),
        child: Text(
          'RESCHEDULED',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.red[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    switch (widget.session.status) {
      case 'Pending':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'PENDING',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.red[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'Accepted':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'ACCEPTED',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.red[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'Completed':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'COMPLETED',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.red[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'Cancelled':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.red),
          ),
          child: Text(
            'CANCELLED',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.red[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'Declined':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'DECLINED',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      default:
        return Container();
    }
  }

  Color _getCardBorderColor() {
    if (_isRescheduled || widget.session.status == 'RESCHEDULE') {
      return Colors.red;
    }
    switch (widget.session.status) {
      case 'Cancelled':
        return const Color(0xFFC62828);
      default:
        return Colors.transparent;
    }
  }

  Future<void> _showCancellationReason(BuildContext context) async {
    try {
      final cancellationRequest = await CancellationRequestService.getCancellationRequestByAppointmentId(int.parse(widget.session.appointmentId));
      
      if (cancellationRequest != null && cancellationRequest.reason != null && cancellationRequest.reason!.isNotEmpty) {
        await showDialog(
          context: context,
          builder: (context) => CancellationReasonDialog(
            coachName: cancellationRequest.coachName ?? '',
            reason: cancellationRequest.reason!,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No cancellation reason found',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.grey[700],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load cancellation reason',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error showing cancellation reason: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDisabled = widget.session.isCancelled || _isRescheduled || widget.session.status == 'RESCHEDULE';
    final isRescheduledStatus = _isRescheduled || widget.session.status == 'RESCHEDULE';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getCardBorderColor(),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'WDT: ${widget.session.coachName}',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDisabled ? Colors.grey : Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusIndicator(),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.session.serviceType,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date: ${_formatDate(widget.session.sessionDate)}',
                      style: GoogleFonts.inter(
                        fontSize: 14, 
                        color: isDisabled ? Colors.grey : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Time: ${_formatTime(widget.session.sessionTime)}',
                      style: GoogleFonts.inter(
                        fontSize: 14, 
                        color: isDisabled ? Colors.grey : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.session.isUpcoming && widget.onReschedule != null)
  Padding(
    padding: const EdgeInsets.only(top: 4),
    child: isRescheduledStatus
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green[800],
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  "Accepted",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
          )
        : _hasPendingReschedule
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.hourglass_empty,
                      color: Colors.red[800],
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Awaiting Confirmation",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.red[800],
                      ),
                    ),
                  ],
                ),
              )
            : ElevatedButton(
                onPressed: () async {
                  await widget.onReschedule!();
                  setState(() => _hasPendingReschedule = true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  minimumSize: const Size(0, 40),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.loop,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Reschedule",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
  ),
              if (widget.session.isCancelled || widget.session.status == 'RESCHEDULE')
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: ElevatedButton(
                    onPressed: () => _showCancellationReason(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      minimumSize: const Size(0, 40),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.message, size: 18, color: Colors.black),
                        const SizedBox(width: 8),
                        Text(
                          "View Message",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}