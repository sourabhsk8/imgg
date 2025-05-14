import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == 'founder@gmail.com' && password == 'founder@1234') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FounderDashboard()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EmployeeDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmployeeRegisterScreen(),
                  ),
                );
              },
              child: Text("New Employee? Register here"),
            ),

            ElevatedButton(onPressed: _login, child: Text("Login")),
          ],
        ),
      ),
    );
  }
}

class EmployeeRegisterScreen extends StatefulWidget {
  @override
  _EmployeeRegisterScreenState createState() => _EmployeeRegisterScreenState();
}

class _EmployeeRegisterScreenState extends State<EmployeeRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  void _registerEmployee() {
    if (_formKey.currentState!.validate()) {
      // Perform registration logic here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Employee registered successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Employee Registration")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nameController, "Full Name"),
              _buildTextField(
                _emailController,
                "Email",
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                _phoneController,
                "Phone Number",
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(_addressController, "Address", maxLines: 2),
              _buildTextField(
                _passwordController,
                "Password",
                isPassword: true,
              ),
              _buildTextField(
                _confirmPasswordController,
                "Confirm Password",
                isPassword: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerEmployee,
                child: Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "$label is required";
          }
          if (label == "Confirm Password" &&
              value != _passwordController.text) {
            return "Passwords do not match";
          }
          return null;
        },
      ),
    );
  }
}

class FounderDashboard extends StatefulWidget {
  @override
  _FounderDashboardState createState() => _FounderDashboardState();
}

class _FounderDashboardState extends State<FounderDashboard> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // Static employee data for demo
  final List<Map<String, String>> employeeList = [
    {'name': 'Alice', 'in': '09:00 AM', 'out': '05:00 PM'},
    {'name': 'Bob', 'in': '00', 'out': '00'},
    {'name': 'Charlie', 'in': '10:00 AM', 'out': '06:30 PM'},
    {'name': 'Daisy', 'in': '00', 'out': '00'},
    {'name': 'Eva', 'in': '08:45 AM', 'out': '04:45 PM'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Founder Dashboard")),
      body: Column(
        children: [
          // Layer 1: Week View Calendar
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            currentDay: _selectedDay,
            calendarFormat: CalendarFormat.week,
            daysOfWeekVisible: true,
            headerVisible: false,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
          ),

          SizedBox(height: 20),

          // Layer 2: Heading
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Employee Attendance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Layer 3: Table View
          Expanded(
            child: SingleChildScrollView(
              child: Table(
                border: TableBorder.all(color: Colors.grey),
                columnWidths: {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                },
                children: [
                  // Table Header
                  TableRow(
                    decoration: BoxDecoration(color: Colors.blue[100]),
                    children: [
                      _buildCell('Employee', isHeader: true),
                      _buildCell('Login Time', isHeader: true),
                      _buildCell('Logout Time', isHeader: true),
                    ],
                  ),
                  // Employee Rows
                  ...employeeList.map((emp) {
                    return TableRow(
                      children: [
                        _buildCell(emp['name'] ?? ''),
                        _buildCell(emp['in'] ?? '00'),
                        _buildCell(emp['out'] ?? '00'),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(String value, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        value,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
    );
  }
}

class EmployeeDashboardScreen extends StatefulWidget {
  @override
  State<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  DateTime? _loginTime;
  DateTime? _logoutTime;
  bool _isLoggedIn = false;
  bool _hasLoggedOut = false;

  final TextEditingController _workDoneController = TextEditingController();

  void _handleLogin() {
    setState(() {
      _loginTime = DateTime.now();
      _isLoggedIn = true;
    });
    // Simulate DB call: save login time
    print("Login Time saved to DB: $_loginTime");
  }

  void _handleLogout() {
    setState(() {
      _logoutTime = DateTime.now();
      _hasLoggedOut = true;
    });
    // Simulate DB call: save logout time + description
    print("Logout Time saved to DB: $_logoutTime");
    print("Description saved to DB: ${_workDoneController.text}");
  }

  String _formatTime(DateTime? time) {
    if (time == null) return "--:--";
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildConditionalLayer() {
    if (!_isLoggedIn) {
      // First login state
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Current time: ${_formatTime(DateTime.now())}", style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: _handleLogin,
            child: Text("Log In"),
          ),
        ],
      );
    } else if (_isLoggedIn && !_hasLoggedOut) {
      // Logged in, show work input + logout
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("You're logged in at: ${_formatTime(_loginTime)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          TextField(
            controller: _workDoneController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "• Task 1\n• Task 2\n• Task 3",
              border: OutlineInputBorder(),
              labelText: "What did you do today?",
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Current time: ${_formatTime(DateTime.now())}", style: TextStyle(fontSize: 16)),
              ElevatedButton(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text("Log Out"),
              ),
            ],
          )
        ],
      );
    } else {
      // Logged out state, show summary
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text("Logged in at: ${_formatTime(_loginTime)}", style: TextStyle(fontSize: 16)),
          Text("Logged out at: ${_formatTime(_logoutTime)}", style: TextStyle(fontSize: 16)),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employee Dashboard")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Layer 1: Calendar (unchanged)
            TableCalendar(
              firstDay: DateTime.utc(2022, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              currentDay: _selectedDay,
              calendarFormat: CalendarFormat.week,
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              headerVisible: false,
            ),

            const SizedBox(height: 20),

            // Layer 2: Conditional content
            _buildConditionalLayer(),
          ],
        ),
      ),
    );
  }
}
