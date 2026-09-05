import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mock_screens.dart';
import 'doctor_mock_screens.dart';
import 'auth/role_selection_screen.dart';
import '../core/services/services.dart';

class PresentationHub extends StatefulWidget {
  const PresentationHub({super.key});

  @override
  State<PresentationHub> createState() => _PresentationHubState();
}

class _PresentationHubState extends State<PresentationHub> {
  int? _focusedScreenIndex;
  bool _isDoctorCanvas = false;

  final List<Map<String, dynamic>> _screens = [
    {'label': '1. Splash Screen', 'widget': const SplashMockView()},
    {'label': '2. Login / Sign Up', 'widget': const LoginSignupMockView()},
    {'label': '3. Home Dashboard', 'widget': const HomeDashboardMockView()},
    {'label': '4. Medicine Reminder (Smart)', 'widget': const MedicineReminderMockView()},
    {'label': '5. Medicine Scanner', 'widget': const MedicineScannerMockView()},
    {'label': '6. Smart Adherence (AI)', 'widget': const SmartAdherenceMockView()},
    {'label': '7. Smart Refill Prediction', 'widget': const SmartRefillMockView()},
    {'label': '8. Caregiver Mode', 'widget': const CaregiverMockView()},
    {'label': '9. Voice Medicine Assistant', 'widget': const VoiceAssistantMockView()},
    {'label': '10. Medicine Interaction Alert', 'widget': const MedicineInteractionMockView()},
    {'label': '11. Pill Verification', 'widget': const PillVerificationMockView()},
    {'label': '12. Location Based Reminder', 'widget': const LocationReminderMockView()},
    {'label': '13. Vitals + Medicine Insight', 'widget': const VitalsInsightMockView()},
    {'label': '14. Emergency Health Card', 'widget': const EmergencyHealthCardMockView()},
    {'label': '15. More / Settings', 'widget': const MoreSettingsMockView()},
  ];

  final List<Map<String, dynamic>> _doctorScreens = [
    {'label': '1. Doctor Login / Portal', 'widget': const DoctorLoginMockView()},
    {'label': '2. Doctor Dashboard', 'widget': const DoctorHomeMockView()},
    {'label': '3. Patients List', 'widget': const DoctorPatientsMockView()},
    {'label': '4. Patient Details', 'widget': const DoctorPatientDetailsMockView()},
    {'label': '5. Appointments List', 'widget': const DoctorAppointmentsMockView()},
    {'label': '6. New Prescription', 'widget': const DoctorNewPrescriptionMockView()},
    {'label': '7. Vitals Monitoring', 'widget': const DoctorVitalsMockView()},
    {'label': '8. AI Clinical Alerts', 'widget': const DoctorAlertsMockView()},
    {'label': '9. Notifications List', 'widget': const DoctorNotificationsMockView()},
    {'label': '10. Reports Dashboard', 'widget': const DoctorReportsMockView()},
    {'label': '11. Doctor Profile', 'widget': const DoctorProfileMockView()},
    {'label': '12. Settings', 'widget': const DoctorSettingsMockView()},
  ];

