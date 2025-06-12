import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:final_career_coaching/Student%20Screen/student_header.dart';
import 'package:final_career_coaching/model/select_coach_model.dart';
import 'package:final_career_coaching/model/time_slot.dart';
import 'package:final_career_coaching/services/api_services.dart';
import 'calendar.dart';

class SelectCoachScreen extends StatefulWidget {
  const SelectCoachScreen({Key? key}) : super(key: key);

  @override
  _SelectCoachScreenState createState() => _SelectCoachScreenState();
}

class _SelectCoachScreenState extends State<SelectCoachScreen> {
  List<Coach> _coaches = [];
  List<Coach> _filteredCoaches = [];
  bool _isLoading = true;
  String _selectedProgram = 'Choose Program';
  TextEditingController searchController = TextEditingController();

  final List<String> _availablePrograms = [
    'Choose Program',
    'Career Coaching',
    'Mock Interview',
    'CV Review',
  ];

  @override
  void initState() {
    super.initState();
    loadCoaches();
    searchController.addListener(_onSearchChanged);
  }

  Future<void> loadCoaches() async {
    try {
      List<Coach> fetchedCoaches = await ApiService.fetchCoaches();
      setState(() {
        _coaches = fetchedCoaches;
        _filteredCoaches = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showError('Error fetching coaches: $e');
    }
  }

  void _onSearchChanged() {
    _filterCoaches();
  }

  void _filterCoaches() {
    setState(() {
      if (_selectedProgram == 'Choose Program') {
        _filteredCoaches = [];
      } else {
        _filteredCoaches = _coaches.where((coach) {
          final matchesSearch = coach.coachName
              .toLowerCase()
              .contains(searchController.text.toLowerCase());
          return matchesSearch;
        }).toList();
      }
    });
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildCoachAvatar(String name, double radius) {
    final initials = name.isEmpty
        ? '?'
        : name.split(' ').length > 1
            ? '${name.split(' ')[0][0]}${name.split(' ').last[0]}'.toUpperCase()
            : name[0].toUpperCase();

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blue.shade800,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.6,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with shadow (copied from example)
          Material(
            elevation: 4.0,
            shadowColor: Colors.black.withOpacity(0.3),
            child: const HeaderWidget(),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                Flexible(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedProgram,
                        icon: const Icon(Icons.arrow_drop_down),
                        isExpanded: true,
                        hint: Text('Choose Program'),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedProgram = newValue!;
                            _filterCoaches();
                          });
                        },
                        items: _availablePrograms
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey[600], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search Workforce Development Trainer',
                              hintStyle: GoogleFonts.inter(
                                  color: Colors.grey[600], fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedProgram == 'Choose Program'
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 64,
                              color: Colors.blueGrey[300],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Select a Program',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey[800],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                'Please choose a program from the dropdown to view available Workforce Development Trainers',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.blueGrey[500],
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      )
                    : _filteredCoaches.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 64,
                                  color: Colors.blueGrey[300],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'No Trainers Found',
                                  style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueGrey[800],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  child: Text(
                                    'We couldn\'t find any Workforce Development Trainers matching your search',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: Colors.blueGrey[500],
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[700],
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      searchController.clear();
                                      _filterCoaches();
                                    });
                                  },
                                  child: Text(
                                    'Clear Search',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _filteredCoaches.length,
                            itemBuilder: (context, index) {
                              return _buildCoachTile(_filteredCoaches[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachTile(Coach coach) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Ensures vertical centering
          children: [
            CircleAvatar(
              radius: 38,
              backgroundImage: AssetImage('assets/1709211669228.jpg'),
            ),
            const SizedBox(width: 18.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centers content vertically
                children: [
                  Text(
                    coach.coachName,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6.0), // Reduced spacing
                  Text(
                    _selectedProgram,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 50.0), // Pushes button slightly down
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFEC1D25),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, // Reduced from 22
                    vertical: 10, // Reduced from 12
                  ),
                  minimumSize: Size(0, 0), // Allows button to shrink
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Slightly less rounded
                  ),
                ),
                onPressed: () => bookNow(coach.id, coach.coachName),
                child: Text(
                  'Book Now',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void bookNow(int coachId, String coachName) async {
    try {
      List<TimeSlot> coachSlots =
          await ApiService.fetchTimeSlotsByCoach(coachId);
      Map<String, List<TimeSlot>> groupedSlots = {};
      for (var slot in coachSlots) {
        groupedSlots.putIfAbsent(slot.dateSlot, () => []).add(slot);
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CalendarScreen(
            coachName: coachName,
            availableTimeSlots: groupedSlots,
            selectedService: _selectedProgram,
          ),
        ),
      );
    } catch (e) {
      showError("Error fetching time slots: $e");
    }
  }
}
