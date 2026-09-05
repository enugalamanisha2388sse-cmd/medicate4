import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class CaregiverScreen extends StatefulWidget {
  const CaregiverScreen({super.key});

  @override
  State<CaregiverScreen> createState() => _CaregiverScreenState();
}

class _CaregiverScreenState extends State<CaregiverScreen> {
  String _timeRange = 'Today';

  @override
  Widget build(BuildContext context) {
    return MobileViewFrame(
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Caregiver Dashboard',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
              fontSize: 16,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Patient Profile Header Row
                Row(
                  children: [
                    // Female Profile Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.3), width: 1.5),
                      ),
                      child: const Center(
                        child: Text(
                          '👩‍⚕️',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manisha E.',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            'View profile',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF0D9488),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Dropdown Switcher
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _timeRange,
                          isDense: true,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                          items: <String>['Today', 'This Week', 'This Month'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _timeRange = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Three Adherence Metric Cards in a Row
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Taken',
                        '2',
                        '100%',
                        const Color(0xFF22C55E),
                        const Color(0xFFDCFCE7),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        'Missed',
                        '1',
                        'Missed',
                        const Color(0xFFEF4444),
                        const Color(0xFFFEE2E2),
                        showPercentage: false,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        'Upcoming',
                        '1',
                        'Pending',
                        const Color(0xFF8B5CF6),
                        const Color(0xFFF3E8FF),
                        showPercentage: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // 3. Medicine Status list
                Text(
                  'Medicine Status',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),

                // List Items
                _buildStatusItem(
                  'Morning (08:00 AM)',
                  'Paracetamol 500mg',
                  'Taken',
                  true,
                ),
                const SizedBox(height: 10),
                _buildStatusItem(
                  'Afternoon (01:00 PM)',
                  'Amoxicillin 500mg',
                  'Taken',
                  true,
                ),
                const SizedBox(height: 10),
                _buildStatusItem(
                  'Evening (08:00 PM)',
                  'Ibuprofen 400mg',
                  'Missed',
                  false,
                ),
                const SizedBox(height: 32),

                // 4. View Full Schedule button at the bottom
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // pop caregiver view
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        'View Full Schedule',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String count,
    String subLabel,
    Color color,
    Color bg, {
    bool showPercentage = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(
                count,
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (showPercentage) ...[
                const SizedBox(width: 4),
                Text(
                  subLabel,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          if (!showPercentage) ...[
            Text(
              subLabel,
              style: GoogleFonts.poppins(
                color: color.withOpacity(0.7),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    String timeLabel,
    String name,
    String status,
    bool isTaken,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.isDark ? Colors.transparent : const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isTaken ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTaken ? Icons.medication_rounded : Icons.warning_rounded,
              color: isTaken ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                status,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isTaken ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isTaken ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isTaken ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
