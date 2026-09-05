import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ==========================================
// SHARED UI HELPERS FOR DOCTOR CANVAS
// ==========================================

Widget buildDocPhoneFrame(BuildContext context, {
  required String label,
  required Widget child,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
          ),
        ),
      ),
      Container(
        width: 320,
        height: 640,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: child,
        ),
      ),
    ],
  );
}

// ==========================================
// 1. DOCTOR LOGIN / ONBOARDING
// ==========================================
class DoctorLoginMockView extends StatelessWidget {
  const DoctorLoginMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              // Doctor Onboarding Illustration
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEFF6FF),
                    border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2), width: 2),
                  ),
                  child: const Center(
                    child: Text('👨‍⚕️', style: TextStyle(fontSize: 70)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Doctor Portal',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
              Text(
                'Smart Care, Better Health',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 36),

              // Inputs
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF94A3B8)),
                  labelText: 'Email or Doctor ID',
                  labelStyle: GoogleFonts.poppins(fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF94A3B8)),
                  suffixIcon: const Icon(Icons.visibility_off_outlined, color: Color(0xFF94A3B8)),
                  labelText: 'Password',
                  labelStyle: GoogleFonts.poppins(fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF2563EB),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Login Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Login',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'or continue with fingerprint scan',
                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 12),
              const Icon(Icons.fingerprint, size: 36, color: Color(0xFF2563EB)),
              const SizedBox(height: 30),
              Text(
                'Secure login for authorized doctors only',
                style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. DOCTOR HOME DASHBOARD
// ==========================================
class DoctorHomeMockView extends StatelessWidget {
  const DoctorHomeMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Color(0xFF1E293B)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications_active, color: Colors.redAccent),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, Dr. Priya Sharma 👋',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            Text(
              'Good Morning!',
              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),

            // AI Clinical Alert Card
            Container(
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
            const SizedBox(height: 16),

            // Grid counters
            Row(
              children: [
                Expanded(
                  child: _buildCountTile('Total Patients', '1,245', '+18 this month', Icons.people_alt, const Color(0xFF3B82F6)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCountTile('Today\'s Appt.', '12', '3 upcoming', Icons.calendar_today, const Color(0xFF10B981)),
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
            const SizedBox(height: 20),

            // Today's Appointments Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Appointments',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                Text(
                  'View all',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildAppointmentItem('Arjun Patel', '09:30 AM', 'Follow up', '👨'),
            _buildAppointmentItem('Neha Verma', '11:00 AM', 'Consultation', '👩'),
            _buildAppointmentItem('Rahul Kumar', '12:30 PM', 'Follow up', '👨'),
            _buildAppointmentItem('Pooja Singh', '02:00 PM', 'Consultation', '👩'),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildDocNavBar(0),
    );
  }

  Widget _buildCountTile(String label, String value, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
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
}

// ==========================================
// 3. PATIENTS LIST
// ==========================================
class DoctorPatientsMockView extends StatelessWidget {
  const DoctorPatientsMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Patients', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 40,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xFF94A3B8), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Search patients...',
                          style: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 12),
                        ),
                      ),
                      const Icon(Icons.filter_list, color: Color(0xFF2563EB), size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Patient list
                Expanded(
                  child: ListView(
                    children: [
                      _buildPatientRow('Rahul Kumar', 'PID12345', '32 yrs, Male', 'Hypertension', '👨'),
                      _buildPatientRow('Neha Verma', 'PID12346', '28 yrs, Female', 'Diabetes', '👩'),
                      _buildPatientRow('Arjun Patel', 'PID12347', '45 yrs, Male', 'Thyroid', '👨'),
                      _buildPatientRow('Pooja Singh', 'PID12348', '30 yrs, Female', 'Asthma', '👩'),
                      _buildPatientRow('Vikram Mehta', 'PID12349', '50 yrs, Male', 'Heart Disease', '👨'),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Add Patient Button Floating
          Positioned(
            bottom: 16,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(12),
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
        ],
      ),
      bottomNavigationBar: _buildDocNavBar(1),
    );
  }

  Widget _buildPatientRow(String name, String pid, String ageGender, String status, String emoji) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: const Color(0xFFEFF6FF), child: Text(emoji)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                Row(
                  children: [
                    Text(pid, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                    const SizedBox(width: 8),
                    Text('•  $ageGender', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: Text(
              status,
              style: GoogleFonts.poppins(color: const Color(0xFF475569), fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. PATIENT DETAILS
// ==========================================
class DoctorPatientDetailsMockView extends StatelessWidget {
  const DoctorPatientDetailsMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
        title: Text('Patient Details', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.edit_outlined, color: Color(0xFF2563EB)),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white24,
                        child: Text('👨', style: TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rahul Kumar',
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Text('PID12345', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10)),
                                const SizedBox(width: 8),
                                Text('•  32 yrs, Male', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                              child: Text('Hypertension', style: GoogleFonts.poppins(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tabs Overview / Vitals
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTextTab('Overview', true),
                    _buildTextTab('Vitals', false),
                    _buildTextTab('History', false),
                    _buildTextTab('Reports', false),
                  ],
                ),
                const SizedBox(height: 20),

                // About section
                Text('About', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.phone_outlined, '+91 98765 43210'),
                _buildInfoRow(Icons.email_outlined, 'rahulkumar@email.com'),
                _buildInfoRow(Icons.location_on_outlined, 'Hyderabad, India'),
                const SizedBox(height: 20),

                // Current Medications
                Text('Current Medications', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                const SizedBox(height: 8),
                _buildMedicationTile('Amlodipine 5mg', 'Once daily - After food', const Color(0xFFFCA5A5)),
                _buildMedicationTile('Telmisartan 40mg', 'Once daily - After food', const Color(0xFFFCA5A5)),
                const SizedBox(height: 80),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text('+ New Prescription', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextTab(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFEFF6FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          color: active ? const Color(0xFF2563EB) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
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

  Widget _buildMedicationTile(String name, String sig, Color barColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(width: 4, height: 28, color: barColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                Text(sig, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

// ==========================================
// 5. APPOINTMENTS LIST
// ==========================================
class DoctorAppointmentsMockView extends StatelessWidget {
  const DoctorAppointmentsMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Appointments', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAppointmentTab('Today', true),
                    _buildAppointmentTab('Upcoming', false),
                    _buildAppointmentTab('Completed', false),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      _buildScheduleTile('Arjun Patel', '09:30 AM', 'Follow up', 'Confirmed', const Color(0xFF10B981), const Color(0xFFD1FAE5)),
                      _buildScheduleTile('Neha Verma', '11:00 AM', 'Consultation', 'Confirmed', const Color(0xFF10B981), const Color(0xFFD1FAE5)),
                      _buildScheduleTile('Rahul Kumar', '12:30 PM', 'Follow up', 'Confirmed', const Color(0xFF10B981), const Color(0xFFD1FAE5)),
                      _buildScheduleTile('Pooja Singh', '02:00 PM', 'Consultation', 'Pending', const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
                      _buildScheduleTile('Vikram Mehta', '03:30 PM', 'Consultation', 'Pending', const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text('+ New Appointment', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildDocNavBar(2),
    );
  }

  Widget _buildAppointmentTab(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2563EB) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: active ? Colors.transparent : const Color(0xFFCBD5E1)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: active ? Colors.white : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildScheduleTile(String name, String time, String type, String status, Color color, Color bg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFF1F5F9),
            child: Icon(Icons.person, color: const Color(0xFF64748B), size: 18),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
                child: Text(status, style: GoogleFonts.poppins(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 6. NEW PRESCRIPTION
// ==========================================
class DoctorNewPrescriptionMockView extends StatelessWidget {
  const DoctorNewPrescriptionMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
        title: Text('New Prescription', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient header strip
                Row(
                  children: [
                    const CircleAvatar(radius: 18, child: Text('👨')),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rahul Kumar', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                        Text('PID12345  ·  32 yrs, Male', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Diagnosis
                Text('Diagnosis', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Text('Essential Hypertension', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1E293B))),
                ),
                const SizedBox(height: 20),

                // Medicines List
                Text('Medicines', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                const SizedBox(height: 8),
                _buildNewMedTile('Amlodipine 5mg', '1 Tablet  ·  Once daily  ·  After food'),
                _buildNewMedTile('Telmisartan 40mg', '1 Tablet  ·  Once daily  ·  After food'),
                
                const SizedBox(height: 8),
                Text(
                  '+ Add Medicine',
                  style: GoogleFonts.poppins(color: const Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 20),

                // Duration
                Text('Duration', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Text('30 Days', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1E293B))),
                ),
                const SizedBox(height: 20),

                // Instructions
                Text('Instructions', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Text('Take medicines regularly at the same time.', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1E293B))),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text('Save Prescription', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewMedTile(String name, String details) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
              Text(details, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
            ],
          ),
          const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
        ],
      ),
    );
  }
}

// ==========================================
// 7. VITALS MONITORING
// ==========================================
class DoctorVitalsMockView extends StatelessWidget {
  const DoctorVitalsMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
        title: Text('Vitals Monitoring', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Patient details row
            Row(
              children: [
                const CircleAvatar(radius: 18, child: Text('👨')),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rahul Kumar', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                    Text('PID12345', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time Selector Day / Week / Month
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

            // Vital Grid
            Row(
              children: [
                Expanded(child: _buildVitalMiniCard('Blood Pressure', '120/80', 'mmHg', 'Normal', const Color(0xFF10B981))),
                const SizedBox(width: 12),
                Expanded(child: _buildVitalMiniCard('Heart Rate', '72', 'bpm', 'Normal', const Color(0xFFEF4444))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildVitalMiniCard('Blood Glucose', '98', 'mg/dL', 'Normal', const Color(0xFF3B82F6))),
                const SizedBox(width: 12),
                Expanded(child: _buildVitalMiniCard('Weight', '72', 'kg', 'Normal', const Color(0xFF8B5CF6))),
              ],
            ),
            const SizedBox(height: 24),

            // View all vitals button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2563EB)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text('View All Vitals', style: GoogleFonts.poppins(color: const Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          color: active ? const Color(0xFF1E293B) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildVitalMiniCard(String label, String value, String unit, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
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
}

// ==========================================
// 8. AI CLINICAL ALERTS
// ==========================================
class DoctorAlertsMockView extends StatelessWidget {
  const DoctorAlertsMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
        title: Text('AI Clinical Alerts', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildAlertCard(
              'High Blood Pressure',
              'Rahul Kumar\'s BP has increased compared to previous 3 readings.',
              '10 min ago',
              const Color(0xFFEF4444),
              const Color(0xFFFEE2E2),
            ),
            const SizedBox(height: 12),
            _buildAlertCard(
              'Missed Medicine',
              'Neha Verma missed a dose of Telmisartan 40mg.',
              '1 hour ago',
              const Color(0xFFF59E0B),
              const Color(0xFFFEF3C7),
            ),
            const SizedBox(height: 12),
            _buildAlertCard(
              'Abnormal Vitals',
              'Pooja Singh\'s blood glucose level is higher than normal.',
              '2 hours ago',
              const Color(0xFF3B82F6),
              const Color(0xFFEFF6FF),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2563EB)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text('View All Alerts', style: GoogleFonts.poppins(color: const Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(String title, String desc, String time, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(Icons.warning, color: color, size: 16),
              ),
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
}

// ==========================================
// 9. NOTIFICATIONS LIST
// ==========================================
class DoctorNotificationsMockView extends StatelessWidget {
  const DoctorNotificationsMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
        title: Text('Notifications', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildNotificationRow(context, 'Appointment Reminder', 'You have 3 appointments today starting at 09:30 AM.', '10 min ago', Icons.calendar_today, const Color(0xFF3B82F6)),
          _buildNotificationRow(context, 'Missed Medicine Alert', 'Rahul Kumar missed a dose of Amlodipine 5mg.', '30 min ago', Icons.warning_amber_rounded, const Color(0xFFEF4444)),
          _buildNotificationRow(context, 'Abnormal Vitals Alert', 'Pooja Singh\'s BP is higher than normal.', '1 hour ago', Icons.favorite_border, const Color(0xFFEF4444)),
          _buildNotificationRow(context, 'New Prescription', 'Neha Verma\'s prescription has been updated.', '2 hours ago', Icons.description_outlined, const Color(0xFF10B981)),
          _buildNotificationRow(context, 'System Update', 'System update completed successfully. Version 2.4.1 active.', '3 hours ago', Icons.system_update_rounded, const Color(0xFF8B5CF6), onTap: () => _showSystemUpdateModal(context)),
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

  Widget _buildNotificationRow(BuildContext context, String title, String body, String time, IconData icon, Color color, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
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
}

// ==========================================
// 10. REPORTS DASHBOARD
// ==========================================
class DoctorReportsMockView extends StatelessWidget {
  const DoctorReportsMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
        title: Text('Reports', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildReportOption('Lab Reports', 'View patient lab test reports', Icons.science_outlined),
          _buildReportOption('Prescription History', 'View all prescriptions', Icons.assignment_outlined),
          _buildReportOption('Vitals History', 'View historical vitals data', Icons.trending_up),
          _buildReportOption('Medicine Adherence', 'Check medicine intake history', Icons.done_all),
          _buildReportOption('Download Reports', 'Download and share reports', Icons.download_outlined),
        ],
      ),
    );
  }

  Widget _buildReportOption(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: const Color(0xFFF1F5F9), child: Icon(icon, color: const Color(0xFF475569), size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

// ==========================================
// 11. DOCTOR PROFILE
// ==========================================
class DoctorProfileMockView extends StatelessWidget {
  const DoctorProfileMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
        title: Text('Profile', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(
                      child: Text('👩‍⚕️', style: TextStyle(fontSize: 40)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Dr. Priya Sharma',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Cardiologist',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    'MBBS, MD (Cardiology)\nReg. No. TS/76845',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.white60, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile info items
            Text('Profile Information', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
            const SizedBox(height: 12),
            _buildProfileInfoItem('Clinic / Hospital', 'Care Health Clinic'),
            _buildProfileInfoItem('Mobile Number', '+91 98765 43210'),
            _buildProfileInfoItem('Email', 'priya.sharma@medicare.com'),
            _buildProfileInfoItem('Availability', 'Mon - Sat (09:00 AM - 06:00 PM)'),
          ],
        ),
      ),
      bottomNavigationBar: _buildDocNavBar(3),
    );
  }

  Widget _buildProfileInfoItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
          Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        ],
      ),
    );
  }
}

// ==========================================
// 12. SETTINGS
// ==========================================
class DoctorSettingsMockView extends StatelessWidget {
  const DoctorSettingsMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
        title: Text('Settings', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsOption(Icons.person_outline, 'Edit Profile', false),
          _buildSettingsOption(Icons.lock_outline, 'Change Password', false),
          _buildSettingsOption(Icons.notifications_none_outlined, 'Notification Settings', false),
          _buildSettingsOption(Icons.privacy_tip_outlined, 'Privacy Policy', false),
          _buildSettingsOption(Icons.help_outline, 'Help & Support', false),
          _buildSettingsOption(Icons.logout, 'Logout', true),
        ],
      ),
    );
  }

  Widget _buildSettingsOption(IconData icon, String text, bool isLogout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, color: isLogout ? Colors.redAccent : const Color(0xFF475569), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isLogout ? Colors.redAccent : const Color(0xFF1E293B),
              ),
            ),
          ),
          if (!isLogout) const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

// Shared Doctor Navigation Bar
Widget _buildDocNavBar(int currentIndex) {
  const activeColor = Color(0xFF2563EB);
  const inactiveColor = Color(0xFF94A3B8);

  return Container(
    height: 60,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _docNavItem(0, currentIndex == 0 ? Icons.home : Icons.home_outlined, 'Home', currentIndex == 0 ? activeColor : inactiveColor),
        _docNavItem(1, currentIndex == 1 ? Icons.people : Icons.people_outline, 'Patients', currentIndex == 1 ? activeColor : inactiveColor),
        _docNavItem(2, currentIndex == 2 ? Icons.calendar_month : Icons.calendar_month_outlined, 'Appointments', currentIndex == 2 ? activeColor : inactiveColor),
        _docNavItem(3, currentIndex == 3 ? Icons.more_horiz : Icons.more_horiz, 'More', currentIndex == 3 ? activeColor : inactiveColor),
      ],
    ),
  );
}

Widget _docNavItem(int index, IconData icon, String label, Color color) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 2),
      Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    ],
  );
}
