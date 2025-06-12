import 'package:final_career_coaching/Student%20Screen/session_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_career_coaching/model/session_model.dart';

class CombinedSessionsView extends StatefulWidget {
  final List<Session> upcomingSessions;
  final List<Session> pastSessions;
  final List<Session> pendingSessions;
  final List<Session> cancelledSessions;
  final Function(Session) onReschedule;

  const CombinedSessionsView({
    Key? key,
    required this.upcomingSessions,
    required this.pastSessions,
    required this.pendingSessions,
    required this.cancelledSessions,
    required this.onReschedule,
  }) : super(key: key);
  

  @override
  _CombinedSessionsViewState createState() => _CombinedSessionsViewState();
}

class _CombinedSessionsViewState extends State<CombinedSessionsView> {
  bool _showAllUpcoming = false;
  bool _showAllPast = false;
  bool _showAllPending = false;
  bool _showAllCancelled = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upcoming Sessions
          _buildSessionSection(
            title: 'Upcoming Sessions',
            sessions: widget.upcomingSessions,
            showAll: _showAllUpcoming,
            onToggleShowAll: () => setState(() => _showAllUpcoming = !_showAllUpcoming),
            emptyMessage: 'No upcoming sessions',
            isUpcoming: true,
          ),

          // Pending Sessions
          _buildSessionSection(
            title: 'Pending Requests',
            sessions: widget.pendingSessions,
            showAll: _showAllPending,
            onToggleShowAll: () => setState(() => _showAllPending = !_showAllPending),
            emptyMessage: 'No pending requests',
            isUpcoming: false,
          ),

          // Past Sessions
          _buildSessionSection(
            title: 'Past Sessions',
            sessions: widget.pastSessions,
            showAll: _showAllPast,
            onToggleShowAll: () => setState(() => _showAllPast = !_showAllPast),
            emptyMessage: 'No past sessions',
            isUpcoming: false,
          ),

          // Cancelled Sessions
          _buildSessionSection(
            title: 'Cancelled Sessions',
            sessions: widget.cancelledSessions,
            showAll: _showAllCancelled,
            onToggleShowAll: () => setState(() => _showAllCancelled = !_showAllCancelled),
            emptyMessage: 'No cancelled sessions',
            isUpcoming: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionSection({
    required String title,
    required List<Session> sessions,
    required bool showAll,
    required VoidCallback onToggleShowAll,
    required String emptyMessage,
    required bool isUpcoming,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFFFF0000),
              ),
            ),
          ),
          if (sessions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  ...(showAll ? sessions : sessions.take(2))
                      .map((session) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: SessionCard(
                              session: session,
                              onReschedule: isUpcoming 
                                  ? () => widget.onReschedule(session)
                                  : null,
                            ),
                          )),
                  if (sessions.length > 2)
                    Center(
                      child: TextButton(
                        onPressed: onToggleShowAll,
                        child: Text(
                          showAll ? 'View Less' : 'View More (${sessions.length})',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFFF0000),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 50, color: Colors.grey),
                    const SizedBox(height: 10),
                    Text(
                      emptyMessage,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}