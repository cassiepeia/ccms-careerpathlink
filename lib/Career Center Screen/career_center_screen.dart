// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_career_coaching/Career%20Center%20Screen/cc_header.dart';
import 'package:final_career_coaching/Career%20Center%20Screen/service.dart';
import 'package:final_career_coaching/Career%20Center%20Screen/student_insight.dart';
import 'package:final_career_coaching/Career%20Center%20Screen/year_level.dart';
import 'package:final_career_coaching/Career%20Center%20Screen/department.dart';
import 'package:final_career_coaching/Career%20Center%20Screen/course.dart';
import 'package:final_career_coaching/footer.dart';

class CareerCenterScreen extends StatefulWidget {
  const CareerCenterScreen({Key? key}) : super(key: key);

  @override
  _CareerCenterScreen createState() => _CareerCenterScreen();
}

class _CareerCenterScreen extends State<CareerCenterScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWideScreen = screenWidth > 800;

    return Scaffold(
      body: Column(
        children: [
          // Fixed Header
          const Material(
            elevation: 4.0,
            color: Colors.white,
            child: CareerCenterHeader(),
          ),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Combined Row for Year Level, Service Details, and Student Insight
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth > 600 ? 50 : 20,
                    ),
                    child: isWideScreen 
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Year Level Section
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    YearLevel(screenWidth: screenWidth),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              
                              // Service Details Section
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Service(screenWidth: screenWidth),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              
                              // Student Insight Section
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    StudentInsight(screenWidth: screenWidth),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              // Year Level Section (stacked on mobile)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Year Level',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  YearLevel(screenWidth: screenWidth),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              // Service Details Section
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Service Details',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Service(screenWidth: screenWidth),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              // Student Insight Section
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Student Insight',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  StudentInsight(screenWidth: screenWidth),
                                ],
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 20),

                  // Department and Course Engagement Sections
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth > 600 ? 50 : 20,
                    ),
                    child: isWideScreen
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title Row
                              Row(
                                children: [
                                  // Department Title
                                  SizedBox(
                                    width: (screenWidth - 100) * 0.5 - 10,
                                    
                                  ),
                                  
                                  // Course Engagement Title
                                  SizedBox(
                                    width: (screenWidth - 100) * 0.5 - 10,
                                    
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              
                              // Content Row with equal height containers
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Department Section
                                  SizedBox(
                                    width: (screenWidth - 100) * 0.5 - 10,
                                    height: 550, // Fixed matching height
                                    child: Department(screenWidth: (screenWidth - 100) * 0.5 - 10),
                                  ),
                                  
                                  const SizedBox(width: 20),
                                  
                                  // Course Engagement Section
                                  SizedBox(
                                    width: (screenWidth - 100) * 0.5 - 10,
                                    height: 550, // Fixed matching height
                                    child: CourseEngagementScreen(),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Department Section (stacked on mobile)
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 550, // Same fixed height
                                child: Department(screenWidth: screenWidth),
                              ),
                              const SizedBox(height: 20),
                              
                              // Course Engagement Section
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 550, // Same fixed height
                                child: CourseEngagementScreen(),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Footer
                  const Footer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}