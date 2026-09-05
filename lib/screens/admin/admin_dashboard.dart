import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/services/services.dart';
import '../auth/role_selection_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  // Navigation Subpage States
  bool _isViewingSilentPatients = false;
  bool _isViewingNoShows = false;
  bool _isViewingDoctors = false;
  bool _isViewingInventory = false;
  bool _isViewingAuditLogs = false;
  bool _isViewingProfile = false;
  bool _isViewingMedicineInteractions = false;
  bool _isViewingAdherenceIssues = false;
  bool _isViewingGeneralSettings = false;
  bool _isViewingNotificationSettings = false;
  bool _isViewingSystemPreferences = false;
  bool _isViewingPrivacySecurity = false;
  bool _isViewingBackupRestore = false;
  bool _isViewingSystemUpdate = false;
  bool _isViewingAbout = false;

  // System Update State
  bool _isCheckingUpdates = false;
  String _systemVersion = 'Version 2.4.0 (Latest)';
  String _updateStatusText = 'Your system is fully up to date with the latest clinical AI models, security patches, and database telemetry drivers.';

  // Low Adherence Patient Data
  final List<Map<String, dynamic>> _lowAdherencePatients = [
    {'name': 'Ramesh Kumar', 'rate': 45, 'meds': 'Amlodipine 5mg, Metformin 500mg', 'missed': '3 doses missed this week', 'doctor': 'Dr. Sarah Connor'},
    {'name': 'Sunita Devi', 'rate': 55, 'meds': 'Atorvastatin 10mg', 'missed': '2 doses missed this week', 'doctor': 'Dr. Reed Richards'},
    {'name': 'Ananya Roy', 'rate': 58, 'meds': 'Lisinopril 10mg', 'missed': '4 doses missed this week', 'doctor': 'Dr. Priya Sharma'},
    {'name': 'Vikram Singh', 'rate': 62, 'meds': 'Pantoprazole 40mg', 'missed': '2 doses missed this week', 'doctor': 'Dr. Stephen Strange'},
    {'name': 'Robert Johnson', 'rate': 68, 'meds': 'Insulin Glargine', 'missed': '1 dose missed this week', 'doctor': 'Dr. Bruce Banner'},
  ];

  // Drug Interaction State
  String _selectedDrugA = 'Aspirin 75mg';
  String _selectedDrugB = 'Ibuprofen 400mg';
  Map<String, String>? _interactionResult;
  final List<Map<String, String>> _flaggedInteractions = [
    {'id': '1', 'patient': 'Ramesh Kumar', 'drugA': 'Aspirin 75mg', 'drugB': 'Ibuprofen 400mg', 'risk': 'High Risk', 'detail': 'Stomach ulcers & gastrointestinal bleeding risk.'},
    {'id': '2', 'patient': 'Sunita Devi', 'drugA': 'Warfarin 5mg', 'drugB': 'Aspirin 81mg', 'risk': 'High Risk', 'detail': 'Severe hemorrhage & internal bleeding risk.'},
    {'id': '3', 'patient': 'Vikram Singh', 'drugA': 'Metformin 500mg', 'drugB': 'CT Contrast Dye', 'risk': 'Moderate Risk', 'detail': 'Risk of lactic acidosis & impaired renal clearance.'},
    {'id': '4', 'patient': 'Ananya Roy', 'drugA': 'Paracetamol 650mg', 'drugB': 'Alcohol', 'risk': 'Moderate Risk', 'detail': 'Severe liver toxicity and acute hepatic injury risk.'},
    {'id': '5', 'patient': 'Rajesh Sharma', 'drugA': 'Lisinopril 10mg', 'drugB': 'Potassium Chloride', 'risk': 'Moderate Risk', 'detail': 'Hyperkalemia and cardiac arrhythmia risk.'},
    {'id': '6', 'patient': 'Meena Patel', 'drugA': 'Atorvastatin 20mg', 'drugB': 'Clarithromycin 500mg', 'risk': 'High Risk', 'detail': 'Rhabdomyolysis & severe muscle breakdown.'},
    {'id': '7', 'patient': 'Amit Verma', 'drugA': 'Cetirizine 10mg', 'drugB': 'Alcohol', 'risk': 'Moderate Risk', 'detail': 'CNS depression and extreme sedation risk.'},
    {'id': '8', 'patient': 'Priya Nair', 'drugA': 'Amoxicillin 500mg', 'drugB': 'Methotrexate 15mg', 'risk': 'Moderate Risk', 'detail': 'Reduced methotrexate clearance & toxicity risk.'},
    {'id': '9', 'patient': 'Deepak Gupta', 'drugA': 'Digoxin 0.25mg', 'drugB': 'Amiodarone 200mg', 'risk': 'High Risk', 'detail': 'Increased digoxin serum levels & digitalis toxicity.'},
  ];

  // Controllers
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    final user = provider.currentUser;

    if (user == null) {
      return RoleSelectionScreen();
    }

    // Subpage Overlays
    if (_isViewingSilentPatients) {
      return _buildSilentPatientsScreen();
    }
    if (_isViewingNoShows) {
      return _buildNoShowsScreen();
    }
    if (_isViewingDoctors) {
      return _buildDoctorsScreen(provider);
    }
    if (_isViewingInventory) {
      return _buildInventoryScreen(provider);
    }
    if (_isViewingAuditLogs) {
      return _buildAuditLogsScreen();
    }
    if (_isViewingProfile) {
      return _buildAdminProfileScreen(user);
    }
    if (_isViewingMedicineInteractions) {
      return _buildMedicineInteractionsScreen(provider);
    }
    if (_isViewingAdherenceIssues) {
      return _buildAdherenceIssuesScreen(provider);
    }
    if (_isViewingGeneralSettings) {
      return _buildGeneralSettingsScreen(provider);
    }
    if (_isViewingNotificationSettings) {
      return _buildNotificationSettingsScreen(provider);
    }
    if (_isViewingSystemPreferences) {
      return _buildSystemPreferencesScreen(provider);
    }
    if (_isViewingPrivacySecurity) {
      return _buildPrivacySecurityScreen(provider);
    }
    if (_isViewingBackupRestore) {
      return _buildBackupRestoreScreen(provider);
    }
    if (_isViewingSystemUpdate) {
      return _buildSystemUpdateScreen(provider);
    }
    if (_isViewingAbout) {
      return _buildAboutAdminPortalScreen(provider);
    }

    final tabs = [
      _buildHomeTab(context, provider, user),
      _buildAiCenterTab(context),
      _buildAlertsTab(context),
      _buildUsersTab(context, provider),
      _buildMoreSettingsTab(context, provider, user),
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
            _buildNavBarItem(0, Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
            _buildNavBarItem(1, Icons.psychology_rounded, Icons.psychology_outlined, 'AI Center'),
            _buildNavBarItem(2, Icons.notifications_active_rounded, Icons.notifications_none_rounded, 'Alerts'),
            _buildNavBarItem(3, Icons.people_rounded, Icons.people_outline_rounded, 'Users'),
            _buildNavBarItem(4, Icons.more_horiz_rounded, Icons.more_horiz_rounded, 'More'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final bool isActive = _currentIndex == index;
    final color = isActive ? const Color(0xFF6366F1) : const Color(0xFF94A3B8); // Purple brand color
    return InkWell(
      onTap: () => setState(() {
        _currentIndex = index;
      }),
      child: SizedBox(
        width: 65,
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
  // TAB 0: ADMIN HOME DASHBOARD
  // ==========================================
  Widget _buildHomeTab(BuildContext context, MedicateProvider provider, UserAccount user) {
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
                    'Good Morning, Admin 👋',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                  Text(
                    "Here's what's happening in your system.",
                    style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF64748B)),
                onPressed: () => setState(() => _currentIndex = 2),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // System Risk Score Gauge Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                // Gauge circle
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('72', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444))),
                        Text('/100', style: GoogleFonts.poppins(fontSize: 8, color: const Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Risk Score',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          'High Risk',
                          style: GoogleFonts.poppins(color: const Color(0xFFEF4444), fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'AI detected anomalies in patient vitals & no-shows.',
                        style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Summary grid cards
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'High-risk Patients',
                  '23',
                  Icons.people_alt,
                  const Color(0xFFEF4444),
                  const Color(0xFFFEE2E2),
                  onTap: () => setState(() => _isViewingSilentPatients = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  'Predicted No-Shows',
                  '17',
                  Icons.calendar_today,
                  const Color(0xFF3B82F6),
                  const Color(0xFFEFF6FF),
                  onTap: () => setState(() => _isViewingNoShows = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'Medicine Alerts',
                  '9',
                  Icons.medication,
                  const Color(0xFFF59E0B),
                  const Color(0xFFFEF3C7),
                  onTap: () => setState(() => _isViewingMedicineInteractions = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  'Low Stock Medicines',
                  '32',
                  Icons.inventory,
                  const Color(0xFF10B981),
                  const Color(0xFFD1FAE5),
                  onTap: () => setState(() => _isViewingInventory = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // AI Recommended Actions Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Recommended Actions',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '3 actions need your attention',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
                ),
                const Divider(color: Colors.white24, height: 20),
                _buildActionBullet('Contact 5 high-risk patients', onTap: () => setState(() => _isViewingSilentPatients = true)),
                _buildActionBullet('Review 9 medicine interactions', onTap: () => setState(() => _isViewingMedicineInteractions = true)),
                _buildActionBullet('Reorder 12 medicines', onTap: () => setState(() => _isViewingInventory = true)),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => setState(() => _currentIndex = 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Review All Actions',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String count, IconData icon, Color color, Color bg, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(backgroundColor: bg, radius: 18, child: Icon(icon, color: color, size: 18)),
            const SizedBox(height: 14),
            Text(count, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
            Text(label, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBullet(String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 14),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                decoration: onTap != null ? TextDecoration.underline : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: AI COMMAND CENTER
  // ==========================================
  Widget _buildAiCenterTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Command Center',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 16),

          // System Intelligence Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Intelligence',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                      ),
                      Text(
                        'Powered by MediCare AI',
                        style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.psychology, color: Color(0xFF6366F1), size: 36),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Insight list
          Text(
            'Top AI Insights',
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 12),

          _buildInsightTile('High Risk Patients', '23', 'Needs immediate attention', Icons.report_problem_rounded, const Color(0xFFEF4444), () {
            setState(() => _isViewingSilentPatients = true);
          }),
          _buildInsightTile('No-Show Predictions', '17', 'May miss appointment', Icons.calendar_month_rounded, const Color(0xFF3B82F6), () {
            setState(() => _isViewingNoShows = true);
          }),
          _buildInsightTile('Medicine Interactions', '9', 'Require review', Icons.warning_amber_rounded, const Color(0xFFF59E0B), () {
            setState(() => _isViewingMedicineInteractions = true);
          }),
          _buildInsightTile('Adherence Issues', '31', 'Low medicine adherence', Icons.check_circle_rounded, const Color(0xFF10B981), () {
            setState(() => _isViewingAdherenceIssues = true);
          }),
        ],
      ),
    );
  }

  Widget _buildInsightTile(String label, String value, String desc, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color, size: 20)),
        title: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        subtitle: Text(desc, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: ALERTS & NOTIFICATIONS FEED
  // ==========================================
  Widget _buildAlertsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Alerts & Notifications',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
        ),
        const SizedBox(height: 16),

        _buildAlertCard('High Risk Patient', 'Ramesh Kumar needs attention', '10 min ago', const Color(0xFFEF4444), const Color(0xFFFEE2E2), onTap: () => setState(() => _isViewingSilentPatients = true)),
        _buildAlertCard('Medicine Interaction', 'Potential interaction detected', '25 min ago', const Color(0xFFF59E0B), const Color(0xFFFEF3C7), onTap: () => setState(() => _isViewingMedicineInteractions = true)),
        _buildAlertCard('Low Stock Alert', 'Amlodipine 5mg is running low', '1 hour ago', const Color(0xFFF59E0B), const Color(0xFFFEF3C7), onTap: () => setState(() => _isViewingInventory = true)),
        _buildAlertCard('System Update', 'System update verified', '2 hours ago', const Color(0xFF3B82F6), const Color(0xFFEFF6FF), onTap: () => setState(() => _isViewingSystemUpdate = true)),
      ],
    );
  }

  Widget _buildAlertCard(String title, String body, String time, Color color, Color bg, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.12)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(backgroundColor: bg, radius: 18, child: Icon(title.contains('System') ? Icons.system_update_rounded : Icons.warning, color: color, size: 16)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                      const SizedBox(height: 2),
                      Text(body, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
                      const SizedBox(height: 6),
                      Text(time, style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 3: USERS DIRECTORY
  // ==========================================
  Widget _buildUsersTab(BuildContext context, MedicateProvider provider) {
    final query = _searchCtrl.text.toLowerCase();
    final list = provider.patients.where((p) => p.name.toLowerCase().contains(query)).toList();

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Users Directory',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 16),

              // Search
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
                        controller: _searchCtrl,
                        style: GoogleFonts.poppins(fontSize: 13),
                        onChanged: (val) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search users...',
                          hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // List of users
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, idx) {
                    final patient = list[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(child: Text('👨')),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(patient.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                                Text('${patient.id}  ·  Patient', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              'Active',
                              style: GoogleFonts.poppins(color: const Color(0xFF10B981), fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Add user floating button
        Positioned(
          bottom: 16,
          left: 20,
          right: 20,
          child: GestureDetector(
            onTap: () => _showAddUserDialog(context, provider),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '+ Add New User',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddUserDialog(BuildContext context, MedicateProvider provider) {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController(text: '30');
    final historyCtrl = TextEditingController(text: 'Normal');
    String gender = 'Male';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add New User', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Name', labelStyle: GoogleFonts.poppins(fontSize: 12))),
              TextField(controller: ageCtrl, decoration: InputDecoration(labelText: 'Age', labelStyle: GoogleFonts.poppins(fontSize: 12))),
              DropdownButtonFormField<String>(
                value: gender,
                onChanged: (val) => gender = val!,
                decoration: InputDecoration(labelText: 'Gender', labelStyle: GoogleFonts.poppins(fontSize: 12)),
                items: ['Male', 'Female'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  final age = int.tryParse(ageCtrl.text) ?? 30;
                  provider.addPatient(nameCtrl.text, age, gender, historyCtrl.text, 'None');
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: Text('Add', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // TAB 4: MORE / SETTINGS HUB
  // ==========================================
  Widget _buildMoreSettingsTab(BuildContext context, MedicateProvider provider, UserAccount user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Admin Profile Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Center(child: Text('👩‍💼', style: TextStyle(fontSize: 30))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Super Admin',
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

          // Administration Section
          _buildSectionHeader('System Administration'),
          const SizedBox(height: 10),
          _buildSettingsOptionTile('Doctors Directory', Icons.medical_services_outlined, () => setState(() => _isViewingDoctors = true)),
          _buildSettingsOptionTile('Medicine Inventory', Icons.inventory_2_outlined, () => setState(() => _isViewingInventory = true)),
          _buildSettingsOptionTile('Drug Interactions Checker', Icons.warning_amber_rounded, () => setState(() => _isViewingMedicineInteractions = true)),
          _buildSettingsOptionTile('Patient Adherence Analytics', Icons.check_circle_outline_rounded, () => setState(() => _isViewingAdherenceIssues = true)),
          _buildSettingsOptionTile('System Audit Logs', Icons.list_alt_rounded, () => setState(() => _isViewingAuditLogs = true)),
          const SizedBox(height: 20),

          // General Settings Section
          _buildSectionHeader('Settings & Preferences'),
          const SizedBox(height: 10),
          _buildSettingsOptionTile('General Settings', Icons.settings_outlined, () => setState(() => _isViewingGeneralSettings = true)),
          _buildSettingsOptionTile('Notification Settings', Icons.notifications_none_rounded, () => setState(() => _isViewingNotificationSettings = true)),
          _buildSettingsOptionTile('System Preferences', Icons.settings_brightness_rounded, () => setState(() => _isViewingSystemPreferences = true)),
          _buildSettingsOptionTile('Privacy & Security', Icons.shield_outlined, () => setState(() => _isViewingPrivacySecurity = true)),
          _buildSettingsOptionTile('Backup & Restore', Icons.cloud_upload_outlined, () => setState(() => _isViewingBackupRestore = true)),
          _buildSettingsOptionTile('System Update', Icons.system_update_rounded, () => setState(() => _isViewingSystemUpdate = true)),
          _buildSettingsOptionTile('About Admin Portal', Icons.info_outline_rounded, () => setState(() => _isViewingAbout = true)),
          _buildSettingsOptionTile('Help & Support', Icons.help_outline_rounded, () => setState(() => _isViewingGeneralSettings = true)),
          const SizedBox(height: 24),

          // Red Logout Card
          InkWell(
            onTap: () {
              provider.logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RoleSelectionScreen()));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFEE2E2)),
              ),
              child: Center(
                child: Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF94A3B8),
          letterSpacing: 1.0,
        ),
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
  // INTERACTIVE DETAIL OVERLAYS
  // ==========================================

  // 1. SILENT PATIENTS SCREEN
  Widget _buildSilentPatientsScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingSilentPatients = false),
        ),
        title: Text('Silent Patients', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gauge
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFEF4444), width: 6),
                    ),
                    child: Center(
                      child: Text(
                        '23',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Silent Patient Detection',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                        ),
                        Text(
                          'AI detects patients who are inactive or unresponsive.',
                          style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'High Risk Patients',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),

            _buildSilentPatientRow('Ramesh Kumar', 'No activity since 15 days'),
            _buildSilentPatientRow('Sunita Devi', 'No activity since 9 days'),
            _buildSilentPatientRow('Vikram Singh', 'No activity since 7 days'),
          ],
        ),
      ),
    );
  }

  Widget _buildSilentPatientRow(String name, String time) {
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
              Text(name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
              Text(time, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(6)),
            child: Text('High Risk', style: GoogleFonts.poppins(color: const Color(0xFFEF4444), fontSize: 8, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 2. PREDICTIVE ANALYTICS SCREEN
  Widget _buildNoShowsScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingNoShows = false),
        ),
        title: Text('Predictive Analytics', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No-Show Prediction',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                  Text(
                    'AI predicts appointments that may be missed.',
                    style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B)),
                  ),
                  const Divider(height: 24),
                  Text(
                    '23%',
                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF3B82F6)),
                  ),
                  Text(
                    'No-show rate this week (down 8% from last week)',
                    style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Top Predicted No-Shows',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),

            _buildNoShowRow('Rahul Kumar', 'May 22, 10:30 AM', '82%'),
            _buildNoShowRow('Neha Verma', 'May 22, 11:00 AM', '74%'),
            _buildNoShowRow('Arjun Patel', 'May 22, 02:30 PM', '68%'),
          ],
        ),
      ),
    );
  }

  Widget _buildNoShowRow(String name, String time, String prob) {
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
              Text(name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
              Text(time, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
            ],
          ),
          Text(prob, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444))),
        ],
      ),
    );
  }

  // 3. DOCTORS DIRECTORY SCREEN
  Widget _buildDoctorsScreen(MedicateProvider provider) {
    final docs = provider.doctors;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingDoctors = false),
        ),
        title: Text('Doctors Directory', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          docs.isEmpty
              ? Center(
                  child: Text(
                    'No doctors found in directory.',
                    style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 80),
                  itemCount: docs.length,
                  itemBuilder: (context, idx) {
                    final doc = docs[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
                      child: Row(
                        children: [
                          const CircleAvatar(child: Text('👩‍⚕️')),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(doc.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                                Text('${doc.specialty}  ·  Fee: \$${doc.consultFee.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Active',
                              style: GoogleFonts.poppins(color: const Color(0xFF10B981), fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => _showAddDoctorDialog(context, provider),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Text('+ Add Doctor', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDoctorDialog(BuildContext context, MedicateProvider provider) {
    final nameCtrl = TextEditingController();
    final specialtyCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final licenseCtrl = TextEditingController();
    final feeCtrl = TextEditingController(text: '500');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add New Doctor', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: 'Doctor Name (e.g. Dr. Jane Smith)', labelStyle: GoogleFonts.poppins(fontSize: 12)),
                ),
                TextField(
                  controller: specialtyCtrl,
                  decoration: InputDecoration(labelText: 'Specialty / Department', labelStyle: GoogleFonts.poppins(fontSize: 12)),
                ),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Email Address', labelStyle: GoogleFonts.poppins(fontSize: 12)),
                ),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: 'Phone Number', labelStyle: GoogleFonts.poppins(fontSize: 12)),
                ),
                TextField(
                  controller: licenseCtrl,
                  decoration: InputDecoration(labelText: 'License Number', labelStyle: GoogleFonts.poppins(fontSize: 12)),
                ),
                TextField(
                  controller: feeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Consultation Fee (\$)', labelStyle: GoogleFonts.poppins(fontSize: 12)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  final fee = double.tryParse(feeCtrl.text.trim()) ?? 500.0;
                  provider.addDoctor(
                    name: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    specialty: specialtyCtrl.text.trim().isEmpty ? 'General Practice' : specialtyCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    licenseNumber: licenseCtrl.text.trim(),
                    consultFee: fee,
                  );
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: Text('Add Doctor', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // 4. MEDICINE INVENTORY SCREEN
  Widget _buildInventoryScreen(MedicateProvider provider) {
    final inventoryItems = provider.inventory;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingInventory = false),
        ),
        title: Text('Medicine Inventory', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          inventoryItems.isEmpty
              ? Center(
                  child: Text(
                    'No medicines found in inventory.',
                    style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 80),
                  itemCount: inventoryItems.length,
                  itemBuilder: (context, idx) {
                    final item = inventoryItems[idx];
                    String tag = 'In Stock';
                    Color tagColor = const Color(0xFF10B981);
                    Color tagBg = const Color(0xFFD1FAE5);

                    if (item.isLowStock) {
                      tag = 'Low';
                      tagColor = const Color(0xFFF59E0B);
                      tagBg = const Color(0xFFFEF3C7);
                    }
                    if (item.stock <= 5) {
                      tag = 'Critical';
                      tagColor = const Color(0xFFEF4444);
                      tagBg = const Color(0xFFFEE2E2);
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
                      child: Row(
                        children: [
                          const CircleAvatar(child: Text('💊')),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                                Text('Stock: ${item.stock} ${item.unit}  ·  ${item.category}', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              tag,
                              style: GoogleFonts.poppins(color: tagColor, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => _showAddMedicineDialog(context, provider),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Text('+ Add Medicine', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMedicineDialog(BuildContext context, MedicateProvider provider) {
    final nameCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'Analgesics');
    final stockCtrl = TextEditingController(text: '50');
    final priceCtrl = TextEditingController(text: '25.00');
    final unitCtrl = TextEditingController(text: 'tablets');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF6366F1)),
              const SizedBox(width: 8),
              Text('Add New Medicine', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Medicine Name (e.g. Paracetamol 500mg)',
                    labelStyle: GoogleFonts.poppins(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryCtrl,
                  decoration: InputDecoration(
                    labelText: 'Category (e.g. Antibiotics, Antacids)',
                    labelStyle: GoogleFonts.poppins(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Stock Quantity',
                    labelStyle: GoogleFonts.poppins(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Price per Unit (\$)',
                    labelStyle: GoogleFonts.poppins(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: unitCtrl,
                  decoration: InputDecoration(
                    labelText: 'Unit (e.g. tablets, capsules, ml)',
                    labelStyle: GoogleFonts.poppins(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isNotEmpty) {
                  final stock = int.tryParse(stockCtrl.text.trim()) ?? 50;
                  final price = double.tryParse(priceCtrl.text.trim()) ?? 25.0;
                  try {
                    await provider.addMedicine(
                      name: name,
                      category: categoryCtrl.text.trim(),
                      stock: stock,
                      price: price,
                      unit: unitCtrl.text.trim(),
                    );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                    }
                    if (mounted) {
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Success: '$name' added to inventory!", style: GoogleFonts.poppins()),
                          backgroundColor: const Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text("Failed to add medicine: $e"), backgroundColor: Colors.red),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text("Please enter a valid medicine name!"), backgroundColor: Colors.orange),
                  );
                }
              },
              child: Text('Add Medicine', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // 5. AUDIT LOGS SCREEN
  Widget _buildAuditLogsScreen() {
    final logs = [
      {'user': 'Admin User', 'action': 'Logged in to the system', 'time': 'May 20, 2025 09:00 AM'},
      {'user': 'Dr. Priya Sharma', 'action': 'Updated patient record', 'time': 'May 20, 2025 08:45 AM'},
      {'user': 'System', 'action': 'Backup completed', 'time': 'May 20, 2025 08:30 AM'},
      {'user': 'Admin User', 'action': 'Changed system settings', 'time': 'May 20, 2025 08:15 AM'},
      {'user': 'Dr. Rahul Verma', 'action': 'Added new prescription', 'time': 'May 20, 2025 08:00 AM'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingAuditLogs = false),
        ),
        title: Text('System Audit Logs', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: logs.length,
        itemBuilder: (context, idx) {
          final log = logs[idx];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(radius: 16, child: Icon(Icons.history_toggle_off_rounded, size: 16)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log['user']!, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                      Text(log['action']!, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF475569))),
                      const SizedBox(height: 4),
                      Text(log['time']!, style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 6. ADMIN PROFILE SCREEN
  Widget _buildAdminProfileScreen(UserAccount user) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingProfile = false),
        ),
        title: Text('Admin Profile', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Center(child: Text('👩‍💼', style: TextStyle(fontSize: 40))),
                  ),
                  const SizedBox(height: 12),
                  Text(user.name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Super Admin', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildProfileDetailItem('Email', 'admin@medicare.com'),
            _buildProfileDetailItem('Phone', '+91 98765 43210'),
            _buildProfileDetailItem('Role', 'Super Admin'),
            _buildProfileDetailItem('Last Login', 'May 20, 2025 09:30 AM'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailItem(String label, String val) {
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

  // 7. MEDICINE INTERACTIONS SCREEN
  Widget _buildMedicineInteractionsScreen(MedicateProvider provider) {
    final result = _interactionResult ?? provider.checkDrugInteraction(_selectedDrugA, _selectedDrugB);
    final status = result['status'] ?? 'No Known Interaction';
    final details = result['details'] ?? '';
    
    Color statusColor = const Color(0xFF10B981);
    Color statusBg = const Color(0xFFD1FAE5);
    IconData statusIcon = Icons.check_circle_outline_rounded;

    if (status == 'High Risk') {
      statusColor = const Color(0xFFEF4444);
      statusBg = const Color(0xFFFEE2E2);
      statusIcon = Icons.warning_rounded;
    } else if (status == 'Moderate Risk') {
      statusColor = const Color(0xFFF59E0B);
      statusBg = const Color(0xFFFEF3C7);
      statusIcon = Icons.error_outline_rounded;
    } else if (status == 'Select Drugs') {
      statusColor = const Color(0xFF3B82F6);
      statusBg = const Color(0xFFEFF6FF);
      statusIcon = Icons.info_outline_rounded;
    }

    final availableMeds = [
      'Aspirin 75mg',
      'Ibuprofen 400mg',
      'Warfarin 5mg',
      'Metformin 500mg',
      'CT Contrast Dye',
      'Paracetamol 650mg',
      'Alcohol',
      'Lisinopril 10mg',
      'Potassium Chloride',
      'Atorvastatin 20mg',
      'Clarithromycin 500mg',
      'Cetirizine 10mg',
      'Amoxicillin 500mg',
      'Methotrexate 15mg',
      'Digoxin 0.25mg',
      'Amiodarone 200mg',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingMedicineInteractions = false),
        ),
        title: Text(
          'Medicine Interactions',
          style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Interactive Drug Checker Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFFEEF2FF),
                        radius: 18,
                        child: Icon(Icons.medication_liquid_rounded, color: Color(0xFF6366F1), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Drug Interaction Checker',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                          ),
                          Text(
                            'Check clinical contraindications between two medications',
                            style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Drug A Dropdown
                  Text('Primary Drug (Drug A)', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF475569))),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: availableMeds.contains(_selectedDrugA) ? _selectedDrugA : availableMeds.first,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                    items: availableMeds.map((med) => DropdownMenuItem(value: med, child: Text(med, style: GoogleFonts.poppins(fontSize: 12)))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedDrugA = val;
                          _interactionResult = provider.checkDrugInteraction(_selectedDrugA, _selectedDrugB);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // Drug B Dropdown
                  Text('Secondary Drug (Drug B)', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF475569))),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: availableMeds.contains(_selectedDrugB) ? _selectedDrugB : availableMeds[1],
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                    items: availableMeds.map((med) => DropdownMenuItem(value: med, child: Text(med, style: GoogleFonts.poppins(fontSize: 12)))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedDrugB = val;
                          _interactionResult = provider.checkDrugInteraction(_selectedDrugA, _selectedDrugB);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 18),

                  // Result Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(statusIcon, color: statusColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              status,
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: statusColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          details,
                          style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF334155), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Flagged Patient Interactions',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '${_flaggedInteractions.length} Pending',
                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD97706)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // List of flagged interactions
            _flaggedInteractions.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Text('All flagged interactions have been resolved!', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF10B981))),
                  )
                : Column(
                    children: _flaggedInteractions.map((item) {
                      final isHigh = item['risk'] == 'High Risk';
                      final badgeColor = isHigh ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
                      final badgeBg = isHigh ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(radius: 14, child: Text('👤', style: TextStyle(fontSize: 12))),
                                    const SizedBox(width: 8),
                                    Text(
                                      item['patient']!,
                                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
                                  child: Text(
                                    item['risk']!,
                                    style: GoogleFonts.poppins(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Combo: ${item['drugA']} + ${item['drugB']}',
                              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['detail']!,
                              style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    side: const BorderSide(color: Color(0xFF6366F1)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _flaggedInteractions.removeWhere((x) => x['id'] == item['id']);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Resolved interaction for ${item['patient']}. Doctor notified.')),
                                    );
                                  },
                                  child: Text('Resolve & Notify', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  // 8. PATIENT ADHERENCE ANALYTICS SCREEN
  Widget _buildAdherenceIssuesScreen(MedicateProvider provider) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingAdherenceIssues = false),
        ),
        title: Text(
          'Medication Adherence Analytics',
          style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Adherence Score Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF59E0B), width: 8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('78%', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                          Text('Adherence', style: GoogleFonts.poppins(fontSize: 8, color: const Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'System Adherence Overview',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '31 patients require intervention for non-compliance or missed medication doses.',
                          style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Metrics Summary Grid
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF1F5F9))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('31', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444))),
                        Text('Low Adherence (<70%)', style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF1F5F9))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('14', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B))),
                        Text('Missed Doses Today', style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF1F5F9))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('85', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                        Text('High Adherence', style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Patient List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Critical Low Adherence Patients',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                Text(
                  '${_lowAdherencePatients.length} Shown',
                  style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Low Adherence Patient Cards
            _lowAdherencePatients.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Text('All adherence reminders & interventions completed!', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF10B981))),
                  )
                : Column(
                    children: _lowAdherencePatients.map((patient) {
                      final int rate = patient['rate'] as int;
                      final Color badgeColor = rate < 50 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
                      final Color badgeBg = rate < 50 ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(radius: 14, child: Text('👤', style: TextStyle(fontSize: 12))),
                                    const SizedBox(width: 8),
                                    Text(
                                      patient['name'] as String,
                                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
                                  child: Text(
                                    '$rate% Adherence',
                                    style: GoogleFonts.poppins(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Medications: ${patient['meds']}',
                              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF475569)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Status: ${patient['missed']}  ·  Doctor: ${patient['doctor']}',
                              style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    side: const BorderSide(color: Color(0xFF6366F1)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Automated reminder sent to ${patient['name']}.')),
                                    );
                                  },
                                  child: Text('Send Reminder', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6366F1),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _lowAdherencePatients.removeWhere((x) => x['name'] == patient['name']);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Alert dispatched to ${patient['doctor']} for ${patient['name']}.')),
                                    );
                                  },
                                  child: Text('Alert Doctor', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SETTINGS & SYSTEM SUBPAGES
  // ==========================================

  // 9. GENERAL SETTINGS SCREEN
  Widget _buildGeneralSettingsScreen(MedicateProvider provider) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingGeneralSettings = false),
        ),
        title: Text('General Settings', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingsCard(
              title: 'Portal Information',
              children: [
                _buildTextFieldTile('Portal Name', 'Medicate Enterprise Admin Hub'),
                _buildTextFieldTile('Admin Support Contact', 'admin-support@medicate.com'),
                _buildDropdownTile('System Language', ['English (US)', 'Spanish', 'French', 'Hindi']),
                _buildDropdownTile('Timezone', ['UTC+05:30 (IST)', 'UTC+00:00 (GMT)', 'UTC-05:00 (EST)']),
              ],
            ),
            const SizedBox(height: 20),
            _buildSettingsCard(
              title: 'System Maintenance & Mode',
              children: [
                _buildSwitchTile('Maintenance Mode', 'Temporarily restrict portal access to Admins', provider.isMaintenanceMode, (v) {
                  provider.setMaintenanceMode(v);
                }),
                _buildSwitchTile('Debug Telemetry Logging', 'Capture detailed API network logs', provider.isDebugTelemetryLogging, (v) {
                  provider.setDebugTelemetryLogging(v);
                }),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('General settings saved successfully!', style: GoogleFonts.poppins()), backgroundColor: const Color(0xFF10B981)),
                );
              },
              child: Text('Save General Settings', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // 10. NOTIFICATION SETTINGS SCREEN
  Widget _buildNotificationSettingsScreen(MedicateProvider provider) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingNotificationSettings = false),
        ),
        title: Text('Notification Settings', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSettingsCard(
              title: 'Communication Channels',
              children: [
                _buildSwitchTile('Email Notifications', 'Send system digest and critical updates via Email', provider.emailNotifications, (v) => provider.setEmailNotifications(v)),
                _buildSwitchTile('SMS Alerts Broadcast', 'Send urgent SMS notifications to staff & patients', provider.smsAlertsBroadcast, (v) => provider.setSmsAlertsBroadcast(v)),
                _buildSwitchTile('Push Notifications', 'Real-time in-app alerts and browser popups', provider.pushNotifications, (v) => provider.setPushNotifications(v)),
              ],
            ),
            const SizedBox(height: 20),
            _buildSettingsCard(
              title: 'Clinical Trigger Alerts',
              children: [
                _buildSwitchTile('Low Adherence Alerts', 'Alert when patient misses > 2 consecutive doses', provider.lowAdherenceAlerts, (v) => provider.setLowAdherenceAlerts(v)),
                _buildSwitchTile('High-Risk Drug Contraindications', 'Flag high-risk drug interaction combinations', provider.highRiskContraindications, (v) => provider.setHighRiskContraindications(v)),
                _buildSwitchTile('Low Stock Inventory Warnings', 'Alert when inventory stock reaches minimum threshold', provider.lowStockWarnings, (v) => provider.setLowStockWarnings(v)),
                _buildSwitchTile('Weekly Performance Summary', 'Email weekly admin compliance digest', provider.weeklyPerformanceSummary, (v) => provider.setWeeklyPerformanceSummary(v)),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notification preferences updated!', style: GoogleFonts.poppins()), backgroundColor: const Color(0xFF10B981)),
                );
              },
              child: Text('Save Notification Preferences', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // 11. SYSTEM PREFERENCES SCREEN
  Widget _buildSystemPreferencesScreen(MedicateProvider provider) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingSystemPreferences = false),
        ),
        title: Text('System Preferences', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSettingsCard(
              title: 'Appearance & UI Theme',
              children: [
                _buildSwitchTile('Dark Mode Theme', 'Switch application between dark and light themes', provider.themeMode == ThemeMode.dark, (v) {
                  provider.toggleTheme();
                  setState(() {});
                }),
                _buildSwitchTile('Presentation Demo Mode', 'Display live telemetry simulations and mock metrics', provider.isPresentationMode, (v) {
                  provider.setPresentationMode(v);
                  setState(() {});
                }),
              ],
            ),
            const SizedBox(height: 20),
            _buildSettingsCard(
              title: 'Performance & Security Timeout',
              children: [
                _buildDropdownTile('Auto Refresh Frequency', ['5 Seconds (Realtime)', '15 Seconds', '30 Seconds', '1 Minute']),
                _buildDropdownTile('Session Auto-Lock', ['15 Minutes', '30 Minutes', '1 Hour', 'Never']),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('System preferences updated!', style: GoogleFonts.poppins()), backgroundColor: const Color(0xFF10B981)),
                );
              },
              child: Text('Save System Preferences', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // 12. PRIVACY & SECURITY SCREEN
  Widget _buildPrivacySecurityScreen(MedicateProvider provider) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingPrivacySecurity = false),
        ),
        title: Text('Privacy & Security', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSettingsCard(
              title: 'Authentication Security',
              children: [
                _buildSwitchTile('Two-Factor Authentication (2FA)', 'Require OTP verification during admin sign-in', provider.twoFactorAuth, (v) => provider.setTwoFactorAuth(v)),
                _buildSwitchTile('Biometric Authentication', 'Enable Fingerprint/FaceID for quick access', provider.biometricAuth, (v) => provider.setBiometricAuth(v)),
                _buildSwitchTile('Enforce Password Rotation', 'Prompt password update every 90 days', provider.enforcePasswordRotation, (v) => provider.setEnforcePasswordRotation(v)),
              ],
            ),
            const SizedBox(height: 20),
            _buildSettingsCard(
              title: 'Data Compliance & Encryption',
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Data Encryption Standard', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                  subtitle: Text('AES-256 Bit GCM Encryption active', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF10B981))),
                  trailing: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('HIPAA & GDPR Compliance', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                  subtitle: Text('Compliant medical data vault', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF10B981))),
                  trailing: const Icon(Icons.verified_user, color: Color(0xFF10B981), size: 18),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Privacy & security settings saved!', style: GoogleFonts.poppins()), backgroundColor: const Color(0xFF10B981)),
                );
              },
              child: Text('Save Security Settings', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // 13. BACKUP & RESTORE SCREEN
  Widget _buildBackupRestoreScreen(MedicateProvider provider) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => setState(() => _isViewingBackupRestore = false),
        ),
        title: Text('Backup & Restore', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSettingsCard(
              title: 'Cloud Backup Status',
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Last Cloud Backup', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                  subtitle: Text('Today at 02:00 AM · Size: 48.5 MB', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                  trailing: const Icon(Icons.cloud_done_rounded, color: Color(0xFF3B82F6), size: 22),
                ),
                _buildSwitchTile('Automated Daily Backup', 'Schedule nightly automated snapshots to cloud storage', provider.automatedDailyBackup, (v) => provider.setAutomatedDailyBackup(v)),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Manual Backup & Restoration', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.backup_rounded, color: Colors.white, size: 18),
                    label: Text('Create Instant Cloud Backup', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () async {
                      await provider.addNotification("Manual system backup created by administrator.");
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Instant cloud backup created successfully!', style: GoogleFonts.poppins()), backgroundColor: const Color(0xFF10B981)),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      side: const BorderSide(color: Color(0xFF6366F1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.restore_rounded, color: Color(0xFF6366F1), size: 18),
                    label: Text('Restore System Snapshot', style: GoogleFonts.poppins(color: const Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Text('Restore System Data?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                          content: Text('This will restore all patient, doctor, and inventory records from the latest valid cloud backup.', style: GoogleFonts.poppins(fontSize: 12)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey))),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                              onPressed: () {
                                Navigator.pop(ctx);
                                provider.initDatabase();
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('System state successfully restored from snapshot!', style: GoogleFonts.poppins()), backgroundColor: const Color(0xFF10B981)),
                                );
                              },
                              child: Text('Confirm Restore', style: GoogleFonts.poppins(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 14. SYSTEM UPDATE SCREEN
  Widget _buildSystemUpdateScreen(MedicateProvider provider) {
    final isChecking = provider.isCheckingUpdates;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() => _isViewingSystemUpdate = false);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
            onPressed: () => setState(() => _isViewingSystemUpdate = false),
          ),
          title: Text('System Update & Telemetry', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Main Update Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: isChecking ? const Color(0xFFEEF2FF) : const Color(0xFFECFDF5),
                      child: isChecking
                          ? const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(color: Color(0xFF6366F1), strokeWidth: 3),
                            )
                          : const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 40),
                    ),
                    const SizedBox(height: 16),
                    Text('Medicate Admin Platform', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isChecking ? const Color(0xFFEEF2FF) : const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        provider.systemVersion,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isChecking ? const Color(0xFF6366F1) : const Color(0xFF10B981),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.updateProgressStatus,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B), height: 1.4),
                    ),
                    if (isChecking) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: provider.updateProgress > 0 ? provider.updateProgress : null,
                          backgroundColor: const Color(0xFFE2E8F0),
                          color: const Color(0xFF6366F1),
                          minHeight: 6,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        disabledBackgroundColor: const Color(0xFFA5B4FC),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: isChecking
                          ? null
                          : () async {
                              await provider.performSystemUpdateCheck();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('System update check complete! ${provider.systemVersion}', style: GoogleFonts.poppins()),
                                    backgroundColor: const Color(0xFF10B981),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(isChecking ? Icons.sync_rounded : Icons.system_update_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isChecking ? 'Checking Telemetry Servers...' : 'Check & Apply Updates',
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Telemetry & Environment Info Card
              _buildSettingsCard(
                title: 'System Environment & Telemetry Specs',
                children: [
                  _buildSystemInfoRow('Platform Build', provider.systemVersion, Icons.code_rounded),
                  _buildSystemInfoRow('Last Verified Sync', provider.lastUpdateCheck, Icons.access_time_rounded),
                  _buildSystemInfoRow('Clinical AI Engine', 'v4.2 (Deep Diagnostic Neural Net)', Icons.psychology_rounded),
                  _buildSystemInfoRow('Security Accreditation', 'HIPAA & GDPR Compliant (AES-256)', Icons.security_rounded),
                  _buildSystemInfoRow('Telemetry Pipeline', 'Firestore Real-time Stream Drivers', Icons.cloud_sync_rounded),
                ],
              ),

              const SizedBox(height: 20),

              // Version Release Notes & History
              _buildSettingsCard(
                title: 'Recent System Release Notes',
                children: [
                  _buildReleaseNoteTile('Version 2.4.1 (Current)', 'Latest release featuring real-time drug-drug contraindication engine, Bluetooth ECG telemetry fixes, and improved notification latency.', 'May 2025'),
                  _buildReleaseNoteTile('Version 2.4.0', 'Introduced Admin Telemetry Hub, automated prescription safety validation, and dark mode UI enhancement.', 'Apr 2025'),
                  _buildReleaseNoteTile('Version 2.3.9', 'Added silent alert emergency dispatch, patient adherence tracking, and vaccine record sync.', 'Mar 2025'),
                ],
              ),

              const SizedBox(height: 20),

              // Update Preferences
              _buildSettingsCard(
                title: 'Update Preferences',
                children: [
                  _buildSwitchTile('Auto-Install Security Patches', 'Automatically apply critical security updates', provider.autoInstallSecurityPatches, (v) => provider.setAutoInstallSecurityPatches(v)),
                  _buildSwitchTile('Beta Release Channel', 'Opt in to test upcoming diagnostic telemetry tools', provider.betaReleaseChannel, (v) => provider.setBetaReleaseChannel(v)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFFF1F5F9),
            child: Icon(icon, size: 14, color: const Color(0xFF475569)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B))),
          ),
          Text(value, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildReleaseNoteTile(String title, String description, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
              Text(date, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(height: 4),
          Text(description, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B), height: 1.3)),
        ],
      ),
    );
  }

  // 15. ABOUT ADMIN PORTAL SCREEN
  Widget _buildAboutAdminPortalScreen(MedicateProvider provider) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() => _isViewingAbout = false);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
            onPressed: () => setState(() => _isViewingAbout = false),
          ),
          title: Text('About Admin Portal', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_hospital_rounded, color: Color(0xFF6366F1), size: 44),
                    ),
                    const SizedBox(height: 16),
                    Text('SmartMed Medicate', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                    Text('Clinical AI & Patient Telemetry Suite', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
                      child: Text(provider.systemVersion, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildSettingsCard(
                title: 'System Information',
                children: [
                  _buildSystemInfoRow('Application Version', provider.systemVersion, Icons.info_outline_rounded),
                  _buildSystemInfoRow('Target Environment', 'Production Clinical Cloud', Icons.cloud_outlined),
                  _buildSystemInfoRow('Framework', 'Flutter 3.44 (Dart 3.12)', Icons.flutter_dash_rounded),
                  _buildSystemInfoRow('Database Storage', 'Google Cloud Firestore', Icons.storage_rounded),
                  _buildSystemInfoRow('Authentication', 'Firebase Auth (Role-Based Access)', Icons.lock_outline_rounded),
                ],
              ),

              const SizedBox(height: 20),

              _buildSettingsCard(
                title: 'Security & Compliance',
                children: [
                  _buildSystemInfoRow('Data Encryption', 'AES-256 (In-transit & At-rest)', Icons.enhanced_encryption_rounded),
                  _buildSystemInfoRow('Regulatory Standard', 'HIPAA, HITECH & GDPR Compliant', Icons.verified_user_rounded),
                  _buildSystemInfoRow('Audit Logging', 'Immutable Log Stream Active', Icons.receipt_long_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Card Builder Widgets
  Widget _buildSettingsCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeTrackColor: const Color(0xFF6366F1),
      activeThumbColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
    );
  }

  Widget _buildTextFieldTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        style: GoogleFonts.poppins(fontSize: 12),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
        ),
      ),
    );
  }

  Widget _buildDropdownTile(String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: options.first,
        style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
        ),
        items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
        onChanged: (val) {},
      ),
    );
  }
}
