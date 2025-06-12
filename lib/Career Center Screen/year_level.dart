import 'package:final_career_coaching/services/career_center_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_career_coaching/model/vw_year_level_engagement_model.dart';

class YearLevel extends StatefulWidget {
  final double screenWidth;

  const YearLevel({Key? key, required this.screenWidth}) : super(key: key);

  @override
  _YearLevelState createState() => _YearLevelState();
}

class _YearLevelState extends State<YearLevel> {
  late Future<List<YearLevelEngagement>> _engagementFuture;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadEngagementData();
  }

  Future<void> _loadEngagementData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      _engagementFuture = EngagementService.getAllYearLevelEngagement();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data: ${e.toString()}';
      });
    }
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
            offset: Offset(0, 5),
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
                  'Year Level Engagement',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                    letterSpacing: 0.5,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Color(0xFF2C3E50)),
                  onPressed: _loadEngagementData,
                  tooltip: 'Refresh data',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Student participation across different academic levels',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricsHeader(),
            const SizedBox(height: 12),
            Expanded(
              child: _buildYearLevelContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearLevelContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C3E50)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading engagement data...',
              style: GoogleFonts.inter(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 40),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEngagementData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2C3E50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<YearLevelEngagement>>(
      future: _engagementFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 40),
                SizedBox(height: 16),
                Text(
                  'Error loading data',
                  style: GoogleFonts.inter(color: Colors.grey[700]),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadEngagementData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2C3E50),
                  ),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        final engagementData = snapshot.data ?? [];
        final allYearLevels = [
          '1st Year',
          '2nd Year',
          '3rd Year',
          '4th Year',
          '5th Year'
        ];

        return SingleChildScrollView(
          child: Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: engagementData.length,
                separatorBuilder: (context, index) => Divider(
                  height: 24,
                  thickness: 0.5,
                  color: Colors.grey[300],
                  indent: 12,
                  endIndent: 12,
                ),
                itemBuilder: (context, index) {
                  final data = engagementData[index];
                  final yearLevel = data.yearLevel;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Ranking badge
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _getColorForYearLevel(yearLevel),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${index + 1}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              yearLevel,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            Spacer(),
                            Text(
                              '${data.totalStudents} students',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Stack(
                          children: [
                            Container(
                              height: 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey[200],
                              ),
                            ),
                            Container(
                              height: 10,
                              width: data.studentDistribution * 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                gradient: LinearGradient(
                                  colors: [
                                    _getColorForYearLevel(yearLevel),
                                    _getColorForYearLevel(yearLevel)
                                        .withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: Text(
                                '${data.studentDistribution.toStringAsFixed(1)}%',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 4,
                          childAspectRatio: 1.5,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          children: [
                            _buildMetricItem(
                                data.activeStudents.toString(), Colors.green),
                            _buildMetricItem(
                                data.totalAppointments.toString(), Colors.blue),
                            _buildMetricItem(
                                data.completedAppointments.toString(),
                                Colors.purple),
                            _buildMetricItem(
                                '${data.engagementRate.toStringAsFixed(1)}%',
                                Colors.orange),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Show any missing year levels that had no data
              ...allYearLevels
                  .where((level) =>
                      !engagementData.any((e) => e.yearLevel == level))
                  .map((yearLevel) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _getColorForYearLevel(yearLevel)
                                    .withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  yearLevel[0],
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getColorForYearLevel(yearLevel),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              yearLevel,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50).withOpacity(0.5),
                              ),
                            ),
                            Spacer(),
                            Text(
                              'No data',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      )),
            ],
          ),
        );
      },
    );
  }

  // Rest of the helper methods remain exactly the same...
  Widget _buildMetricsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xFF2C3E50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMetricHeaderItem(Icons.people_alt_outlined, 'Active'),
          _buildMetricHeaderItem(Icons.calendar_today_outlined, 'Total'),
          _buildMetricHeaderItem(Icons.check_circle_outline, 'Completed'),
          _buildMetricHeaderItem(Icons.trending_up, 'Engagement'),
        ],
      ),
    );
  }

  Widget _buildMetricHeaderItem(IconData icon, String title) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Color(0xFF2C3E50)),
        SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Color _getColorForYearLevel(String yearLevel) {
    const colors = [
      Color(0xFFEC1D25), // Red
      Color(0xFF2A9D8F), // Teal
      Color(0xFFE9C46A), // Yellow
      Color(0xFFF4A261), // Orange
      Color(0xFF264653), // Dark blue
    ];

    final levels = ['1st Year', '2nd Year', '3rd Year', '4th Year', '5th Year'];
    final index = levels.indexOf(yearLevel) % colors.length;
    return index >= 0 ? colors[index] : colors[0];
  }
}
