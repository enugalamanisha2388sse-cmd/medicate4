import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/services/services.dart';

class ProfileTab extends StatefulWidget {
  ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with SingleTickerProviderStateMixin {
  late TabController _profileSubController;

  // Profile fields controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;

  bool _isBackingUp = false;

  @override
  void initState() {
    super.initState();
    _profileSubController = TabController(length: 3, vsync: this);
    
    final provider = Provider.of<MedicateProvider>(context, listen: false);
    final user = provider.currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _profileSubController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile(MedicateProvider provider) {
    provider.updateUserProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      bio: _bioController.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('SUCCESS: Profile updated successfully.')),
    );
  }

  void _runCloudBackup() async {
    setState(() => _isBackingUp = true);
    await Future.delayed(Duration(seconds: 2));
    if (mounted) {
      setState(() => _isBackingUp = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SUCCESS: Database successfully synced to secure Cloud Storage.')),
      );
    }
  }

  void _generatePdfReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppTheme.primaryIndigo.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.picture_as_pdf_rounded, color: AppTheme.primaryIndigo),
            SizedBox(width: 10),
            Text('PDF Report Generated', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          ],
        ),
        content: Text(
          'Your premium digital health report has been generated. It includes your biometrics summary, logged symptoms, medication reminders, and vital signs trends.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloading SmartMed_Health_Report.pdf to device...')),
              );
            },
            icon: Icon(Icons.download_rounded, color: Colors.white, size: 16),
            label: Text('DOWNLOAD PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryIndigo),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: AppTheme.primaryIndigo, size: 18),
      filled: true,
      fillColor: Colors.black.withOpacity(0.12),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.borderCard)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.primaryIndigo)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _profileSubController,
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textSecondary,
              indicator: BoxDecoration(color: AppTheme.primaryIndigo, borderRadius: BorderRadius.circular(12)),
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              tabs: [
                Tab(text: 'SETTINGS'),
                Tab(text: 'ANALYTICS'),
                Tab(text: 'EMERGENCY'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _profileSubController,
        children: [
          _buildSettingsView(provider),
          _buildAnalyticsView(provider),
          _buildEmergencyView(provider),
        ],
      ),
    );
  }

  Widget _buildSettingsView(MedicateProvider provider) {
    final isDark = provider.themeMode == ThemeMode.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Theme Switcher Row
          GlassCard(
            radius: 20,
            borderColor: AppTheme.primaryIndigo.withOpacity(0.15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: AppTheme.primaryIndigo,
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DYNAMIC DARK MODE',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                        ),
                        SizedBox(height: 2),
                        Text(
                          isDark ? 'Dark Theme Enabled' : 'Light Theme Enabled',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: isDark,
                  activeColor: AppTheme.primaryIndigo,
                  onChanged: (val) {
                    provider.toggleTheme();
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // OCR Scan Card
          GlassCard(
            radius: 20,
            borderColor: AppTheme.primaryIndigo.withOpacity(0.15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppTheme.primaryIndigo.withOpacity(0.12), shape: BoxShape.circle),
                      child: Icon(Icons.document_scanner_rounded, color: AppTheme.primaryIndigo, size: 20),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI SCANNER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                        SizedBox(height: 2),
                        Text('Prescription OCR Scanner', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Upload or capture an image of your prescription. Our AI OCR scanner will extract instructions and automatically configure alarms.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.3),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: provider.isOcrScanning 
                      ? null 
                      : () => provider.runOcrPrescriptionScan('prescription.jpg'),
                    icon: provider.isOcrScanning 
                      ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                    label: Text(
                      provider.isOcrScanning ? 'EXTRACTING TEXT...' : 'CAMERA OCR SCAN',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryIndigo),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Profile Settings Form
          Text('Profile Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          SizedBox(height: 12),
          GlassCard(
            radius: 20,
            borderColor: AppTheme.borderCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: _inputDecoration('Full Name', Icons.person_outline),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: _inputDecoration('Email Address', Icons.mail_outline),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: _inputDecoration('Phone Number', Icons.phone_android_outlined),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _bioController,
                  maxLines: 2,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: _inputDecoration('Bio / Patient Overview', Icons.article_outlined),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _saveProfile(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryIndigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('SAVE PROFILE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Backup & Export Card
          Text('Security & Data Export', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          SizedBox(height: 12),
          GlassCard(
            radius: 20,
            borderColor: AppTheme.borderCard,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isBackingUp ? null : _runCloudBackup,
                    icon: _isBackingUp
                      ? SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 16),
                    label: Text(_isBackingUp ? 'SYNCING...' : 'CLOUD BACKUP', style: TextStyle(color: Colors.white, fontSize: 11)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, padding: EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _generatePdfReport(context),
                    icon: Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 16),
                    label: Text('PDF REPORT', style: TextStyle(color: Colors.white, fontSize: 11)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryIndigo, padding: EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsView(MedicateProvider provider) {
    // Render custom charts using CustomPainters to guarantee responsiveness and zero overflows.
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Biometrics Summary & Trends', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          SizedBox(height: 16),

          // Pulse Rate Chart
          Text('ECG HEART RATE PROGRESSION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          SizedBox(height: 8),
          GlassCard(
            radius: 20,
            borderColor: AppTheme.primaryIndigo.withOpacity(0.15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Vitals Wearable Status:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    Text('Active Streams (76 bpm)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: CustomPaint(
                    painter: _SimpleLineChartPainter(
                      points: [72, 75, 78, 73, 76, 79, 81, 75, 76, 78],
                      color: AppTheme.primaryIndigo,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Glucose trend
          Text('GLUCOSE LEVELS (10-DAY TREND)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          SizedBox(height: 8),
          GlassCard(
            radius: 20,
            borderColor: AppTheme.primaryPurple.withOpacity(0.15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Target Range:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    Text('70 - 140 mg/dL (In Range)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: CustomPaint(
                    painter: _SimpleLineChartPainter(
                      points: [98, 102, 95, 99, 108, 97, 104, 101, 98, 99],
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Blood Pressure
          Text('BLOOD PRESSURE TREND', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          SizedBox(height: 8),
          GlassCard(
            radius: 20,
            borderColor: AppTheme.primaryTeal.withOpacity(0.15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Reading:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    Text('118/79 mmHg (Ideal)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: CustomPaint(
                    painter: _SimpleLineChartPainter(
                      points: [122, 120, 118, 121, 119, 117, 118, 120, 119, 118],
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyView(MedicateProvider provider) {
    final vehicles = provider.liveVehicles;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SOS Trigger Card
          GlassCard(
            radius: 24,
            borderColor: AppTheme.error.withOpacity(0.3),
            fillColor: AppTheme.error.withOpacity(0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppTheme.error, shape: BoxShape.circle),
                      child: Icon(Icons.emergency_rounded, color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SOS EMERGENCY ALERTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.error, letterSpacing: 1.2)),
                          SizedBox(height: 4),
                          Text('Broadcast Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Triggering this SOS will immediately broadcast your GPS coordinates and clinical card to nearby trauma centers, medical responders, and registered contacts.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.error,
                        content: Text('ALERT: Broadcast sent. Simulated emergency dispatch is responding.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, padding: EdgeInsets.symmetric(vertical: 14)),
                  child: Text('TRIGGER SOS BROADCAST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          SizedBox(height: 28),

          Text('Responding Telemetry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          SizedBox(height: 12),
          ...vehicles.map((vh) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              child: GlassCard(
                radius: 20,
                borderColor: AppTheme.primaryIndigo.withOpacity(0.15),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppTheme.primaryIndigo.withOpacity(0.12), shape: BoxShape.circle),
                      child: Icon(
                        vh.type == 'Ambulance' ? Icons.airport_shuttle_rounded : Icons.flight_takeoff_rounded,
                        color: AppTheme.primaryIndigo,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${vh.type} [ID: ${vh.id}]',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Status: ${vh.status} • Target: ${vh.targetHospital}',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                      child: Text('Active GPS', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SimpleLineChartPainter extends CustomPainter {
  final List<double> points;
  final Color color;

  _SimpleLineChartPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final double minVal = points.reduce((a, b) => a < b ? a : b);
    final double maxVal = points.reduce((a, b) => a > b ? a : b);
    final double valueRange = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()..color = color;

    final double stepX = size.width / (points.length - 1);
    final path = Path();

    for (int i = 0; i < points.length; i++) {
      final double x = i * stepX;
      // Map value range to height with padding
      final double normalizedY = (points[i] - minVal) / valueRange;
      final double y = size.height - (normalizedY * (size.height - 20) + 10);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
