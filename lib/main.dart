import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'dart:async';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase setup
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(), // for employee registration
      },
    );
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login method
  Future<String?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user == null) return "User not found.";

      if (email == 'founder@gmail.com') {
        return "founder";
      }

      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      final role = snapshot.data()?['role'];

      if (role == 'employee') {
        return "employee";
      } else {
        return "Invalid role.";
      }
    } catch (e) {
      return e.toString();
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _isLoading = false;
  final AuthService _authService = AuthService();

  void _login() async {
    setState(() => _isLoading = true);

    String? result = await _authService.login(_email.text, _password.text);

    setState(() => _isLoading = false);

    if (result == "founder") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  FounderDashboard()),
      );
    } else if (result == "employee") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  EmployeeDashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result ?? "Login failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _login, child: const Text("Login")),
            const SizedBox(height: 10),
            TextButton(
              child: const Text("Register as Employee"),
              onPressed: () {
                Navigator.pushNamed(context, '/register'); // Use your named route or screen
              },
            ),
          ],
        ),
      ),
    );
  }
}


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool loading = false;

  void registerEmployee() async {
    if (_formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      try {
        setState(() => loading = true);

        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'address': addressController.text.trim(),
          'role': 'employee',
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );

        Navigator.pop(context); // Go back to login screen
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration failed')),
        );
      } finally {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Employee')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter email' : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Min 6 characters' : null,
              ),
              TextFormField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 20),
              loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: registerEmployee,
                      child: const Text('Register'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}



class FounderDashboard extends StatefulWidget {
  const FounderDashboard({super.key});

  @override
  State<FounderDashboard> createState() => _FounderDashboardState();
}

class _FounderDashboardState extends State<FounderDashboard> {
  DateTime _selectedDay = DateTime.now();
  List<Map<String, dynamic>> employeeData = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchEmployeeAttendance();
  }

  Future<void> fetchEmployeeAttendance() async {
    setState(() {
      loading = true;
      employeeData.clear();
    });

    final String selectedDate = DateFormat('yyyy-MM-dd').format(_selectedDay);

    // Get all users with role employee
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .get();

    for (var doc in usersSnapshot.docs) {
      String uid = doc['uid'];
      String name = doc['name'];

      final attendanceDoc = await FirebaseFirestore.instance
          .collection('attendance')
          .doc(uid)
          .collection('dates')
          .doc(selectedDate)
          .get();

      String loginTime = '00';
      String logoutTime = '00';

      if (attendanceDoc.exists) {
        loginTime = attendanceDoc.data()?['login'] ?? 'NR';
        logoutTime = attendanceDoc.data()?['logout'] ?? 'NR';
      } else if (_selectedDay.isBefore(DateTime.now())) {
        loginTime = 'NR';
        logoutTime = 'NR';
      }

      employeeData.add({
        'name': name,
        'login': loginTime,
        'logout': logoutTime,
      });
    }

    setState(() => loading = false);
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      _selectedDay = day;
    });
    fetchEmployeeAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Founder Dashboard')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 30)),
            lastDay: DateTime.now().add(const Duration(days: 30)),
            focusedDay: _selectedDay,
            currentDay: _selectedDay,
            onDaySelected: _onDaySelected,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
            ),
            availableGestures: AvailableGestures.horizontalSwipe,
            headerVisible: false,
            calendarFormat: CalendarFormat.week,
          ),
          const SizedBox(height: 12),
          Text(
            "Attendance on: ${DateFormat('dd MMM yyyy').format(_selectedDay)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          loading
              ? const CircularProgressIndicator()
              : Expanded(
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Employee')),
                        DataColumn(label: Text('Login')),
                        DataColumn(label: Text('Logout')),
                      ],
                      rows: employeeData
                          .map(
                            (emp) => DataRow(cells: [
                              DataCell(Text(emp['name'])),
                              DataCell(Text(emp['login'])),
                              DataCell(Text(emp['logout'])),
                            ]),
                          )
                          .toList(),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}



class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  DateTime _selectedDay = DateTime.now();
  String loginTime = '';
  String logoutTime = '';
  bool isLoggedIn = false;
  Timer? _timer;
  String currentTime = '';

  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _updateCurrentTime();
    _loadDayData();
  }

  void _updateCurrentTime() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      setState(() {
        currentTime = DateFormat('hh:mm:ss a').format(now);
      });
    });
  }

  Future<void> _loadDayData() async {
    final docId = DateFormat('yyyy-MM-dd').format(_selectedDay);
    final doc = await FirebaseFirestore.instance
        .collection('attendance')
        .doc(uid)
        .collection('dates')
        .doc(docId)
        .get();

    setState(() {
      if (doc.exists) {
        loginTime = doc['login'] ?? '00';
        logoutTime = doc['logout'] ?? '00';
        isLoggedIn = doc['login'] != null && doc['logout'] == null;
      } else {
        loginTime = '00';
        logoutTime = '00';
        isLoggedIn = false;
      }
    });
  }

  Future<void> _handleLogin() async {
    final docId = DateFormat('yyyy-MM-dd').format(_selectedDay);
    final now = DateFormat('hh:mm:ss a').format(DateTime.now());

    await FirebaseFirestore.instance
        .collection('attendance')
        .doc(uid)
        .collection('dates')
        .doc(docId)
        .set({'login': now}, SetOptions(merge: true));

    setState(() {
      loginTime = now;
      isLoggedIn = true;
    });
  }

  Future<void> _handleLogout() async {
    final docId = DateFormat('yyyy-MM-dd').format(_selectedDay);
    final now = DateFormat('hh:mm:ss a').format(DateTime.now());

    await FirebaseFirestore.instance
        .collection('attendance')
        .doc(uid)
        .collection('dates')
        .doc(docId)
        .set({
      'logout': now,
    }, SetOptions(merge: true));

    setState(() {
      logoutTime = now;
      isLoggedIn = false;
    });
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      _selectedDay = day;
    });
    _loadDayData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isToday = DateFormat('yyyy-MM-dd').format(_selectedDay) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Employee Dashboard')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 30)),
            lastDay: DateTime.now().add(const Duration(days: 30)),
            focusedDay: _selectedDay,
            currentDay: _selectedDay,
            onDaySelected: _onDaySelected,
            headerVisible: false,
            calendarFormat: CalendarFormat.week,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (isToday && loginTime == '00') ...[
            Text("Current Time: $currentTime"),
            ElevatedButton(
              onPressed: _handleLogin,
              child: const Text('Login'),
            ),
          ] else if (isToday && isLoggedIn) ...[
            Text("Logged In At: $loginTime"),
            Text("Current Time: $currentTime"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _handleLogout,
              child: const Text('Logout'),
            ),
          ] else ...[
            Text("Login Time: $loginTime"),
            Text("Logout Time: $logoutTime"),
          ],
        ],
      ),
    );
  }
}
