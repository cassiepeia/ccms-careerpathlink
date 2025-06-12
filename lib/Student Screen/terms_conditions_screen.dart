import 'package:final_career_coaching/Student%20Screen/select_coach_screen.dart';
import 'package:final_career_coaching/footer.dart';
import 'package:final_career_coaching/Student%20Screen/student_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  _AppointmentBookingScreenState createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  bool isChecked = false;

  void _toggleCheckbox(bool? value) {
    setState(() {
      isChecked = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Detect if the platform is mobile or web
    bool isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Column(
        children: [
          // Header with shadow
          Material(
            elevation: 4.0,
            shadowColor: Colors.black.withOpacity(0.3),
            child: const HeaderWidget(),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "APPOINTMENT",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFFEC1D25),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "BOOKING",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 80,
                            top: 20,
                            right: 20,
                          ),
                          child: Text(
                            "Welcome to the UNC Career Coaching Platform. Review all fields in the online form carefully and provide complete and accurate information.",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 80,
                            top: 20,
                            right: 20,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 5,
                                height: 60,
                                color: Color(0xFFEC1D25),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Reminder:",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFEC1D25),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "Please ensure you have a valid UNC email address to access the platform. The platform is designed for seamless integration with various devices and browsers.",
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
                            child: Text(
                              "Terms and Condition",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          child: Text(
                            "This appointment and scheduling system allocates slots on a first come, first served basis. Users are responsible for supplying, checking, and verifying the accuracy of the information they provide. Incorrect information may result in session cancellation.",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: isChecked,
                                onChanged: _toggleCheckbox,
                                activeColor: Color(0xFFEC1D25),
                              ),
                              Expanded(
                                child: Text(
                                  "By proceeding with this application, you understand that you are signifying your consent to the collection and use of your personal information for the purpose of facilitating services.",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFFEC1D25),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // "Start Schedule an Appointment" button wrapped in GestureDetector
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: GestureDetector(
                            onTap: isChecked
                                ? () {
                                    // Navigate to SelectCoachScreen when tapped
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SelectCoachScreen(),
                                      ),
                                    );
                                  }
                                : null, // Disable tap if checkbox is unchecked
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isChecked
                                    ? Color(0xFFEC1D25) // Active color
                                    : Colors.grey, // Inactive color
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Center(
                                child: Text(
                                  "Start Schedule an Appointment",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // The new text aligned differently based on screen size
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 15,
                          ), // Some space above the text
                          child: Align(
                            alignment: isWeb
                                ? Alignment.center // Center text for web
                                : Alignment
                                    .centerLeft, // Left-align text for mobile
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ), // Added horizontal padding for alignment
                              child: Text(
                                "After agreeing to the Terms and Conditions above, you may start your online application by clicking “Start Appointment”",
                                style: GoogleFonts.beVietnamPro(
                                  fontWeight: FontWeight.w300, // Light weight
                                  fontSize: 14, // Adjust size if needed
                                  color: Color(0xFF6C6868), // The desired color
                                ),
                                textAlign: isWeb
                                    ? TextAlign.center // Center the text on web
                                    : TextAlign.left, // Align left on mobile
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Footer at the bottom of the page
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
