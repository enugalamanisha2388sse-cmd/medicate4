import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';
import '../auth/role_selection_screen.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> with TickerProviderStateMixin {
  late AnimationController _callAnimationController;
  late AnimationController _telemetryController;

  int _currentIndex = 0;

  // Local call simulation states
  bool _isCallActive = false;
  String? _callingPatient;
  int _callDuration = 0;
  Timer? _callTimer;

  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  // Details Navigation State
  PatientRecord? _selectedPatient;
  bool _isCreatingPrescription = false;
  bool _isViewingVitals = false;
  bool _isViewingProfile = false;
  bool _isViewingReports = false;
  bool _isViewingLabReports = false;
  bool _isViewingPrescriptionHistory = false;
  bool _isViewingVitalsHistory = false;
  bool _isViewingMedicineAdherence = false;
  bool _isViewingAlerts = false;
  bool _isViewingNotifications = false;

  // Form controllers
  final _searchController = TextEditingController();
  final _diagnosisController = TextEditingController(text: 'Essential Hypertension');
  final _durationController = TextEditingController(text: '30 Days');
  final _instructionsController = TextEditingController(text: 'Take medicines regularly at the same time.');
  final List<Map<String, String>> _prescriptionMeds = [
    {'name': 'Amlodipine 5mg', 'sig': '1 Tablet  ·  Once daily  ·  After food'},
    {'name': 'Telmisartan 40mg', 'sig': '1 Tablet  ·  Once daily  ·  After food'},
  ];

  @override
  void initState() {
    super.initState();
    _callAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _telemetryController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
  }

  @override
  void dispose() {
    _callAnimationController.dispose();
    _telemetryController.dispose();
    _callTimer?.cancel();
    _searchController.dispose();
    _diagnosisController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    _disposeCamera();
    super.dispose();
  }

  void _disposeCamera() {
    _cameraController?.dispose();
    _cameraController = null;
    _isCameraInitialized = false;
  }

  void _startCall(String patientName) {
    setState(() {
      _isCallActive = true;
      _callingPatient = patientName;
      _callDuration = 0;
    });
    _callAnimationController.repeat();
    _initializeCamera();

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      _callAnimationController.stop();
      _telemetryController.repeat();
      _startTimer();
    });
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      CameraDescription? frontCamera;
      for (var camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }

      final selectedCamera = frontCamera ?? cameras.first;

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print("Camera initialization error: $e");
    }
  }

  void _startTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _callDuration++;
      });
    });
  }

  void _hangUp() {
    _callTimer?.cancel();
    _telemetryController.stop();
    _disposeCamera();
    setState(() {
      _isCallActive = false;
      _callingPatient = null;
      _callDuration = 0;
    });
  }

  String _formatDuration(int secs) {
    final mins = (secs ~/ 60).toString().padLeft(2, '0');
    final seconds = (secs % 60).toString().padLeft(2, '0');
    return '$mins:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    final user = provider.currentUser;

    if (user == null) {
      return RoleSelectionScreen();
    }

    if (_isCallActive) {
      return _buildCallScreen();
    }

    // Sub-screens Navigation Overlays
    if (_isCreatingPrescription && _selectedPatient != null) {
      return _buildNewPrescriptionScreen(_selectedPatient!);
    }
    if (_isViewingVitals && _selectedPatient != null) {
      return _buildVitalsScreen(_selectedPatient!);
    }
    if (_selectedPatient != null) {
      return _buildPatientDetailsScreen(_selectedPatient!);
    }
    if (_isViewingProfile) {
      return _buildDoctorProfileScreen(user);
    }
    if (_isViewingLabReports) {
      return _buildLabReportsDashboardScreen();
    }
    if (_isViewingPrescriptionHistory) {
      return _buildPrescriptionHistoryScreen(provider);
    }
    if (_isViewingVitalsHistory) {
      return _buildVitalsHistoryScreen();
    }
    if (_isViewingMedicineAdherence) {
      return _buildMedicineAdherenceScreen();
    }
    if (_isViewingReports) {
      return _buildReportsScreen();
    }
    if (_isViewingAlerts) {
      return _buildAlertsScreen();
    }
    if (_isViewingNotifications) {
      return _buildNotificationsScreen();
    }

    final myAppts = provider.appointments.where((a) => a.doctorName.toLowerCase() == user.name.toLowerCase()).toList();

    final tabs = [
      _buildHomeTab(context, provider, user, myAppts),
      _buildPatientsTab(context, provider),
      _buildAppointmentsTab(context, provider, myAppts),
      _buildSettingsTab(context, provider, user),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: tabs[_currentIndex],
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavBarItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
            _buildNavBarItem(1, Icons.people_rounded, Icons.people_outline_rounded, 'Patients'),
            _buildNavBarItem(2, Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Appointments'),
            _buildNavBarItem(3, Icons.more_horiz_rounded, Icons.more_horiz_rounded, 'More'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final bool isActive = _currentIndex == index;
    final color = isActive ? const Color(0xFF2563EB) : const Color(0xFF94A3B8);
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : inactiveIcon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 0: HOME DASHBOARD
  // ==========================================
  Widget _buildHomeTab(BuildContext context, MedicateProvider provider, UserAccount user, List<Appointment> myAppts) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${user.name} 👋',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                  Text(
                    'Good Morning!',
                    style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.notifications_active, color: Colors.redAccent),
                onPressed: () => setState(() => _isViewingNotifications = true),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // AI Clinical Alert Card
          GestureDetector(
            onTap: () => setState(() => _isViewingAlerts = true),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.report_gmailerrorred_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Clinical Alert',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '2 patients need your immediate attention',
                          style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      'View Alerts',
                      style: GoogleFonts.poppins(color: const Color(0xFF1E3A8A), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Grid Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildCountTile('Total Patients', '${provider.patients.length + 18}', '+18 this month', Icons.people_alt, const Color(0xFF3B82F6)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCountTile('Today\'s Appt.', '${myAppts.length}', '${myAppts.where((a) => a.status == 'Pending').length} pending', Icons.calendar_today, const Color(0xFF10B981)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCountTile('Prescriptions', '38', '+6 new', Icons.note_alt, const Color(0xFF8B5CF6)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCountTile('Pending Alerts', '7', 'View all', Icons.alarm, const Color(0xFFEF4444)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Today's Appointments Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Appointments',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
              ),
              InkWell(
                onTap: () => setState(() => _currentIndex = 2),
                child: Text(
                  'View all',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Appointment List
          if (myAppts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No appointments booked yet.',
                  style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 13),
                ),
              ),
            )
          else
            ...myAppts.map((appt) {
              final timeStr = '${appt.dateTime.hour.toString().padLeft(2, '0')}:${appt.dateTime.minute.toString().padLeft(2, '0')}';
              final isFemale = appt.patientName.toLowerCase().contains('neha') || appt.patientName.toLowerCase().contains('pooja') || appt.patientName.toLowerCase().contains('alice') || appt.patientName.toLowerCase().contains('emily');
              return InkWell(
                onTap: () {
                  _showAppointmentActionDialog(context, provider, appt);
                },
                child: _buildAppointmentItem(
                  appt.patientName,
                  timeStr,
                  appt.department,
                  isFemale ? '👩' : '👨',
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildCountTile(String label, String value, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
          Text(label, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
          Text(sub, style: GoogleFonts.poppins(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(String name, String time, String type, String emoji) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFEFF6FF),
            child: Text(emoji, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                Text(type, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          Text(time, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: PATIENTS LIST
  // ==========================================
  Widget _buildPatientsTab(BuildContext context, MedicateProvider provider) {
    final query = _searchController.text.toLowerCase();
    final list = provider.patients.where((p) => p.name.toLowerCase().contains(query)).toList();

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Search input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFF94A3B8), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.poppins(fontSize: 13),
                        onChanged: (val) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search patients...',
                          hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    const Icon(Icons.filter_list, color: Color(0xFF2563EB), size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Patient List View
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Text(
                          'No patients found',
                          style: GoogleFonts.poppins(color: const Color(0xFF64748B)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, idx) {
                          final patient = list[idx];
                          final isFemale = patient.gender.toLowerCase() == 'female';
                          return InkWell(
                            onTap: () => setState(() => _selectedPatient = patient),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFFEFF6FF),
                                    child: Text(isFemale ? '👩' : '👨'),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(patient.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                                        Row(
                                          children: [
                                            Text(patient.id, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                                            const SizedBox(width: 8),
                                            Text('·  ${patient.age} yrs, ${patient.gender}', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                                    child: Text(
                                      patient.medicalHistory.split(',')[0],
                                      style: GoogleFonts.poppins(color: const Color(0xFF475569), fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),

        // Add Patient Floating Action Button
        Positioned(
          bottom: 16,
          left: 20,
          right: 20,
          child: GestureDetector(
            onTap: () => _showAddPatientDialog(context, provider),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Add Patient',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddPatientDialog(BuildContext context, MedicateProvider provider) {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final historyCtrl = TextEditingController();
    String gender = 'Male';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add Patient Record', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: 'Name', labelStyle: GoogleFonts.poppins(fontSize: 12)),
              ),
              TextField(
                controller: ageCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Age', labelStyle: GoogleFonts.poppins(fontSize: 12)),
              ),
              DropdownButtonFormField<String>(
                value: gender,
                onChanged: (val) => gender = val!,
                decoration: InputDecoration(labelText: 'Gender', labelStyle: GoogleFonts.poppins(fontSize: 12)),
                items: ['Male', 'Female'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              ),
              TextField(
                controller: historyCtrl,
                decoration: InputDecoration(labelText: 'Diagnosis / History', labelStyle: GoogleFonts.poppins(fontSize: 12)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && ageCtrl.text.isNotEmpty) {
                  final age = int.tryParse(ageCtrl.text) ?? 30;
                  provider.addPatient(nameCtrl.text, age, gender, historyCtrl.text, 'None');
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: Text('Save', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // TAB 2: APPOINTMENTS LIST
  // ==========================================
  Widget _buildAppointmentsTab(BuildContext context, MedicateProvider provider, List<Appointment> myAppts) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Calendar title
              Text(
                'Schedules Overview',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 16),
              
              // Appointments List
              Expanded(
                child: myAppts.isEmpty
                    ? Center(
                        child: Text(
                          'No appointments scheduled yet',
                          style: GoogleFonts.poppins(color: const Color(0xFF64748B)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: myAppts.length,
                        itemBuilder: (context, idx) {
                          final appt = myAppts[idx];
                          final timeStr = '${appt.dateTime.hour.toString().padLeft(2, '0')}:${appt.dateTime.minute.toString().padLeft(2, '0')}';
                          return InkWell(
                            onTap: () {
                              _showAppointmentActionDialog(context, provider, appt);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFFEFF6FF),
                                    child: Icon(Icons.person, color: const Color(0xFF2563EB), size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(appt.patientName, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                                        Text(appt.department, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(timeStr, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: appt.status == 'Pending' ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          appt.status,
                                          style: GoogleFonts.poppins(
                                            color: appt.status == 'Pending' ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),

        // New Appointment Button Floating
        Positioned(
          bottom: 16,
          left: 20,
          right: 20,
          child: GestureDetector(
            onTap: () => _showNewAppointmentDialog(context, provider),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_month, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'New Appointment',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showNewAppointmentDialog(BuildContext context, MedicateProvider provider) {
    final patientNameCtrl = TextEditingController();
    final deptCtrl = TextEditingController(text: 'General Consultation');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Schedule Appointment', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: patientNameCtrl,
                decoration: InputDecoration(labelText: 'Patient Name', labelStyle: GoogleFonts.poppins(fontSize: 12)),
              ),
              TextField(
                controller: deptCtrl,
                decoration: InputDecoration(labelText: 'Department', labelStyle: GoogleFonts.poppins(fontSize: 12)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
              onPressed: () {
                if (patientNameCtrl.text.isNotEmpty) {
                  provider.scheduleAppointment(
                    patientNameCtrl.text,
                    provider.currentUser?.name ?? 'Dr. Sarah Connor',
                    deptCtrl.text,
                    DateTime.now().add(const Duration(hours: 2)),
                    'Confirmed',
                  );
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: Text('Schedule', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // TAB 3: MORE / SETTINGS
  // ==========================================
  Widget _buildSettingsTab(BuildContext context, MedicateProvider provider, UserAccount user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Doctor Summary Profile Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Center(child: Text('👩‍⚕️', style: TextStyle(fontSize: 32))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.specialty,
                        style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                  onPressed: () => setState(() => _isViewingProfile = true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Options List
          _buildSettingsOptionTile('Reports Dashboard', Icons.analytics_outlined, () => setState(() => _isViewingReports = true)),
          _buildSettingsOptionTile('AI Clinical Alerts', Icons.report_problem_outlined, () => setState(() => _isViewingAlerts = true)),
          _buildSettingsOptionTile('Notifications History', Icons.notifications_none_rounded, () => setState(() => _isViewingNotifications = true)),
          _buildSettingsOptionTile('Change Password', Icons.lock_outline_rounded, () {}),
          _buildSettingsOptionTile('Help & Support', Icons.help_outline_rounded, () {}),
          _buildSettingsOptionTile('Logout', Icons.logout_rounded, () {
            provider.logout();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RoleSelectionScreen()));
          }, isLogout: true),
        ],
      ),
    );
  }

  Widget _buildSettingsOptionTile(String label, IconData icon, VoidCallback onTap, {bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: isLogout ? Colors.redAccent : const Color(0xFF475569)),
        title: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isLogout ? Colors.redAccent : const Color(0xFF1E293B),
          ),
        ),
        trailing: isLogout ? null : const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF94A3B8)),
      ),
    );
  }

  // ==========================================
  // SUB-SCREEN OVERLAYS
  // ==========================================

  // 1. PATIENT DETAILS SCREEN
  Widget _buildPatientDetailsScreen(PatientRecord patient) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _selectedPatient = null),
        ),
        title: Text('Patient Details', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Details Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 24, backgroundColor: Colors.white24, child: Text('👨', style: TextStyle(fontSize: 26))),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(patient.name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            Text('${patient.id}  ·  ${patient.age} yrs, ${patient.gender}', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(6)),
                              child: Text(patient.medicalHistory, style: GoogleFonts.poppins(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Sub-tabs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildOverviewSubTab('Overview', true),
                    _buildOverviewSubTab('Vitals', false, onTap: () => setState(() => _isViewingVitals = true)),
                    _buildOverviewSubTab('History', false),
                    _buildOverviewSubTab('Reports', false),
                  ],
                ),
                const SizedBox(height: 24),

                // Info Section
                Text('About', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                const SizedBox(height: 8),
                _buildContactInfoTile(Icons.phone_outlined, '+91 98765 43210'),
                _buildContactInfoTile(Icons.email_outlined, '${patient.name.replaceAll(' ', '').toLowerCase()}@email.com'),
                _buildContactInfoTile(Icons.location_on_outlined, 'Hyderabad, India'),
                const SizedBox(height: 24),

                // Medications Section
                Text('Current Medications', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                const SizedBox(height: 8),
                _buildMedicationStrip('Amlodipine 5mg', 'Once daily  ·  After food'),
                _buildMedicationStrip('Telmisartan 40mg', 'Once daily  ·  After food'),
                const SizedBox(height: 80),
              ],
            ),
          ),

          // New Prescription Action Button
          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => setState(() => _isCreatingPrescription = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Text('+ New Prescription', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSubTab(String label, bool active, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? const Color(0xFF2563EB) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfoTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 16),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF475569))),
        ],
      ),
    );
  }

  Widget _buildMedicationStrip(String name, String schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(
        children: [
          Container(width: 4, height: 28, color: const Color(0xFFFCA5A5)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                Text(schedule, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  // 2. NEW PRESCRIPTION SCREEN
  Widget _buildNewPrescriptionScreen(PatientRecord patient) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isCreatingPrescription = false),
        ),
        title: Text('New Prescription', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(radius: 18, child: Text('👨')),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(patient.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                        Text('${patient.id}  ·  ${patient.age} yrs, ${patient.gender}', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Diagnosis input
                Text('Diagnosis', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                const SizedBox(height: 6),
                TextField(
                  controller: _diagnosisController,
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 20),

                // Medicines List
                Text('Medicines', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                const SizedBox(height: 8),
                Column(
                  children: _prescriptionMeds.map((med) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(med['name']!, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                              Text(med['sig']!, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                            onPressed: () => setState(() => _prescriptionMeds.remove(med)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _showAddMedicineDialog,
                  child: Text(
                    '+ Add Medicine',
                    style: GoogleFonts.poppins(color: const Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 20),

                // Duration
                Text('Duration', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                const SizedBox(height: 6),
                TextField(
                  controller: _durationController,
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 20),

                // Instructions
                Text('Instructions', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                const SizedBox(height: 6),
                TextField(
                  controller: _instructionsController,
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Prescription Saved & Sent to ${patient.name}!', style: GoogleFonts.poppins()),
                  backgroundColor: const Color(0xFF10B981),
                ));
                setState(() {
                  _isCreatingPrescription = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Text('Save Prescription', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMedicineDialog() {
    final medNameCtrl = TextEditingController();
    final medSigCtrl = TextEditingController(text: '1 Tablet  ·  Once daily  ·  After food');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add Medication', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: medNameCtrl,
                decoration: InputDecoration(labelText: 'Medicine Name', labelStyle: GoogleFonts.poppins(fontSize: 12)),
              ),
              TextField(
                controller: medSigCtrl,
                decoration: InputDecoration(labelText: 'Instructions / Dose', labelStyle: GoogleFonts.poppins(fontSize: 12)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
              onPressed: () {
                if (medNameCtrl.text.isNotEmpty) {
                  setState(() {
                    _prescriptionMeds.add({
                      'name': medNameCtrl.text,
                      'sig': medSigCtrl.text,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Add', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // 3. VITALS MONITORING SCREEN
  Widget _buildVitalsScreen(PatientRecord patient) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingVitals = false),
        ),
        title: Text('Vitals Monitoring', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 18, child: Text('👨')),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patient.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                    Text(patient.id, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time filters
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Expanded(child: _buildTimeChip('Day', false)),
                  Expanded(child: _buildTimeChip('Week', true)),
                  Expanded(child: _buildTimeChip('Month', false)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Vitals Mini Grid
            Row(
              children: [
                Expanded(child: _buildVitalItemCard('Blood Pressure', '120/80', 'mmHg', 'Normal', const Color(0xFF10B981))),
                const SizedBox(width: 12),
                Expanded(child: _buildVitalItemCard('Heart Rate', '72', 'bpm', 'Normal', const Color(0xFFEF4444))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildVitalItemCard('Blood Glucose', '98', 'mg/dL', 'Normal', const Color(0xFF3B82F6))),
                const SizedBox(width: 12),
                Expanded(child: _buildVitalItemCard('Weight', '72', 'kg', 'Normal', const Color(0xFF8B5CF6))),
              ],
            ),
            const SizedBox(height: 28),

            GestureDetector(
              onTap: () => setState(() => _isViewingVitals = false),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFF2563EB)), borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text('Close Vitals', style: GoogleFonts.poppins(color: const Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8)),
      child: Text(label, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 11, fontWeight: active ? FontWeight.bold : FontWeight.w500, color: const Color(0xFF1E293B))),
    );
  }

  Widget _buildVitalItemCard(String label, String value, String unit, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
          const SizedBox(height: 4),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
              const SizedBox(width: 4),
              Text(unit, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: GoogleFonts.poppins(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 4. DOCTOR PROFILE SCREEN
  Widget _buildDoctorProfileScreen(UserAccount user) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingProfile = false),
        ),
        title: Text('Profile', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Center(child: Text('👩‍⚕️', style: TextStyle(fontSize: 40))),
                  ),
                  const SizedBox(height: 12),
                  Text(user.name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(user.specialty, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                  Text('Reg. No. TS/76845', style: GoogleFonts.poppins(color: Colors.white60, fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildProfileDetailRow('Clinic / Hospital', user.hospitalName.isNotEmpty ? user.hospitalName : 'Care Health Clinic'),
            _buildProfileDetailRow('Mobile Number', user.phone.isNotEmpty ? user.phone : '+91 98765 43210'),
            _buildProfileDetailRow('Email', user.email),
            _buildProfileDetailRow('Availability', 'Mon - Sat (09:00 AM - 06:00 PM)'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(String label, String val) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
          Text(val, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        ],
      ),
    );
  }

  // 5. REPORTS DASHBOARD SCREEN
  Widget _buildReportsScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingReports = false),
        ),
        title: Text('Reports Dashboard', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildReportOptionTile('Lab Reports', 'View patient lab test reports', Icons.science_outlined, () {
            setState(() => _isViewingLabReports = true);
          }),
          _buildReportOptionTile('Prescription History', 'View all prescriptions', Icons.assignment_outlined, () {
            setState(() => _isViewingPrescriptionHistory = true);
          }),
          _buildReportOptionTile('Vitals History', 'View historical vitals data', Icons.trending_up, () {
            setState(() => _isViewingVitalsHistory = true);
          }),
          _buildReportOptionTile('Medicine Adherence', 'Check medicine intake history', Icons.done_all, () {
            setState(() => _isViewingMedicineAdherence = true);
          }),
        ],
      ),
    );
  }

  Widget _buildReportOptionTile(String title, String sub, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundColor: const Color(0xFFF1F5F9), child: Icon(icon, color: const Color(0xFF475569), size: 20)),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        subtitle: Text(sub, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF94A3B8)),
      ),
    );
  }

  Widget _buildLabReportsDashboardScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingLabReports = false),
        ),
        title: Text('Lab Reports', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildLabReportPatientSection('Alice Smith (ID: p1)', [
            {'test': 'Complete Blood Count (CBC)', 'result': 'Normal', 'date': '24 Aug 2026', 'status': 'normal'},
            {'test': 'Lipid Panel', 'result': 'Cholesterol: 210 mg/dL', 'date': '20 Aug 2026', 'status': 'warning'},
            {'test': 'Thyroid Stimulating Hormone (TSH)', 'result': '1.8 uIU/mL', 'date': '15 Aug 2026', 'status': 'normal'},
          ]),
          const SizedBox(height: 16),
          _buildLabReportPatientSection('Robert Johnson (ID: p2)', [
            {'test': 'HbA1c (Glycated Hemoglobin)', 'result': '7.4%', 'date': '22 Aug 2026', 'status': 'danger'},
            {'test': 'Renal Function Test', 'result': 'Creatinine: 1.1 mg/dL', 'date': '18 Aug 2026', 'status': 'normal'},
          ]),
          const SizedBox(height: 16),
          _buildLabReportPatientSection('Emily Davis (ID: p3)', [
            {'test': 'Urinalysis', 'result': 'Normal', 'date': '19 Aug 2026', 'status': 'normal'},
            {'test': 'Vitamin D3 level', 'result': '24 ng/mL (Low)', 'date': '10 Aug 2026', 'status': 'warning'},
          ]),
        ],
      ),
    );
  }

  Widget _buildLabReportPatientSection(String patientName, List<Map<String, String>> tests) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              patientName,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ...tests.map((t) {
            Color statusColor;
            Color bgStatus;
            switch (t['status']) {
              case 'danger':
                statusColor = const Color(0xFFEF4444);
                bgStatus = const Color(0xFFFEE2E2);
                break;
              case 'warning':
                statusColor = const Color(0xFFF59E0B);
                bgStatus = const Color(0xFFFEF3C7);
                break;
              default:
                statusColor = const Color(0xFF10B981);
                bgStatus = const Color(0xFFD1FAE5);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t['test']!, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
                        const SizedBox(height: 2),
                        Text('Tested on ${t['date']}', style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: bgStatus, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          t['result']!,
                          style: GoogleFonts.poppins(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPrescriptionHistoryScreen(MedicateProvider provider) {
    final prescriptions = provider.prescriptions;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingPrescriptionHistory = false),
        ),
        title: Text('Prescription History', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: prescriptions.isEmpty
          ? Center(
              child: Text(
                'No prescriptions written yet.',
                style: GoogleFonts.poppins(color: const Color(0xFF64748B)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: prescriptions.length,
              itemBuilder: (context, idx) {
                final prescription = prescriptions[idx];
                final dateStr = '${prescription.date.day}/${prescription.date.month}/${prescription.date.year}';
                final patientName = provider.patients.firstWhere((p) => p.id == prescription.patientId, orElse: () => PatientRecord(id: '', name: 'Standard Patient', age: 30, gender: 'Male', medicalHistory: '', allergies: '')).name;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            patientName,
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                          ),
                          Text(
                            dateStr,
                            style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rx: ${prescription.medicineName}',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sig: ${prescription.dosage}',
                        style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                      ),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'By: ${prescription.doctorName}',
                            style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8), fontStyle: FontStyle.italic),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              'E-Signed',
                              style: GoogleFonts.poppins(color: const Color(0xFF2563EB), fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildVitalsHistoryScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingVitalsHistory = false),
        ),
        title: Text('Vitals History', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildVitalsHistoryPatientCard('Alice Smith', [
            {'date': '24 Aug 2026', 'bp': '118/76', 'hr': '72 bpm', 'glucose': '95 mg/dL'},
            {'date': '17 Aug 2026', 'bp': '120/80', 'hr': '75 bpm', 'glucose': '98 mg/dL'},
            {'date': '10 Aug 2026', 'bp': '122/82', 'hr': '74 bpm', 'glucose': '101 mg/dL'},
          ]),
          const SizedBox(height: 16),
          _buildVitalsHistoryPatientCard('Robert Johnson', [
            {'date': '24 Aug 2026', 'bp': '138/88', 'hr': '82 bpm', 'glucose': '145 mg/dL'},
            {'date': '17 Aug 2026', 'bp': '135/86', 'hr': '80 bpm', 'glucose': '140 mg/dL'},
            {'date': '10 Aug 2026', 'bp': '140/90', 'hr': '84 bpm', 'glucose': '152 mg/dL'},
          ]),
          const SizedBox(height: 16),
          _buildVitalsHistoryPatientCard('Emily Davis', [
            {'date': '24 Aug 2026', 'bp': '115/70', 'hr': '68 bpm', 'glucose': '88 mg/dL'},
            {'date': '17 Aug 2026', 'bp': '112/72', 'hr': '70 bpm', 'glucose': '90 mg/dL'},
          ]),
        ],
      ),
    );
  }

  Widget _buildVitalsHistoryPatientCard(String patientName, List<Map<String, String>> vitals) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              patientName,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ...vitals.map((v) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(v['date']!, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
                      const Icon(Icons.trending_up, color: Colors.blue, size: 16),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildVitalsMetricSub('Blood Pressure', v['bp']!),
                      ),
                      Expanded(
                        child: _buildVitalsMetricSub('Heart Rate', v['hr']!),
                      ),
                      Expanded(
                        child: _buildVitalsMetricSub('Glucose', v['glucose']!),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildVitalsMetricSub(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF94A3B8))),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF475569))),
      ],
    );
  }

  Widget _buildMedicineAdherenceScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingMedicineAdherence = false),
        ),
        title: Text('Medicine Adherence', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildAdherencePatientSection('Alice Smith', 92, [
            {'med': 'Montelukast 10mg', 'schedule': 'Daily 09:00 PM', 'status': 'Taken'},
            {'med': 'Amoxicillin 250mg', 'schedule': 'Daily 08:00 AM', 'status': 'Taken'},
            {'med': 'Multivitamin', 'schedule': 'Daily 02:00 PM', 'status': 'Missed'},
          ]),
          const SizedBox(height: 16),
          _buildAdherencePatientSection('Robert Johnson', 75, [
            {'med': 'Metformin 500mg', 'schedule': 'Daily 08:00 AM', 'status': 'Taken'},
            {'med': 'Aspirin 75mg', 'schedule': 'Daily 08:00 AM', 'status': 'Missed'},
            {'med': 'Atorvastatin 10mg', 'schedule': 'Daily 09:00 PM', 'status': 'Taken'},
          ]),
          const SizedBox(height: 16),
          _buildAdherencePatientSection('Emily Davis', 100, [
            {'med': 'Cetirizine 10mg', 'schedule': 'Daily 09:00 PM', 'status': 'Taken'},
          ]),
        ],
      ),
    );
  }

  Widget _buildAdherencePatientSection(String patientName, int rate, List<Map<String, String>> meds) {
    Color rateColor = rate >= 90 ? const Color(0xFF10B981) : (rate >= 80 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  patientName,
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: rateColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    'Adherence: $rate%',
                    style: GoogleFonts.poppins(color: rateColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ...meds.map((m) {
            final isTaken = m['status'] == 'Taken';
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    isTaken ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: isTaken ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m['med']!, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
                        Text('Scheduled: ${m['schedule']}', style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                  Text(
                    m['status']!.toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: isTaken ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // 6. AI CLINICAL ALERTS SCREEN
  Widget _buildAlertsScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingAlerts = false),
        ),
        title: Text('AI Clinical Alerts', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildAlertCardStrip('High Blood Pressure', 'Rahul Kumar\'s BP has increased compared to previous 3 readings.', '10 min ago', const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
          _buildAlertCardStrip('Missed Medicine', 'Neha Verma missed a dose of Telmisartan 40mg.', '1 hour ago', const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
          _buildAlertCardStrip('Abnormal Vitals', 'Pooja Singh\'s blood glucose level is higher than normal.', '2 hours ago', const Color(0xFF3B82F6), const Color(0xFFEFF6FF)),
        ],
      ),
    );
  }

  Widget _buildAlertCardStrip(String title, String desc, String time, Color color, Color bg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.12))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Icon(Icons.warning, color: color, size: 16)),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF475569))),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8))),
              Text('View Patient', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  // 7. NOTIFICATIONS SCREEN
  Widget _buildNotificationsScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingNotifications = false),
        ),
        title: Text('Notifications', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildNotificationCard(context, 'Appointment Reminder', 'You have 3 appointments today starting at 09:30 AM.', '10 min ago', Icons.calendar_today, const Color(0xFF3B82F6)),
          _buildNotificationCard(context, 'Missed Medicine Alert', 'Rahul Kumar missed a dose of Amlodipine 5mg.', '30 min ago', Icons.warning_amber_rounded, const Color(0xFFEF4444)),
          _buildNotificationCard(context, 'Abnormal Vitals Alert', 'Pooja Singh\'s BP is higher than normal.', '1 hour ago', Icons.favorite_border, const Color(0xFFEF4444)),
          _buildNotificationCard(context, 'System Update', 'System update completed. Version 2.4.1 verified.', '2 hours ago', Icons.system_update_rounded, const Color(0xFF10B981), onTap: () => _showSystemUpdateModal(context)),
        ],
      ),
    );
  }

  void _showSystemUpdateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const CircleAvatar(radius: 30, backgroundColor: Color(0xFFECFDF5), child: Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 32)),
              const SizedBox(height: 12),
              Text('System Update Verified', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
              const SizedBox(height: 4),
              Text('Medicate Clinical Platform v2.4.1', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6366F1), fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text(
                'Your system has been successfully verified and updated! All clinical AI models, telemetry drivers, and security patches are running on the latest build.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(BuildContext context, String title, String body, String time, IconData icon, Color color, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF1F5F9))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color, size: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                      const SizedBox(height: 2),
                      Text(body, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                      const SizedBox(height: 4),
                      Text(time, style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // CALL SIMULATOR SCREEN
  // ==========================================
  Widget _buildCallScreen() {
    return Scaffold(
      backgroundColor: AppTheme.isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Telemetry pulsing circle
                Center(
                  child: AnimatedBuilder(
                    animation: _callAnimationController,
                    builder: (context, child) {
                      return Container(
                        width: 120 + 30 * _callAnimationController.value,
                        height: 120 + 30 * _callAnimationController.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF3B82F6).withOpacity(0.15 - 0.1 * _callAnimationController.value),
                        ),
                        child: Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.videocam, color: Colors.white, size: 40),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  _callingPatient ?? 'Connecting...',
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDuration(_callDuration),
                  style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF94A3B8)),
                ),
                const Spacer(),
                // End Call Button
                GestureDetector(
                  onTap: _hangUp,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 30),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),

            // Floating Camera Feed PIP
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                width: 95,
                height: 135,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.5),
                  child: _isCameraInitialized && _cameraController != null
                      ? AspectRatio(
                          aspectRatio: _cameraController!.value.aspectRatio,
                          child: CameraPreview(_cameraController!),
                        )
                      : Container(
                          color: Colors.black.withOpacity(0.8),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.videocam_off_rounded, color: Colors.redAccent, size: 20),
                                SizedBox(height: 4),
                                Text('Connecting...', style: TextStyle(color: Colors.white, fontSize: 8)),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppointmentActionDialog(BuildContext context, MedicateProvider provider, Appointment appt) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Manage Appointment', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Text(
            'Appointment with ${appt.patientName} for ${appt.department} is currently ${appt.status}.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          actions: [
            if (appt.status == 'Pending') ...[
              TextButton(
                onPressed: () {
                  provider.updateAppointmentStatus(appt.id, 'Approved');
                  Navigator.pop(context);
                  setState(() {});
                },
                child: Text('Approve', style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () {
                  provider.updateAppointmentStatus(appt.id, 'Cancelled');
                  Navigator.pop(context);
                  setState(() {});
                },
                child: Text('Cancel / Decline', style: GoogleFonts.poppins(color: Colors.red)),
              ),
            ] else if (appt.status == 'Approved') ...[
              TextButton(
                onPressed: () {
                  provider.updateAppointmentStatus(appt.id, 'Completed');
                  Navigator.pop(context);
                  setState(() {});
                },
                child: Text('Mark Completed', style: GoogleFonts.poppins(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            ],
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }
}