  List<Map<String, dynamic>> get _activeScreens => _isDoctorCanvas ? _doctorScreens : _screens;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Sleek figma-like light canvas background
      body: Stack(
        children: [
          // Background soft glowing blobs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0EA5E9).withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF22C55E).withOpacity(0.03),
              ),
            ),
          ),

          SafeArea(
            child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
          ),

          // Zoomed-in Focus Mode Overlay
          if (_focusedScreenIndex != null)
            _buildZoomOverlay(_focusedScreenIndex!),
        ],
      ),
    );
  }

  // Mobile layout: Single phone view with screen switcher dropdown/buttons
  Widget _buildMobileLayout() {
    final int activeIdx = (_focusedScreenIndex ?? 2).clamp(0, _activeScreens.length - 1);

    return Column(
      children: [
        // App header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  buildMockLogo(size: 32),
                  const SizedBox(width: 8),
                  const Text(
                    'MediCare+',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<MedicateProvider>(context, listen: false).setPresentationMode(false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Enter App', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        
        // Canvas Toggle Row for Mobile
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _isDoctorCanvas = false;
                      _focusedScreenIndex = null;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: !_isDoctorCanvas ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Patient Portal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: !_isDoctorCanvas ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _isDoctorCanvas = true;
                      _focusedScreenIndex = null;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: _isDoctorCanvas ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Doctor Portal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _isDoctorCanvas ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Dropdown switcher
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: activeIdx,
                isExpanded: true,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 13),
                items: List.generate(_activeScreens.length, (idx) {
                  return DropdownMenuItem(
                    value: idx,
                    child: Text(_activeScreens[idx]['label']),
                  );
                }),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _focusedScreenIndex = val);
                  }
                },
              ),
            ),
          ),
        ),
        // Active Phone Render
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Center(
              child: buildMockPhoneFrame(
                context,
                label: _activeScreens[activeIdx]['label'],
                child: _activeScreens[activeIdx]['widget'],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Desktop canvas layout matching mock Figma canvas perfectly
  Widget _buildDesktopLayout() {
    return Column(
      children: [
        // 1. TOP HEADER PANEL
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Logo Block
              Row(
                children: [
                  buildMockLogo(size: 40),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MediCare+',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Smart Medicine & Patient Care',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),

              // Segmented Toggle Switcher for Patient/Doctor
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() {
                        _isDoctorCanvas = false;
                        _focusedScreenIndex = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: !_isDoctorCanvas ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: !_isDoctorCanvas
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          'PATIENT CANVAS (15 Screens)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: !_isDoctorCanvas ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        _isDoctorCanvas = true;
                        _focusedScreenIndex = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isDoctorCanvas ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _isDoctorCanvas
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          'DOCTOR CANVAS (12 Screens)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _isDoctorCanvas ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right Navigation Quick Features & standard launch
              Row(
                children: [
                  _headerIconChip(Icons.psychology, 'AI Prediction', const Color(0xFFEEF2FF), const Color(0xFF4F46E5)),
                  const SizedBox(width: 8),
                  _headerIconChip(Icons.mic, 'Voice Assistant', const Color(0xFFFFF7ED), const Color(0xFFEA580C)),
                  const SizedBox(width: 8),
                  _headerIconChip(Icons.camera_alt, 'Scan Medicine', const Color(0xFFFDF2F8), const Color(0xFFDB2777)),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Provider.of<MedicateProvider>(context, listen: false).setPresentationMode(false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
                      );
                    },
                    icon: const Icon(Icons.launch, size: 14, color: Colors.white),
                    label: const Text('Enter Standard App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. CANVAS MAIN SCROLL GRID
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Row 1
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 12),
                  child: Text(
                    _isDoctorCanvas
                        ? 'ROW 1: CLINICAL METRICS & APPOINTMENTS'
                        : 'ROW 1: ONBOARDING & SMART MONITORING',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.2),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_isDoctorCanvas ? 6 : 7, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: GestureDetector(
                          onTap: () => setState(() => _focusedScreenIndex = index),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              buildMockPhoneFrame(
                                context,
                                label: _activeScreens[index]['label'],
                                child: _activeScreens[index]['widget'],
                              ),
                              Positioned(
                                top: 40,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                                  child: const Icon(Icons.zoom_in, size: 16, color: Color(0xFF0EA5E9)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 36),

                // Row 2
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 12),
                  child: Text(
                    _isDoctorCanvas
                        ? 'ROW 2: TELEMETRY, REPORTS & PROFILE'
                        : 'ROW 2: CAREGIVER & INTELLIGENT ALERTS',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.2),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_isDoctorCanvas ? 6 : 8, (index) {
                      final int screenIdx = index + (_isDoctorCanvas ? 6 : 7);
                      return Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: GestureDetector(
                          onTap: () => setState(() => _focusedScreenIndex = screenIdx),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              buildMockPhoneFrame(
                                context,
                                label: _activeScreens[screenIdx]['label'],
                                child: _activeScreens[screenIdx]['widget'],
                              ),
                              Positioned(
                                top: 40,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                                  child: const Icon(Icons.zoom_in, size: 16, color: Color(0xFF0EA5E9)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. FOOTER INFO
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Features Checklist
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Why MediCare+ is Unique?',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _footerFeatureTile('AI predicts missed doses', Icons.check_circle_outline),
                      const SizedBox(width: 16),
                      _footerFeatureTile('Voice & Scan makes it easy', Icons.check_circle_outline),
                      const SizedBox(width: 16),
                      _footerFeatureTile('Smart alerts keep you safe', Icons.check_circle_outline),
                      const SizedBox(width: 16),
                      _footerFeatureTile('Caregiver support you\'re never alone', Icons.check_circle_outline),
                    ],
                  ),
                ],
              ),
              // Right Data Lock
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, color: Color(0xFF10B981), size: 18),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Data. Your Health. Our Priority.',
                          style: TextStyle(color: Color(0xFF065F46), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'End-to-end encrypted & 100% secure',
                          style: TextStyle(color: Color(0xFF047857), fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _headerIconChip(IconData icon, String label, Color bgColor, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _footerFeatureTile(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF22C55E), size: 14),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
      ],
    );
  }

  // Overlay showing the active interactive screen in full phone view
  Widget _buildZoomOverlay(int screenIdx) {
    final activeIdx = screenIdx.clamp(0, _activeScreens.length - 1);
    return Container(
      color: Colors.black87,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () => setState(() => _focusedScreenIndex = null),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Zoom Title Control
              Container(
                width: 330,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _activeScreens[activeIdx]['label'],
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 13),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _focusedScreenIndex = null),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              // Simulated Phone Frame containing live interactive widget
              Container(
                width: 330,
                height: 620,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  child: _activeScreens[activeIdx]['widget'],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
