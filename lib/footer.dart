import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $email';
    }
  }

  Future<void> _launchFacebook() async {
    const String facebookUrl =
        'https://www.facebook.com/UniversityOfNuevaCaceres/';
    final Uri url = Uri.parse(facebookUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch Facebook';
    }
  }

  Future<void> _launchYouTube() async {
    const String youtubeUrl =
        'https://www.youtube.com/@UniversityofNuevaCaceres';
    final Uri url = Uri.parse(youtubeUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch YouTube';
    }
  }

  Future<void> _launchX() async {
    const String xUrl = 'https://x.com/uncgreyhounds';
    final Uri url = Uri.parse(xUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch X (Twitter)';
    }
  }

  Future<void> _launchInstagram() async {
    const String instagramUrl = 'https://www.instagram.com/uncgreyhounds/';
    final Uri url = Uri.parse(instagramUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch Instagram';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          color: const Color(0xFF413E3E),
          padding: const EdgeInsets.only(
            top: 30,
            left: 20,
            right: 20,
            bottom: 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('logo.png', width: 80, height: 80),
                  const SizedBox(width: 15),
                  Text(
                    "UNIVERSITY OF\nNUEVA CACERES",
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "J. Hernandez Ave, Naga City 4400",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "09561301775 | 09071566898",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "22565-1-862 (UNC)",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => _launchEmail("info@unc.edu.ph"),
                              child: Text(
                                "info@unc.edu.ph",
                                style: TextStyle(
                                  color: const Color(0xFFEC1D25),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(
                            text: " | ",
                            style: TextStyle(color: Colors.white),
                          ),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => _launchEmail("admission@unc.edu.ph"),
                              child: Text(
                                "admission@unc.edu.ph",
                                style: TextStyle(
                                  color: const Color(0xFFEC1D25),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _launchFacebook,
                          child: const FaIcon(
                            FontAwesomeIcons.facebook,
                            color: Color.fromARGB(255, 59, 89, 152),
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: _launchYouTube,
                          child: const FaIcon(
                            FontAwesomeIcons.youtube,
                            color: Color.fromARGB(255, 255, 0, 0),
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: _launchX,
                          child: const FaIcon(
                            FontAwesomeIcons.xTwitter,
                            color: Color.fromARGB(255, 0, 0, 0),
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: _launchInstagram,
                          child: const FaIcon(
                            FontAwesomeIcons.instagram,
                            color: Color.fromARGB(255, 193, 53, 132),
                            size: 30,
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
        Container(
          width: double.infinity,
          color: const Color(0xFF808080),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              "Copyright",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
