// ignore_for_file: unused_field

import 'package:final_career_coaching/Login%20and%20Signup%20Page/login_page.dart';
import 'package:final_career_coaching/Student%20Screen/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_career_coaching/Login%20and%20Signup%20Page/user.dart';
import 'package:final_career_coaching/Student%20Screen/student_profile.dart';
import 'package:final_career_coaching/model/student_notification_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({Key? key}) : super(key: key);

  @override
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  String? _currentUserId; // This is the line that was missing
  StudentNotification? _selectedNotification;
  bool _showNotificationDetails = false;
  OverlayEntry? _notificationOverlayEntry;
  final GlobalKey _bellIconKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      print('Loaded user ID from preferences: $userId');

      if (userId != null) {
        setState(() => _currentUserId = userId);
        await Provider.of<StudentNotificationProvider>(context, listen: false)
            .loadNotifications(userId);
      } else {
        print('No user ID found in SharedPreferences');
      }
    } catch (e) {
      print('Error loading user ID: $e');
    }
  }

  Future<void> _launchGoogleMaps() async {
    const String googleMapsUrl =
        'https://www.google.com/maps/place/University+Of+Nueva+Caceres/@13.6245313,123.1825038,16.95z/data=!4m6!3m5!1s0x33a18cb17fc9a129:0x3bc323a37f0bd148!8m2!3d13.6245666!4d123.182528!16zL20vMGZ6eDlj?hl=en&entry=ttu&g_ep=EgoyMDI0MTEyNC4xIKXMDSoASAFQAw%3D%3D';
    final Uri url = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUrl = Uri.parse('mailto:$email');
    if (await canLaunchUrl(emailUrl)) {
      await launchUrl(emailUrl);
    } else {
      throw 'Could not launch email client';
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _showNotificationPopup(BuildContext context) {
    final overlay = Overlay.of(context);
    final renderBox =
        _bellIconKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      print('Could not find bell icon render box');
      return;
    }

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    print('Showing notification popup at position: $position');

    _notificationOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy + size.height + 8,
        right: MediaQuery.of(context).size.width - position.dx - size.width,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 320,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: _buildNotificationContent(),
          ),
        ),
      ),
    );

    overlay.insert(_notificationOverlayEntry!);
  }

  void _hideNotificationPopup() {
    _notificationOverlayEntry?.remove();
    _notificationOverlayEntry = null;
    setState(() {
      _showNotificationDetails = false;
    });
  }

  Widget _buildNotificationContent() {
    final notificationProvider =
        Provider.of<StudentNotificationProvider>(context, listen: true);

    return _showNotificationDetails && _selectedNotification != null
        ? _buildNotificationDetailsView(_selectedNotification!)
        : _buildNotificationListView(notificationProvider);
  }

  Widget _buildNotificationListView(StudentNotificationProvider provider) {
    print(
        'Building notification list with ${provider.notifications.length} items');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notifications (${provider.unreadCount})',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              if (provider.unreadCount > 0)
                TextButton(
                  onPressed: () => provider.markAllAsRead(),
                  child: Text(
                    'Mark all as read',
                    style: GoogleFonts.inter(
                      color: Color(0xFFEC1D25),
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        Expanded(
          child: provider.notifications.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No notifications found',
                      style: GoogleFonts.inter(color: Colors.grey),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = provider.notifications[index];
                    print(
                        'Building notification item $index: ${notification.message}');
                    return _buildNotificationItem(
                      icon: _getNotificationIcon(notification.notificationType),
                      title: notification.displayType,
                      message: notification.message ?? 'No message',
                      time: _formatTime(notification.createdAt),
                      isUnread: notification.isUnread,
                      notification: notification,
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: TextButton(
            onPressed: () {
              // TODO: Navigate to full notifications page
            },
            child: Text(
              'View all notifications',
              style: GoogleFonts.inter(
                color: Color(0xFFEC1D25),
                fontSize: 14,
              ),
            ),
          ),
        )
      ],
    );
  }

  // In your HeaderWidget class
  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
    required StudentNotification notification,
  }) {
    return InkWell(
      onTap: () {
        final provider = context.read<StudentNotificationProvider>();

        // Mark as read if it's unread
        if (notification.isUnread) {
          provider.markAsRead(notification.id);
        }

        setState(() {
          _selectedNotification = notification;
          _showNotificationDetails = true;
        });

        _notificationOverlayEntry?.markNeedsBuild();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isUnread
              ? Color(0xFFEC1D25).withOpacity(0.05)
              : Colors.transparent,
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFFEC1D25).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Color(0xFFEC1D25), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(0xFFEC1D25),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationDetailsView(StudentNotification notification) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [Color(0xFFEC1D25), Color(0xFFC2185B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notification Details',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _showNotificationDetails = false;
                    });
                    _notificationOverlayEntry?.markNeedsBuild();
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(0xFFEC1D25).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getNotificationIcon(notification.notificationType),
                          color: Color(0xFFEC1D25),
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.displayType,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              DateFormat('MMM d, y hh:mm a')
                                  .format(notification.createdAt),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(height: 1, thickness: 1),
                  SizedBox(height: 16),
                  if (notification.message != null)
                    Text(
                      notification.message!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  SizedBox(height: 16),
                  if (notification.dateRequested != null)
                    Text(
                      'Scheduled for: ${DateFormat('MMM d, y').format(notification.dateRequested!)} '
                      'at ${notification.timeRequested ?? ''}',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'Accepted Appointment':
        return Icons.check_circle_outline;
      case 'Declined Appointment':
        return Icons.cancel_outlined;
      case 'Completed Appointment':
        return Icons.done_all;
      case 'Cancelled Appointment':
        return Icons.event_busy;
      case 'Accepted Reschedule Request':
        return Icons.schedule;
      case 'Declined Reschedule Request':
        return Icons.schedule_send;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1)
      return '${difference.inMinutes} mins ago';
    else if (difference.inDays < 1)
      return '${difference.inHours} hours ago';
    else if (difference.inDays < 7)
      return '${difference.inDays} days ago';
    else
      return DateFormat('MMM d, y').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<StudentNotificationProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('logo.png'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UNC',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Career',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color:
                                      const Color.fromARGB(255, 114, 114, 114),
                                ),
                              ),
                              const SizedBox(width: 0),
                              Text(
                                'Pathlink',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: const Color(0xFFEC1D25),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        if (_notificationOverlayEntry == null) {
                          _showNotificationPopup(context);
                        } else {
                          _hideNotificationPopup();
                        }
                      },
                      child: Container(
                        key: _bellIconKey,
                        padding: EdgeInsets.all(8),
                        child: Badge(
                          label: Text('${notificationProvider.unreadCount}',
                              style: TextStyle(color: Colors.white)),
                          isLabelVisible: notificationProvider.unreadCount > 0,
                          backgroundColor: Color(0xFFEC1D25),
                          child: Icon(Icons.notifications_active_outlined,
                              size: 26, color: Color(0xFFEC1D25)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: PopupMenuButton<int>(
                      padding: EdgeInsets.zero,
                      offset: const Offset(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFEC1D25), width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: const DecorationImage(
                                  image: AssetImage('student_profile.jpg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child:
                                  Container(padding: const EdgeInsets.all(4)),
                            ),
                          ],
                        ),
                      ),
                      onSelected: (value) {
                        if (value == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const StudentProfileScreen()),
                          );
                        } else if (value == 4) {
                          _logout(context);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              Icon(Icons.person_outline,
                                  color: Colors.grey.shade700),
                              const SizedBox(width: 12),
                              Text("My Profile",
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 4,
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.red.shade400),
                              const SizedBox(width: 12),
                              Text("Logout",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red.shade400,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GestureDetector(
                  onTap: _launchGoogleMaps,
                  child: _buildContactInfo(
                      icon: Icons.location_on,
                      text: 'J. Hernandez Ave, Naga City 4400'),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _launchEmail('info@unc.edu.ph'),
                  child: _buildContactInfo(
                      icon: Icons.email, text: 'info@unc.edu.ph'),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () =>
                      _copyToClipboard(context, '(054) 472-1862 loc. 130'),
                  child: _buildContactInfo(
                      icon: Icons.phone, text: '(054) 472-1862 loc. 130'),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _copyToClipboard(context, '0907-156-6898'),
                  child: _buildContactInfo(
                      icon: Icons.phone, text: '0907-156-6898'),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _copyToClipboard(context, '22565-1-862'),
                  child:
                      _buildContactInfo(icon: Icons.sms, text: '22565-1-862'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFEC1D25), size: 24),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _notificationOverlayEntry?.remove();
    super.dispose();
  }
}
