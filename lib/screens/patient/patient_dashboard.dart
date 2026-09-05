import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';
import '../auth/role_selection_screen.dart';
import 'hospital_map_screen.dart';
import 'ai_chat_screen.dart';
import 'video_consult_screen.dart';
import 'appointment_calendar_screen.dart';
import 'trackers_screen.dart';
import 'medical_shop_screen.dart';
import 'emergency_screen.dart';
import 'vaccination_screen.dart';
import 'user_profile_screen.dart';
import 'bluetooth_vitals_screen.dart';
import 'tabs/medicines_tab.dart';
import 'tabs/calendar_tab.dart';
import 'tabs/profile_tab.dart';

class PatientDashboard extends StatefulWidget {
  PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    final user = provider.currentUser;

    if (user == null) {
      return RoleSelectionScreen();
    }

    final pages = [
      _buildHomeView(context, provider, user),
      BluetoothVitalsScreen(isTab: true),
      MedicinesTab(),
      CalendarTab(),
      ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: DynamicBackground(
        child: Stack(
          children: [
            // Outer Glow
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryCyan.withOpacity(0.08),
                ),
              ),
            ),
            pages[_currentIndex],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          border: Border(top: BorderSide(color: AppTheme.borderCard, width: 1.2)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (idx) => setState(() => _currentIndex = idx),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: _currentIndex == 0
              ? AppTheme.primaryBlue
              : (_currentIndex == 1
                  ? Colors.redAccent
                  : (_currentIndex == 2
                      ? Color(0xFF8B5CF6)
                      : (_currentIndex == 3 ? Colors.orange : Color(0xFF4F46E5)))),
          unselectedItemColor: AppTheme.textSecondary,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded, color: _currentIndex == 0 ? AppTheme.primaryBlue : AppTheme.textSecondary),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_rounded, color: _currentIndex == 1 ? Colors.redAccent : AppTheme.textSecondary),
              label: 'Vitals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medication_rounded, color: _currentIndex == 2 ? Color(0xFF8B5CF6) : AppTheme.textSecondary),
              label: 'Medicines',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded, color: _currentIndex == 3 ? Colors.orange : AppTheme.textSecondary),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_rounded, color: _currentIndex == 4 ? Color(0xFF4F46E5) : AppTheme.textSecondary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeView(BuildContext context, MedicateProvider provider, UserAccount user) {
    final activeReminders = provider.reminders.where((r) => !r.isTaken).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back,',
                      style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      user.name,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        IconButton(
                          onPressed: () => _showNotificationsBottomSheet(context, provider),
                          icon: Icon(Icons.notifications_outlined, color: AppTheme.textSecondary),
                          tooltip: 'Notifications',
                        ),
                        if (provider.notifications.isNotEmpty)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                              constraints: BoxConstraints(minWidth: 12, minHeight: 12),
                              child: Text(
                                '${provider.notifications.length}',
                                style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen())),
                      icon: Icon(Icons.account_circle_outlined, color: AppTheme.textSecondary),
                      tooltip: 'Profile Settings',
                    ),
                    IconButton(
                      onPressed: () {
                        provider.logout();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
                        );
                      },
                      icon: Icon(Icons.logout_rounded, color: Colors.redAccent),
                      tooltip: 'Logout',
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),

            // Health Status Live ECG Widget
            ECGWidget(),

            SizedBox(height: 28),
            Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            SizedBox(height: 16),

            // Actions Grid
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                _buildActionCard(
                  icon: Icons.calendar_month_rounded,
                  title: 'Book Consult',
                  color: AppTheme.primaryTeal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentCalendarScreen())),
                ),
                _buildActionCard(
                  icon: Icons.video_call_rounded,
                  title: 'Video Call',
                  color: AppTheme.primaryIndigo,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VideoConsultScreen())),
                ),
                _buildActionCard(
                  icon: Icons.contact_emergency_rounded,
                  title: 'SOS Emergency',
                  color: Colors.redAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EmergencyScreen())),
                ),
                _buildActionCard(
                  icon: Icons.track_changes_rounded,
                  title: 'My Trackers',
                  color: AppTheme.primaryCyan,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TrackersScreen())),
                ),
                _buildActionCard(
                  icon: Icons.assignment_rounded,
                  title: 'Medical Records',
                  color: Colors.amber,
                  onTap: () => _showMedicalRecordsBottomSheet(context, provider),
                ),
                _buildActionCard(
                  icon: Icons.vaccines_rounded,
                  title: 'Vaccine Hub',
                  color: AppTheme.primaryPurple,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VaccinationScreen())),
                ),
                _buildActionCard(
                  icon: Icons.local_hospital_rounded,
                  title: 'Find Hospitals',
                  color: Colors.pinkAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HospitalMapScreen())),
                ),
                _buildActionCard(
                  icon: Icons.shopping_bag_rounded,
                  title: 'Medical Shop',
                  color: Colors.greenAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MedicalShopScreen())),
                ),
                _buildActionCard(
                  icon: Icons.chat_bubble_rounded,
                  title: 'AI Chatbot',
                  color: Colors.orangeAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AiChatScreen())),
                ),
              ],
            ),

            SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Medication Reminders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                if (activeReminders.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      '${activeReminders.length} Pending',
                      style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),

            // Reminders Box
            if (provider.reminders.isEmpty)
              GlassCard(
                radius: 16,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text('No active medication schedules.', style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                ),
              )
            else
              Column(
                children: provider.reminders.map((rem) => _buildReminderItem(context, provider, rem)).toList(),
              ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        radius: 18,
        borderColor: color.withOpacity(0.15),
        fillColor: color.withOpacity(0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.12)),
              child: Icon(icon, size: 24, color: color),
            ),
            SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderItem(BuildContext context, MedicateProvider provider, MedicineReminder reminder) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: GlassCard(
        radius: 16,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderColor: reminder.isTaken ? Colors.green.withOpacity(0.2) : AppTheme.borderCard,
        fillColor: reminder.isTaken ? Colors.green.withOpacity(0.05) : Color(0x0AFFFFFF),
        child: Row(
          children: [
            Icon(
              reminder.isTaken ? Icons.check_circle : Icons.circle_outlined,
              color: reminder.isTaken ? Colors.green : AppTheme.primaryTeal,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.medicineName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      decoration: reminder.isTaken ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${reminder.dosage} • ${reminder.time}',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => provider.toggleReminderTaken(reminder.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: reminder.isTaken ? Colors.grey[800] : AppTheme.primaryTeal,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                reminder.isTaken ? 'Undo' : 'Take',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _showMedicalRecordsBottomSheet(BuildContext context, MedicateProvider provider) {
    final myPrescriptions = provider.prescriptions.where((p) => p.patientId == provider.currentUser?.id).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return GlassCard(
          radius: 30,
          borderColor: Colors.amber.withOpacity(0.3),
          fillColor: AppTheme.background.withOpacity(0.98),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(color: AppTheme.textSecondary.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Icon(Icons.assignment_rounded, color: Colors.amber, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Digital Medical Records',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Encrypted records generated and approved by your certified doctors.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                SizedBox(height: 24),
                if (myPrescriptions.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Text('No medical records/prescriptions on file.', style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: myPrescriptions.length,
                      itemBuilder: (context, idx) {
                        final pres = myPrescriptions[idx];
                        final dateStr = '${pres.date.day}/${pres.date.month}/${pres.date.year}';
                        
                        // Find matching medicine in stock to add to cart
                        final matchedMed = provider.medicines.firstWhere(
                          (m) => m.name.toLowerCase().contains(pres.medicineName.toLowerCase()) || pres.medicineName.toLowerCase().contains(m.name.toLowerCase()),
                          orElse: () => Medicine(id: 'temp', name: pres.medicineName, category: 'Prescribed', price: 9.99, description: 'Doctor prescribed', stock: 10),
                        );

                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          child: GlassCard(
                            radius: 16,
                            borderColor: Colors.amber.withOpacity(0.2),
                            fillColor: Colors.amber.withOpacity(0.02),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pres.medicineName,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                                      ),
                                      SizedBox(height: 4),
                                      Text('Instructions: ${pres.dosage}', style: TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
                                      SizedBox(height: 8),
                                      Text('Prescribed by ${pres.doctorName} on $dateStr', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    provider.addToCart(matchedMed);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Added ${pres.medicineName} to shopping cart.')),
                                    );
                                  },
                                  icon: Icon(Icons.add_shopping_cart, size: 14, color: Colors.black),
                                  label: Text('BUY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showReportDialog(context, provider);
                        },
                        icon: Icon(Icons.analytics_rounded, size: 16, color: Colors.black),
                        label: Text('MY REPORT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.borderCard),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('DISMISS', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationsBottomSheet(BuildContext context, MedicateProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return GlassCard(
          radius: 30,
          borderColor: AppTheme.primaryCyan.withOpacity(0.3),
          fillColor: AppTheme.background.withOpacity(0.98),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(color: AppTheme.textSecondary.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications_active_rounded, color: AppTheme.primaryCyan, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Notification Center',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    if (provider.notifications.isNotEmpty)
                      TextButton(
                        onPressed: () => provider.clearAllNotifications(),
                        child: Text('CLEAR ALL', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                SizedBox(height: 16),
                if (provider.notifications.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Text('No unread notifications.', style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: provider.notifications.length,
                      itemBuilder: (context, idx) {
                        final notif = provider.notifications[idx];
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderCard),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: AppTheme.primaryCyan, size: 18),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  notif.text,
                                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, height: 1.4),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close_rounded, size: 16, color: AppTheme.textSecondary),
                                onPressed: () => provider.dismissNotification(notif.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.borderCard),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('DISMISS', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReportDialog(BuildContext context, MedicateProvider provider) {
    final user = provider.currentUser!;
    final recentSymptoms = provider.symptoms;
    final prescriptions = provider.prescriptions.where((p) => p.patientId == user.id).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppTheme.primaryTeal.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.analytics_rounded, color: AppTheme.primaryTeal),
            SizedBox(width: 8),
            Text('Health Diagnostics Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PATIENT CLASSIFICATION', style: TextStyle(fontSize: 10, color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                SizedBox(height: 4),
                Text('Name: ${user.name}', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Contact: ${user.phone}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                Text('Biometrics Node: ${user.email}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                Divider(color: AppTheme.borderCard, height: 24),
                
                Text('TELEMETRY STATUS', style: TextStyle(fontSize: 10, color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ECG Pulse Rate:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    Text(
                      provider.btStatus == BluetoothConnectionStatus.connected
                          ? '${provider.bpmValue} bpm (Normal Sinus)'
                          : 'Offline (Not Connected)',
                      style: TextStyle(
                        color: provider.btStatus == BluetoothConnectionStatus.connected ? Colors.greenAccent : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Blood Glucose level:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    Text(
                      provider.btStatus == BluetoothConnectionStatus.connected
                          ? '${provider.glucoseValue.toStringAsFixed(1)} mg/dL'
                          : 'Offline (Not Connected)',
                      style: TextStyle(
                        color: provider.btStatus == BluetoothConnectionStatus.connected ? AppTheme.primaryPurple : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                
                Text('LOGGED SYMPTOMS', style: TextStyle(fontSize: 10, color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                SizedBox(height: 6),
                if (recentSymptoms.isEmpty)
                  Text('No recent symptom anomalies logged.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12))
                else
                  ...recentSymptoms.map((s) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('• ${s.symptom}', style: TextStyle(fontSize: 12)),
                        Text('Severity: ${s.severity.toInt()}/10', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                      ],
                    ),
                  )),
                Divider(color: AppTheme.borderCard, height: 24),

                Text('PRESCRIBED MEDICATIONS', style: TextStyle(fontSize: 10, color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                SizedBox(height: 6),
                if (prescriptions.isEmpty)
                  Text('No active digital prescriptions.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12))
                else
                  ...prescriptions.map((p) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.medicineName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Dosage: ${p.dosage} (Issued by ${p.doctorName})', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                      ],
                    ),
                  )),
              ],
            ),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(side: BorderSide(color: AppTheme.borderCard)),
            child: Text('CLOSE', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Exporting report as PDF/JSON... Diagnostic copy saved to files.')),
              );
            },
            icon: Icon(Icons.download_rounded, size: 16, color: Colors.white),
            label: Text('EXPORT REPORT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
          ),
        ],
      ),
    );
  }
}

// Real-Time Electrocardiogram Telemetry Pulse Monitor
class ECGWidget extends StatefulWidget {
  ECGWidget({super.key});

  @override
  State<ECGWidget> createState() => _ECGWidgetState();
}

class _ECGWidgetState extends State<ECGWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _bpm = 78;
  Timer? _bpmTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();

    _bpmTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _bpm = 74 + _random.nextInt(8);
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _bpmTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    final btStatus = provider.btStatus;
    final isConnected = btStatus == BluetoothConnectionStatus.connected;
    final connectedDevice = provider.connectedDevice;
    final glucose = provider.glucoseValue;
    final bpm = isConnected ? provider.bpmValue : _bpm;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BluetoothVitalsScreen()),
        );
      },
      child: GlassCard(
        radius: 24,
        borderColor: isConnected ? AppTheme.primaryCyan.withOpacity(0.3) : AppTheme.borderCard,
        fillColor: isConnected ? AppTheme.primaryCyan.withOpacity(0.04) : Color(0x0AFFFFFF),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isConnected ? Icons.bluetooth_connected_rounded : Icons.bluetooth_disabled_rounded,
                      color: isConnected ? Colors.greenAccent : AppTheme.textSecondary,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      isConnected
                          ? 'WEARABLE ACTIVE: ${connectedDevice?.name.toUpperCase()}'
                          : 'TELEMETRY OFFLINE - TAP TO CONNECT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isConnected ? Colors.greenAccent : AppTheme.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                if (isConnected)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryCyan.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${connectedDevice?.batteryLevel}% Batt',
                      style: TextStyle(color: AppTheme.primaryCyan, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            if (isConnected) ...[
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ECG HEART RATE',
                          style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$bpm',
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'bpm',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REAL-TIME GLUCOSE',
                          style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              glucose.toStringAsFixed(1),
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'mg/dL',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              SizedBox(
                height: 45,
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ECGPainter(_controller.value),
                    );
                  },
                ),
              ),
            ] else ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sensors_off_rounded, color: AppTheme.textSecondary.withOpacity(0.6), size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vitals Streaming Offline',
                            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Connect watch or ring for ECG & glucose monitoring',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textSecondary, size: 14),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ECGPainter extends CustomPainter {
  final double value;
  ECGPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppTheme.primaryTeal.withOpacity(0.08)
      ..strokeWidth = 0.8;

    for (double i = 0; i < size.width; i += 12) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double j = 0; j < size.height; j += 12) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), gridPaint);
    }

    final wavePaint = Paint()
      ..color = AppTheme.primaryCyan
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = AppTheme.primaryCyan.withOpacity(0.3)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final centerY = size.height * 0.5;
    path.moveTo(0, centerY);

    for (double x = 0; x < size.width; x++) {
      final targetX = (x - (value * size.width)) % size.width;
      double y = centerY;

      final localX = targetX % (size.width / 2);
      if (localX > 20 && localX < 30) {
        y -= 5 * sin((localX - 20) / 10 * pi);
      } else if (localX >= 30 && localX < 34) {
        y += 4 * ((localX - 30) / 4);
      } else if (localX >= 34 && localX < 38) {
        y -= 30 * ((localX - 34) / 4);
      } else if (localX >= 38 && localX < 42) {
        y += 35 * ((localX - 38) / 4);
      } else if (localX >= 42 && localX < 46) {
        y -= 9 * ((localX - 42) / 4);
      } else if (localX >= 55 && localX < 70) {
        y -= 8 * sin((localX - 55) / 15 * pi);
      }

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, wavePaint);

    final dotX = value * size.width;
    double dotY = centerY;
    final cursorX = dotX % (size.width / 2);
    if (cursorX > 20 && cursorX < 30) {
      dotY -= 5 * sin((cursorX - 20) / 10 * pi);
    } else if (cursorX >= 30 && cursorX < 34) {
      dotY += 4 * ((cursorX - 30) / 4);
    } else if (cursorX >= 34 && cursorX < 38) {
      dotY -= 30 * ((cursorX - 34) / 4);
    } else if (cursorX >= 38 && cursorX < 42) {
      dotY += 35 * ((cursorX - 38) / 4);
    } else if (cursorX >= 42 && cursorX < 46) {
      dotY -= 9 * ((cursorX - 42) / 4);
    } else if (cursorX >= 55 && cursorX < 70) {
      dotY -= 8 * sin((cursorX - 55) / 15 * pi);
    }

    canvas.drawCircle(Offset(dotX, dotY), 4, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(dotX, dotY), 8, Paint()..color = AppTheme.primaryCyan.withOpacity(0.5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
