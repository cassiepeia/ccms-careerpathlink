import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_career_coaching/model/service_analytics_model.dart';
import 'package:final_career_coaching/services/career_center_services.dart';

class Service extends StatefulWidget {
  final double screenWidth;

  const Service({Key? key, required this.screenWidth}) : super(key: key);

  @override
  _ServiceState createState() => _ServiceState();
}

class _ServiceState extends State<Service> {
  late Future<List<ServiceAnalytics>> _serviceAnalytics;
  final Color gridLineColor = Colors.grey.withOpacity(0.3);
  
  final List<Color> barColors = [
    const Color(0xFFEC1D25),
    const Color(0xFF2A9D8F),
    const Color(0xFFE9C46A),
  ];

  final List<String> allServiceTypes = [
    'Career Coaching',
    'Mock Interview',
    'CV Review'
  ];

  @override
  void initState() {
    super.initState();
    _serviceAnalytics = EngagementService.getServiceAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 400,
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Service Details',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Completion %',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<ServiceAnalytics>>(
                future: _serviceAnalytics,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading analytics'));
                  }
                  
                  final analytics = snapshot.data ?? [];
                  
                  return _buildHistogramContent(analytics);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistogramContent(List<ServiceAnalytics> analytics) {
    // Sort analytics to maintain consistent order
    analytics.sort((a, b) => allServiceTypes.indexOf(a.serviceType)
        .compareTo(allServiceTypes.indexOf(b.serviceType)));

    // Calculate max percentage for scaling
    final maxPercentage = analytics.isNotEmpty 
        ? (analytics.map((a) => a.completionRate).reduce((a, b) => a > b ? a : b) / 10).ceil() * 10
        : 20;
    final gridLineCount = (maxPercentage / 20).ceil() + 1;

    return Stack(
      children: [
        // Grid lines
        Column(
          children: List.generate(gridLineCount, (index) {
            final percentage = maxPercentage - (index * 20);
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 8.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: gridLineColor,
                      width: 1.0,
                    ),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      '$percentage%',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        
        // Bars and labels
        Padding(
          padding: const EdgeInsets.only(left: 60.0),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: analytics.length,
                    itemBuilder: (context, index) {
                      final service = analytics[index];
                      final percentage = service.completionRate;
                      final barHeight = percentage * 2.0;
                      final barColor = barColors[index % barColors.length];

                      return Tooltip(
                        message: '${service.serviceType}\n'
                                'Total: ${service.totalAppointments}\n'
                                'Completed: ${service.completedAppointments}\n'
                                'Cancelled: ${service.cancelledAppointments}\n'
                                'Pending: ${service.pendingAppointments}',
                        child: Container(
                          width: 70,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  '${percentage.toInt()}%',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                height: barHeight > 0 ? barHeight : 2,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: barColor.withOpacity(service.totalAppointments > 0 ? 1.0 : 0.5),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Service labels
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(analytics.length, (index) {
                      final service = analytics[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        constraints: BoxConstraints(
                          maxWidth: widget.screenWidth * 0.25,
                        ),
                        child: Tooltip(
                          message: '${service.serviceType}\n'
                                  'Total: ${service.totalAppointments}',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: barColors[index % barColors.length]
                                      .withOpacity(service.totalAppointments > 0 ? 1.0 : 0.5),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  service.serviceType,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: service.totalAppointments > 0 ? Colors.black : Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}