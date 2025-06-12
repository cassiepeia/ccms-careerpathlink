import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Department extends StatefulWidget {
  final double screenWidth;

  const Department({Key? key, required this.screenWidth}) : super(key: key);

  @override
  _DepartmentState createState() => _DepartmentState();
}

class _DepartmentState extends State<Department> {
  List<Map<String, dynamic>> departments = [];
  bool isLoading = true;
  String errorMessage = '';

  final List<String> allDepartments = [
    'School of Social and Natural Sciences',
    'College of Engineering and Architecture',
    'School of Business and Accountancy',
    'School of Computer and Information Sciences',
    'School of Law',
    'School of Teacher Education',
    'College of Criminal Justice Education',
    'School of Nursing and Allied Health Sciences',
  ];

  final Color primaryColor = const Color(0xFFEC1D25);
  final Color secondaryColor = const Color(0xFF2D3748);
  final Color backgroundColor = const Color(0xFFF7FAFC);
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _fetchDepartmentData();
  }

  Future<void> _fetchDepartmentData() async {
    try {
      final url = Uri.parse(
          "http://localhost/final_career_coaching/api/department_insight/vw_department_engagement.php");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody['success'] == true) {
          final apiData = responseBody['data'];

          final processedData = allDepartments.map((deptName) {
            final deptData = apiData.firstWhere(
              (item) => item['department'] == deptName,
              orElse: () => null,
            );

            return {
              'department_name': deptName,
              'overall_percentage': deptData != null
                  ? (deptData['percentage_of_total']?.toDouble() ?? 0.0) / 100.0
                  : 0.0,
              'most_active_year': deptData?['most_active_year'] ?? 'N/A',
              'percentage_of_total':
                  deptData?['percentage_of_total']?.toDouble() ?? 0.0,
            };
          }).toList();

          setState(() {
            departments = processedData;
            isLoading = false;
          });
        } else {
          _showDefaultDepartments();
        }
      } else {
        _showDefaultDepartments();
      }
    } catch (e) {
      _showDefaultDepartments();
      print('Error fetching department data: $e');
    }
  }

  void _showDefaultDepartments() {
    setState(() {
      departments = allDepartments
          .map((deptName) => {
                'department_name': deptName,
                'overall_percentage': 0.0,
                'most_active_year': 'N/A', // Add this
                'percentage_of_total': 0.0, // Add this
              })
          .toList();
      isLoading = false;
      errorMessage = 'Failed to load latest data. Showing department list.';
    });
  }

  double _parsePercentage(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value / 100.0;
    if (value is int) return value.toDouble() / 100.0;

    String strValue = value.toString();
    strValue = strValue.replaceAll('%', '').trim();
    if (strValue.isEmpty) return 0.0;

    try {
      return double.parse(strValue) / 100.0;
    } catch (e) {
      print('Error parsing percentage value: $value');
      return 0.0;
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
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading department data...',
                          style: GoogleFonts.inter(
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        if (errorMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.amber[800]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: GoogleFonts.inter(
                                      color: Colors.amber[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ..._buildDepartmentList(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Department Engagement',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Overview of student engagement across departments',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDepartmentList() {
    return departments.map((department) {
      return _buildDepartmentCard(
        title: department['department_name'],
        progress: department['overall_percentage'],
        percentageOfTotal: department['percentage_of_total'] ?? 0.0, // Add this
      );
    }).toList();
  }

  Widget _buildDepartmentCard({
    required String title,
    required double progress,
    required double percentageOfTotal,
  }) {
    // Ensure progress is between 0.0 and 1.0
    final normalizedProgress = progress.clamp(0.0, 1.0);
    final totalPercentageText = "${percentageOfTotal.toStringAsFixed(1)}%";
    final icon = _getDepartmentIcon(title);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: primaryColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: secondaryColor,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    totalPercentageText,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: normalizedProgress,
              backgroundColor: Colors.grey[200],
              color: _getProgressColor(percentageOfTotal),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              'Engagement Rate',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDepartmentIcon(String departmentName) {
    if (departmentName.contains('Engineering')) return Icons.engineering;
    if (departmentName.contains('Business')) return Icons.business;
    if (departmentName.contains('Computer')) return Icons.computer;
    if (departmentName.contains('Law')) return Icons.gavel;
    if (departmentName.contains('Teacher')) return Icons.school;
    if (departmentName.contains('Criminal Justice')) return Icons.security;
    if (departmentName.contains('Nursing')) return Icons.medical_services;
    return Icons.science;
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 75) return const Color(0xFFD50000); // Darker red
    if (percentage >= 50) return const Color(0xFFEC1D25); // Your primary red
    if (percentage >= 25)
      return const Color.fromARGB(255, 217, 24, 24); // Lighter red
    return const Color.fromARGB(255, 217, 24, 24); // Very light red
  }
}
