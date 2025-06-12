import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InformationScreen extends StatefulWidget {
  final String coachName;
  final String selectedDate;
  final String startTime;
  final String endTime;

  const InformationScreen({super.key, 
    required this.coachName,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
  });

  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _suffixController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _studentNoController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String _gender = 'Male';
  String _yearLevel = 'Freshman';
  String _department = 'Computer Science';
  String _program = 'Full-time';
  String _status = 'Active';

  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> yearLevelOptions = ['Freshman', 'Sophomore', 'Junior', 'Senior'];
  final List<String> departmentOptions = ['Computer Science', 'Information Technology', 'Engineering'];
  final List<String> programOptions = ['Full-time', 'Part-time'];
  final List<String> statusOptions = ['Active', 'Inactive'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fill Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking Information for Coach ${widget.coachName}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text('Selected Date: ${widget.selectedDate}', style: TextStyle(fontSize: 16)),
              Text('Time: ${widget.startTime} - ${widget.endTime}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              _buildTextField(_lastNameController, 'Last Name'),
              _buildTextField(_suffixController, 'Suffix (optional)', isOptional: true),
              _buildTextField(_firstNameController, 'First Name'),
              _buildTextField(_middleNameController, 'Middle Name'),
              _buildTextField(_emailController, 'Email'),
              _buildTextField(_phoneNoController, 'Phone Number'),
              _buildTextField(_studentNoController, 'Student Number'),
              _buildDateField(),
              _buildDropdownField('Gender', genderOptions, _gender, (value) {
                setState(() {
                  _gender = value!;
                });
              }),
              _buildDropdownField('Year Level', yearLevelOptions, _yearLevel, (value) {
                setState(() {
                  _yearLevel = value!;
                });
              }),
              _buildDropdownField('Department', departmentOptions, _department, (value) {
                setState(() {
                  _department = value!;
                });
              }),
              _buildDropdownField('Program', programOptions, _program, (value) {
                setState(() {
                  _program = value!;
                });
              }),
              _buildDropdownField('Status', statusOptions, _status, (value) {
                setState(() {
                  _status = value!;
                });
              }),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle form submission (e.g., store data, send request)
                  print('Form Data:');
                  print('Name: ${_firstNameController.text} ${_middleNameController.text} ${_lastNameController.text}');
                  print('Email: ${_emailController.text}');
                  print('Phone: ${_phoneNoController.text}');
                  print('Student No: ${_studentNoController.text}');
                  print('Date of Birth: ${_dobController.text}');
                  print('Gender: $_gender');
                  print('Year Level: $_yearLevel');
                  print('Department: $_department');
                  print('Program: $_program');
                  print('Status: $_status');
                  // You can add more actions like API calls to store the booking data
                  Navigator.pop(context); // Navigate back after form submission
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create text fields
  Widget _buildTextField(TextEditingController controller, String label, {bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: isOptional ? 'Optional' : '',
        ),
      ),
    );
  }

  // Date of Birth field
  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _dobController,
        decoration: InputDecoration(
          labelText: 'Date of Birth',
        ),
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              _dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
            });
          }
        },
      ),
    );
  }

  // Helper method to create dropdown fields
  Widget _buildDropdownField(String label, List<String> options, String selectedValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
        ),
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
