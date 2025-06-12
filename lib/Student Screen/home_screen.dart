import 'package:final_career_coaching/Student%20Screen/terms_conditions_screen.dart';
import 'package:final_career_coaching/footer.dart';
import 'package:final_career_coaching/Student%20Screen/student_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _expandedIndex; // Track which card is expanded

  void _toggleExpand(int index) {
    setState(() {
      // If the clicked card is already expanded, collapse it; otherwise, expand it
      _expandedIndex = (_expandedIndex == index) ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final screenHeight = MediaQuery.of(context).size.height;
    const headerHeight = 150.0;

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: headerHeight),
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Image.asset('homepage.png', fit: BoxFit.cover),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'CAREER CENTER SERVICES',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: Text(
                        'STAY CONNECTED BEYOND GRADUATION',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEC1D25),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: Text(
                        'Since 2014, the Career Services and Placement Office has been committed to supporting UNC students in shaping and achieving their career aspirations. Beyond academic courses, our programs are designed to equip students with the essential skills and competencies needed for a fulfilling and successful career.\n\n'
                        'Our office is staffed with dedicated counselors who assist students in identifying a suitable career path, regardless of whether they already have a specific occupation in mind or are unsure about their direction. By utilizing self-assessment tools and various career exploration methods, we evaluate students\' values, skills, interests, and personalities. Based on these insights, our counselors either recommend potential career options or work closely with students to determine if their desired career choices align with their strengths and aspirations. Additionally, our counselors help students select majors and courses that align with their professional objectives.\n\n'
                        'We also organize events and workshops on topics such as career exploration, resume building, job interview techniques, and other activities designed to enhance students\' skills and refine their career strategies. These opportunities provide practical experience and guidance, empowering students to confidently navigate their professional journeys.\n\n'
                        'The Career Center offers a range of flagship programs and services aimed at enhancing graduate employability. These include the Government-Industry Academe Programs, initiatives focused on Student Employment Readiness, Research and Development projects, and many others. For more details about these programs and how they can benefit you, feel free to contact us using the information provided below.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AppointmentBookingScreen(), // Navigate to AppointmentBookingScreen
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        color: Color(0xFFEC1D25),
                        margin: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 20,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        height: 60,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Student Success: Experience the "Alagang UNC"! 👉 Book an Appointment Today!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 600;
                          final cardWidth =
                              (isMobile ? constraints.maxWidth : 300)
                                  .toDouble();

                          return isMobile
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: _buildImageCards(cardWidth),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _buildImageCards(cardWidth),
                                );
                        },
                      ),
                    ),
                    const Footer(),
                  ],
                ),
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
              child: const HeaderWidget(), // Your header
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildImageCards(double cardWidth) {
    return [
      _buildImageCard(
        0,
        'career_coaching.png',
        'Career Coaching',
        'Career Coaching pairs you with experienced alumni who will guide you through career planning and goal-setting. Get the clarity and confidence you need to succeed in your dream career.',
        cardWidth,
      ),
      _buildImageCard(
        1,
        'mock_interview.webp',
        'Mock Interview',
        'Practice with professionals who provide real-time feedback and tips. Gain the confidence to handle any interview and stand out to employers.',
        cardWidth,
      ),
      _buildImageCard(
        2,
        'cv_review.png',
        'CV Review',
        'Submit your resume for expert review and get personalized advice on how to make it impactful. A great CV opens doors—let us help you perfect yours!',
        cardWidth,
      ),
      _buildImageCard(
        3,
        'mentoring_.png',
        'Mentoring',
        'Mentoring connects you with alumni who’ve been where you are. Get career advice and support to make your professional journey a success.',
        cardWidth,
      ),
    ];
  }

  Widget _buildImageCard(
    int index,
    String imagePath,
    String title,
    String description,
    double cardWidth,
  ) {
    final isExpanded = _expandedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15, right: 10),
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                imagePath,
                width: cardWidth,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      size: 24,
                    ),
                    onPressed: () => _toggleExpand(index),
                  ),
                ],
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    // Align(
                    //   alignment: Alignment.centerRight,
                    //   child: TextButton(
                    //     onPressed: () {
                    //       if (index == 2) {
                    //         // Navigate to Upload CV screen when "Submit CV" is clicked
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (context) => UploadCVScreen(),
                    //           ),
                    //         );
                    //       } else {
                    //         // Navigate to Select Coach
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (context) => SelectCoachScreen(),
                    //           ),
                    //         );
                    //       }
                    //     },
                    //     child: Text(
                    //       index == 2 ? "Submit CV" : "Book Now",
                    //       style: GoogleFonts.inter(
                    //         fontSize: 14,
                    //         fontWeight: FontWeight.bold,
                    //         color: Colors.red,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
