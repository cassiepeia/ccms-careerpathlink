import 'package:final_career_coaching/model/course_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

class CourseEngagementScreen extends StatefulWidget {
  const CourseEngagementScreen({Key? key}) : super(key: key);

  @override
  _CourseEngagementScreenState createState() => _CourseEngagementScreenState();
}

class _CourseEngagementScreenState extends State<CourseEngagementScreen> {
  List<CourseEngagement> _courses = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final List<String> _allSystemCourses = [
    'Bachelor of Arts in Psychology',
    'Bachelor of Arts in Political Science',
    'Bachelor of Science in Biology',
    'Bachelor of Science in Civil Engineering',
    'Bachelor of Science in Interior Design',
    'Bachelor of Science in Architecture',
    'Expanded Tertiary Education Equivalent & Accreditation',
    'Bachelor of Science in Accountancy',
    'Bachelor of Science in Tourism Management',
    'Bachelor of Science in Librarian & Information Science',
    'Bachelor of Science in Computer Science',
    'Bachelor of Science in Information Technology',
    'Juris Doctor',
    'Bachelor of Elementary Education',
    'Bachelor of Secondary Education',
    'Bachelor of Physical Education',
    'Bachelor of Science in Criminology',
    'Bachelor of Science in Forensic Science',
    'Bachelor of Science in Nursing',
  ];

  @override
  void initState() {
    super.initState();
    _fetchCourseData();
  }

  Future<void> _fetchCourseData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(
          'http://localhost/final_career_coaching/api/course/view_course.php'));

      developer.log('API Response: ${response.body}', name: 'CourseEngagement');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final coursesWithData = (data['data'] as List?)
                  ?.map((json) => CourseEngagement.fromJson(json))
                  .toList() ??
              [];

          final mergedCourses = _allSystemCourses.map((courseName) {
            final existingData = coursesWithData.firstWhere(
              (course) =>
                  course.course.trim().toLowerCase() ==
                  courseName.trim().toLowerCase(),
              orElse: () => CourseEngagement(
                course: courseName,
                totalStudents: 0,
                activeStudents: 0,
                totalAppointments: 0,
                completedAppointments: 0,
                cancelledAppointments: 0,
                pendingAppointments: 0,
                engagementRate: 0,
                completionRate: 0,
              ),
            );
            return existingData;
          }).toList();

          setState(() {
            _courses = mergedCourses;
            _isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to load engagement data');
        }
      } else {
        throw Exception('API returned status code ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error: $e', name: 'CourseEngagement', error: e);
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
        _courses = _allSystemCourses
            .map((courseName) => CourseEngagement(
                  course: courseName,
                  totalStudents: 0,
                  activeStudents: 0,
                  totalAppointments: 0,
                  completedAppointments: 0,
                  cancelledAppointments: 0,
                  pendingAppointments: 0,
                  engagementRate: 0,
                  completionRate: 0,
                ))
            .toList();
        _isLoading = false;
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
        color: Color(0xFFF7FAFC), // Changed to match Department container
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Course Engagement',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Engagement %',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Track student engagement across all courses',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 20),
          if (_errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline,
                        size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: GoogleFonts.inter(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF2C3E50)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading engagement data...',
                          style: GoogleFonts.inter(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _courses.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final course = _courses[index];
                      return CourseCard(
                        course: course,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final CourseEngagement course;

  const CourseCard({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasData = course.totalStudents > 0 ||
        course.activeStudents > 0 ||
        course.completedAppointments > 0;
    final engagementColor = hasData
        ? _getEngagementColor(course.engagementRate)
        : Colors.grey[400]!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  course.course,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: hasData ? Colors.black87 : Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: engagementColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: engagementColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  "${course.engagementRate.toInt()}%",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: engagementColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutQuart,
                    height: 8,
                    width: constraints.maxWidth * (course.engagementRate / 100),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          engagementColor.withOpacity(0.9),
                          engagementColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                icon: Icons.people_alt_outlined,
                value: "${course.activeStudents}/${course.totalStudents}",
                label: "Students",
                hasData: hasData,
              ),
              _buildStatItem(
                icon: Icons.event_available_outlined,
                value: course.completedAppointments.toString(),
                label: "Sessions",
                hasData: hasData,
              ),
              _buildStatItem(
                icon: Icons.assessment_outlined,
                value: "${course.completionRate.toInt()}%",
                label: "Completion",
                hasData: hasData,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required bool hasData,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: hasData ? Color(0xFF2C3E50) : Colors.black26,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: hasData ? Colors.black87 : Colors.black38,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: hasData ? Colors.black54 : Colors.black26,
          ),
        ),
      ],
    );
  }

  Color _getEngagementColor(double rate) {
    if (rate < 30)
      return const Color.fromARGB(
          255, 217, 24, 24); // Lighter red;  // Dark Red
    if (rate < 60) return Color(0xFFB22222); // Firebrick
    if (rate < 80) return const Color.fromARGB(255, 217, 24, 24); // Lighter red
    return const Color.fromARGB(255, 217, 24, 24); // Lighter red;  // Crimson
  }
}
