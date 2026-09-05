import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/services/services.dart';

// ==========================================
// SHARED UI HELPERS FOR MOCKUP
// ==========================================

Widget buildMockPhoneFrame(BuildContext context, {
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

// Logo matching Splash and Login
Widget buildMockLogo({double size = 48}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: const Color(0xFFE0F2FE),
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.3), width: 1.5),
    ),
    child: Icon(
      Icons.health_and_safety,
      color: const Color(0xFF0EA5E9),
      size: size * 0.6,
    ),
  );
}

// ==========================================
// 1. SPLASH SCREEN
// ==========================================
class SplashMockView extends StatefulWidget {
  const SplashMockView({super.key});

  @override
  State<SplashMockView> createState() => _SplashMockViewState();
}

class _SplashMockViewState extends State<SplashMockView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _activeDot = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(), // Spacer
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                  CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
                ),
                child: buildMockLogo(size: 80),
              ),
              const SizedBox(height: 16),
              const Text(
                'MediCare+',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Smart Medicine, Better Life',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              // Dots indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => _activeDot = index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: _activeDot == index ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _activeDot == index ? const Color(0xFF0EA5E9) : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          // Footer
          const Text(
            'Your health, our priority.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. LOGIN / SIGN UP
// ==========================================
class LoginSignupMockView extends StatefulWidget {
  const LoginSignupMockView({super.key});

  @override
  State<LoginSignupMockView> createState() => _LoginSignupMockViewState();
}

class _LoginSignupMockViewState extends State<LoginSignupMockView> {
  final _emailCtrl = TextEditingController(text: 'patient@medicate.com');
  final _passCtrl = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1E293B)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: buildMockLogo(size: 64)),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Sign in to continue',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
            const SizedBox(height: 28),
            // Form fields
            TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outline, size: 18),
                labelText: 'Email or Phone',
                labelStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline, size: 18),
                suffixIcon: const Icon(Icons.visibility_off_outlined, size: 18),
                labelText: 'Password',
                labelStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Color(0xFF0EA5E9), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Successfully Authenticated as Manisha E.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'or continue with',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                    label: const Text('Google', style: TextStyle(color: Color(0xFF1E293B), fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.apple, color: Colors.black),
                    label: const Text('Apple', style: TextStyle(color: Color(0xFF1E293B), fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Center(
              child: RichText(
                text: const TextSpan(
                  text: "Don't have an account? ",
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  children: [
                    TextSpan(
                      text: "Sign Up",
                      style: TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. HOME DASHBOARD
// ==========================================
class HomeDashboardMockView extends StatefulWidget {
  const HomeDashboardMockView({super.key});

  @override
  State<HomeDashboardMockView> createState() => _HomeDashboardMockViewState();
}

class _HomeDashboardMockViewState extends State<HomeDashboardMockView> {
  bool _taken = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Good morning,', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      SizedBox(height: 2),
                      Text('Manisha 👋', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFF1E293B)),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                          child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Next Medicine card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.medication, color: Color(0xFF22C55E)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Next Medicine', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              SizedBox(height: 2),
                              Text('Paracetamol 500mg', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            ],
                          ),
                        ),
                        const Text('08:00 PM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0EA5E9))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _taken = !_taken);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _taken ? const Color(0xFF22C55E) : const Color(0xFF0EA5E9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: const Size(double.infinity, 38),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_taken ? 'Medicine Taken ✓' : 'Take Medicine', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Medication Adherence section
              const Text('Medication Adherence', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Text(
                              '86%',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF22C55E)),
                            ),
                            SizedBox(width: 4),
                            Text('• Good', style: TextStyle(color: Color(0xFF22C55E), fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const Icon(Icons.trending_up, color: Color(0xFF22C55E), size: 16),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: CustomPaint(painter: LineChartPainter()),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'You usually miss your evening medicine on weekends.',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Quick Access
              const Text('Quick Access', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
                children: [
                  _quickAccessItem(Icons.medication, 'Medicines', const Color(0xFFEEF2FF), const Color(0xFF4F46E5)),
                  _quickAccessItem(Icons.favorite, 'Vitals', const Color(0xFFFEF2F2), const Color(0xFFEF4444)),
                  _quickAccessItem(Icons.calendar_month, 'Appointments', const Color(0xFFECFDF5), const Color(0xFF059669)),
                  _quickAccessItem(Icons.inventory, 'Inventory', const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
                  _quickAccessItem(Icons.psychology, 'AI Assistant', const Color(0xFFF0FDF4), const Color(0xFF0EA5E9)),
                  _quickAccessItem(Icons.camera_alt, 'Scan Medicine', const Color(0xFFFDF2F8), const Color(0xFFDB2777)),
                  _quickAccessItem(Icons.people, 'Caregiver', const Color(0xFFFFF7ED), const Color(0xFFEA580C)),
                  _quickAccessItem(Icons.grid_view, 'More', const Color(0xFFF8FAFC), const Color(0xFF64748B)),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0EA5E9),
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedFontSize: 9,
        unselectedFontSize: 9,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled, size: 20), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.medication, size: 20), label: 'Medicines'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite, size: 20), label: 'Vitals'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications, size: 20), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 20), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _quickAccessItem(IconData icon, String label, Color bgColor, Color iconColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// Custom Painter for Adherence Chart
class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22C55E)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF22C55E).withOpacity(0.2), const Color(0xFF22C55E).withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..cubicTo(size.width * 0.2, size.height * 0.4, size.width * 0.4, size.height * 0.8, size.width * 0.6, size.height * 0.3)
      ..cubicTo(size.width * 0.8, size.height * 0.1, size.width * 0.9, size.height * 0.4, size.width, size.height * 0.2);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ==========================================
// 4. MEDICINE REMINDER (SMART)
// ==========================================
class MedicineReminderMockView extends StatelessWidget {
  const MedicineReminderMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1E293B)),
        actions: const [Icon(Icons.more_horiz, color: Color(0xFF1E293B)), SizedBox(width: 16)],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const SizedBox(height: 12),
                // Circular Timer/Indicator
                Container(
                  width: 180,
                  height: 180,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.12), width: 12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_active, color: Color(0xFF0EA5E9), size: 36),
                      const SizedBox(height: 12),
                      const Text(
                        'Time to take your',
                        style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Paracetamol\n500mg',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Detail Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _reminderRow('Dose', '1 Tablet', Icons.medication),
                      const Divider(height: 20),
                      _reminderRow('Time', '08:00 PM', Icons.schedule),
                      const Divider(height: 20),
                      _reminderRow('Before / After Food', 'After Food', Icons.restaurant),
                      const Divider(height: 20),
                      _reminderRow('Repeat', 'Daily', Icons.repeat),
                    ],
                  ),
                ),
              ],
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionRoundButton(Icons.snooze, 'Snooze', const Color(0xFF64748B)),
                  _actionRoundButton(Icons.check, 'Taken', const Color(0xFF22C55E)),
                  _actionRoundButton(Icons.close, 'Skip', const Color(0xFFEF4444)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reminderRow(String label, String val, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        const Spacer(),
        Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _actionRoundButton(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

// ==========================================
// 5. MEDICINE SCANNER
// ==========================================
class MedicineScannerMockView extends StatelessWidget {
  const MedicineScannerMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
        title: const Text('Place the medicine package inside the frame', style: TextStyle(fontSize: 11, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Simulated Scanner Window
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 200,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          '💊 Blister Pack',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  // Corner brackets mock
                  const Positioned(top: 8, left: 8, child: Icon(Icons.crop_free, color: Colors.cyanAccent, size: 16)),
                  const Positioned(top: 8, right: 8, child: Icon(Icons.crop_free, color: Colors.cyanAccent, size: 16)),
                  const Positioned(bottom: 8, left: 8, child: Icon(Icons.crop_free, color: Colors.cyanAccent, size: 16)),
                  const Positioned(bottom: 8, right: 8, child: Icon(Icons.crop_free, color: Colors.cyanAccent, size: 16)),
                ],
              ),
            ),
          ),
          // Information Panel Overlay Card
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Detected Medicine', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                  const SizedBox(height: 2),
                  const Text('Amoxicillin 500mg', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const Text('Capsule', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Manufacturer', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      Text('Cipla Ltd', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Expiry', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      Text('12 Dec 2026', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Use This Medicine', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Edit Details', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                  ),
                ],
              ),
            ),
          ),
          // Camera Control Bottom Bar
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(icon: const Icon(Icons.photo_library, color: Colors.white), onPressed: () {}),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: const CircleAvatar(radius: 20, backgroundColor: Colors.white),
                ),
                IconButton(icon: const Icon(Icons.flash_on, color: Colors.white), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 6. SMART ADHERENCE (AI)
// ==========================================
class SmartAdherenceMockView extends StatelessWidget {
  const SmartAdherenceMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1E293B)),
        title: const Text('Medication Adherence', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        actions: const [Icon(Icons.more_horiz, color: Color(0xFF1E293B)), SizedBox(width: 16)],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gauge Center
            Center(
              child: SizedBox(
                width: 130,
                height: 130,
                child: CustomPaint(
                  painter: AdherenceRadialPainter(percentage: 0.86),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('86%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      SizedBox(height: 2),
                      Text('Good', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF22C55E))),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // AI Insight Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Color(0xFFD1FAE5), shape: BoxShape.circle),
                    child: const Icon(Icons.psychology, color: Color(0xFF22C55E), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('AI Insight', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                        SizedBox(height: 2),
                        Text('You usually miss your evening medicine on weekends.', style: TextStyle(fontSize: 11, color: Color(0xFF065F46))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Prediction Card
            _adherenceCard('Prediction', 'High chance of missing next dose', const Color(0xFFFEF2F2), const Color(0xFFEF4444)),
            const SizedBox(height: 16),
            // Recommendation Card
            _adherenceCard('Recommendation', 'We will remind you 30 mins earlier on weekends.', const Color(0xFFEFF6FF), const Color(0xFF0EA5E9)),
          ],
        ),
      ),
    );
  }

  Widget _adherenceCard(String label, String body, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: iconColor)),
            ],
          ),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(fontSize: 11, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }
}

// Adherence Radial Painter
class AdherenceRadialPainter extends CustomPainter {
  final double percentage;
  AdherenceRadialPainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 8;

    final backgroundPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    final progressPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;

    canvas.drawCircle(center, radius, backgroundPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * percentage,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==========================================
// 7. SMART REFILL PREDICTION
// ==========================================
class SmartRefillMockView extends StatelessWidget {
  const SmartRefillMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1E293B)),
        title: const Text('Stock Prediction', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        actions: const [Icon(Icons.more_horiz, color: Color(0xFF1E293B)), SizedBox(width: 16)],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Details
            const Text('Amoxicillin 500mg', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const Text('Capsule', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            // Main Pred Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Estimated Remaining', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                  const SizedBox(height: 4),
                  const Text('4 Days', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                  const SizedBox(height: 2),
                  const Text('Based on your current schedule', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                  const SizedBox(height: 14),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 0.25,
                      minHeight: 8,
                      backgroundColor: Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation(Color(0xFFEF4444)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _stockStat('Stock Left', '12 Capsules'),
                      _stockStat('Daily Usage', '3 Capsules'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(double.infinity, 38),
                      elevation: 0,
                    ),
                    child: const Text('Add to Refill List', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Upcoming list
            const Text('Upcoming Refills', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 10),
            _refillTile('Ibuprofen 400mg', 'In 6 Days', const Color(0xFFF59E0B)),
            const SizedBox(height: 10),
            _refillTile('Vitamin D3 1000IU', 'In 10 Days', const Color(0xFF22C55E)),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('View All Inventory', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stockStat(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _refillTile(String name, String remaining, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(remaining, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 8. CAREGIVER MODE
// ==========================================
class CaregiverMockView extends StatelessWidget {
  const CaregiverMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1E293B)),
        title: const Text('Caregiver Dashboard', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        actions: const [Icon(Icons.more_horiz, color: Color(0xFF1E293B)), SizedBox(width: 16)],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Patient details banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100'),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Manisha E.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        Text('Patient Profile', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                    child: const Text('Today', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Metrics boxes
            Row(
              children: [
                Expanded(child: _metricBox('Taken', '2', '100%', const Color(0xFF22C55E))),
                const SizedBox(width: 10),
                Expanded(child: _metricBox('Missed', '1', 'Refill due', const Color(0xFFEF4444))),
                const SizedBox(width: 10),
                Expanded(child: _metricBox('Upcoming', '1', 'Pending', const Color(0xFF0EA5E9))),
              ],
            ),
            const SizedBox(height: 24),
            // Status list
            const Text('Medicine Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 10),
            _medicineStatusTile('Morning (08:00 AM)', 'Paracetamol 500mg', 'Taken', const Color(0xFF22C55E)),
            const SizedBox(height: 10),
            _medicineStatusTile('Afternoon (01:00 PM)', 'Amoxicillin 500mg', 'Taken', const Color(0xFF22C55E)),
            const SizedBox(height: 10),
            _medicineStatusTile('Evening (08:00 PM)', 'Ibuprofen 400mg', 'Missed', const Color(0xFFEF4444)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('View Full Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricBox(String label, String count, String details, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(details, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _medicineStatusTile(String time, String med, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Text(time, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 9. VOICE MEDICINE ASSISTANT
// ==========================================
class VoiceAssistantMockView extends StatefulWidget {
  const VoiceAssistantMockView({super.key});

  @override
  State<VoiceAssistantMockView> createState() => _VoiceAssistantMockViewState();
}

class _VoiceAssistantMockViewState extends State<VoiceAssistantMockView> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1E293B)),
        title: const Text('Voice Assistant', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Pulsing Audio Visualizer Wave
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  // Animated waveform mockup
                  SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        return CustomPaint(painter: WaveformPainter(_waveController.value));
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Listening...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0EA5E9))),
                ],
              ),
            ),

            // Help hints
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Try saying something like:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 12),
                _hintCard('"Remind me to take Vitamin D every Sunday at 9 AM"'),
                const SizedBox(height: 8),
                _hintCard('"Add Paracetamol 500mg every 8 hours"'),
                const SizedBox(height: 8),
                _hintCard('"Show my today\'s medicines"'),
              ],
            ),

            // Shutter stop button
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.mic_off, size: 16, color: Colors.white),
              label: const Text('Tap to stop', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hintCard(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
      ),
    );
  }
}

// Waveform Painter
class WaveformPainter extends CustomPainter {
  final double phase;
  WaveformPainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0EA5E9)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double midY = size.height / 2;
    final int count = 25;
    final double spacing = size.width / (count + 1);

    for (int i = 0; i < count; i++) {
      final double x = spacing * (i + 1);
      final double progress = i / count;
      final double waveHeight = 40 * sin(progress * pi) * sin(2 * pi * phase + (progress * 4 * pi)).abs();
      canvas.drawLine(
        Offset(x, midY - waveHeight / 2 - 2),
        Offset(x, midY + waveHeight / 2 + 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==========================================
// 10. MEDICINE INTERACTION ALERT
// ==========================================
class MedicineInteractionMockView extends StatelessWidget {
  const MedicineInteractionMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1E293B)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
                ),
                child: const Icon(Icons.warning_rounded, color: Color(0xFFEF4444), size: 48),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Potential Interaction\nDetected',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'The combination of Ibuprofen and Aspirin may increase the risk of bleeding. Please consult your doctor.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.5),
            ),
            const SizedBox(height: 24),
            // Involved medications
            const Text('Involved Medicines', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 10),
            _involvedMedTile('Ibuprofen 400mg', 'Pain reliever', const Color(0xFFEF4444)),
            const SizedBox(height: 10),
            _involvedMedTile('Aspirin 75mg', 'Blood thinner', const Color(0xFF64748B)),
            const Spacer(),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Learn More', style: TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Consult Doctor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _involvedMedTile(String medName, String purpose, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(Icons.medication, color: iconColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(medName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              Text(purpose, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 11. PILL VERIFICATION
// ==========================================
class PillVerificationMockView extends StatelessWidget {
  const PillVerificationMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1E293B)),
        title: const Text('Verify Your Medicine', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Your scheduled medicine:', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            const Text('Paracetamol 500mg', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 20),
            // Appearance card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Expected Appearance', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  const SizedBox(height: 12),
                  // Mock image rendering using shapes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
                        ),
                        child: const Center(
                          child: Text('P 500', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 80,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
                        ),
                        child: const Center(
                          child: Text('P 500', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Description: White, Oval Tablet. Imprint: P 500', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const Spacer(),
            const Center(
              child: Text(
                'Does your medicine look like this?',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pill Verification Confirmed. Enjoy your dose!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Yes, It Matches', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Action Terminated. Do not take this medication! Contact doctor.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("No, It's Different", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'This is a visual confirmation aid, not a guarantee of identity.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 12. LOCATION BASED REMINDER
// ==========================================
class LocationReminderMockView extends StatefulWidget {
  const LocationReminderMockView({super.key});

  @override
  State<LocationReminderMockView> createState() => _LocationReminderMockViewState();
}

class _LocationReminderMockViewState extends State<LocationReminderMockView> {
  String _loc = 'Home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Simulated map background
          Container(
            color: const Color(0xFFE2E8F0),
            width: double.infinity,
            height: double.infinity,
            child: CustomPaint(painter: MapGridPainter()),
          ),

          // Home/Office pin
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10)),
                  child: Text('You are at $_loc', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 4),
                const Icon(Icons.location_on, color: Color(0xFFEF4444), size: 36),
              ],
            ),
          ),

          // Back arrow
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF1E293B)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Floating Reminder Details Card
          Positioned(
            bottom: 110,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Medicine Due', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                  const SizedBox(height: 2),
                  const Text('Paracetamol 500mg', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const Text('08:00 PM', style: TextStyle(fontSize: 11, color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text("It's time to take your medicine.", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Take Medicine', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),

          // Why this reminder section
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Why this reminder? You are at $_loc. Perfect time for your medicine.',
                      style: const TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _loc = _loc == 'Home' ? 'Office' : 'Home';
                      });
                    },
                    child: const Text(
                      'Change Location',
                      style: TextStyle(color: Color(0xFF0EA5E9), fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    final dotPaint = Paint()..color = const Color(0xFF94A3B8).withOpacity(0.3);

    // Draw grid lines to simulate roads
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.35), paint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.65), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.4, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.75, 0), Offset(size.width * 0.7, size.height), paint);

    // Draw little circles representing houses/blocks
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.15), 18, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.18), 24, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.8), 20, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.82), 22, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// 13. VITALS + MEDICINE INSIGHT
// ==========================================
class VitalsInsightMockView extends StatelessWidget {
  const VitalsInsightMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1E293B)),
        title: const Text('Health Insight', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(6)),
            alignment: Alignment.center,
            child: const Text('Today', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          ),
          const SizedBox(width: 16),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BP Card Before
            _bpGraphCard(
              title: 'Blood Pressure',
              val: '138/90 mmHg',
              status: 'Slightly High',
              color: const Color(0xFFEF4444),
              isNormal: false,
            ),
            const SizedBox(height: 16),
            // BP Card After
            _bpGraphCard(
              title: 'After taking Amlodipine 5mg',
              val: '120/80 mmHg',
              status: 'Normal',
              color: const Color(0xFF22C55E),
              isNormal: true,
            ),
            const SizedBox(height: 20),
            // AI Insight Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Color(0xFFEEF2FF), shape: BoxShape.circle),
                    child: const Icon(Icons.psychology, color: Color(0xFF4F46E5), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('AI Insight', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        SizedBox(height: 2),
                        Text('Your BP improved after taking your medicine. Keep following your medication.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bpGraphCard({
    required String title,
    required String val,
    required String status,
    required Color color,
    required bool isNormal,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 10),
          SizedBox(
            height: 45,
            width: double.infinity,
            child: CustomPaint(painter: BPChartPainter(isNormal: isNormal, color: color)),
          ),
        ],
      ),
    );
  }
}

class BPChartPainter extends CustomPainter {
  final bool isNormal;
  final Color color;
  BPChartPainter({required this.isNormal, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, isNormal ? size.height * 0.5 : size.height * 0.3);

    final points = isNormal
        ? [
            Offset(size.width * 0.25, size.height * 0.48),
            Offset(size.width * 0.5, size.height * 0.52),
            Offset(size.width * 0.75, size.height * 0.49),
            Offset(size.width, size.height * 0.5)
          ]
        : [
            Offset(size.width * 0.25, size.height * 0.5),
            Offset(size.width * 0.5, size.height * 0.22),
            Offset(size.width * 0.75, size.height * 0.44),
            Offset(size.width, size.height * 0.26)
          ];

    for (var pt in points) {
      path.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()..color = color;
    for (var pt in points) {
      canvas.drawCircle(pt, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// 14. EMERGENCY HEALTH CARD
// ==========================================
class EmergencyHealthCardMockView extends StatelessWidget {
  const EmergencyHealthCardMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1E293B)),
        title: const Text('Emergency Health Card', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Tap to share', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            // Medical Red Emergency Card block
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('EMERGENCY CARD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2)),
                      Icon(Icons.emergency_share, color: Colors.white70, size: 20),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _emergencyCardItem('Blood Group', 'O+', Icons.bloodtype),
                  const Divider(color: Colors.white24, height: 16),
                  _emergencyCardItem('Allergies', 'Penicillin', const IconData(0xe1ad, fontFamily: 'MaterialIcons')),
                  const Divider(color: Colors.white24, height: 16),
                  _emergencyCardItem('Chronic Condition', 'Hypertension', Icons.medical_information),
                  const Divider(color: Colors.white24, height: 16),
                  _emergencyCardItem('Regular Medicines', '3 Active', Icons.healing),
                  const Divider(color: Colors.white24, height: 16),
                  _emergencyCardItem('Emergency Contact', '+91 98765 43210', Icons.phone),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Card Shared! Simulated native share sheet launch...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Share Card', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(height: 12),
            const Text(
              'This card can be used in medical emergencies.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _emergencyCardItem(String label, String val, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const Spacer(),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ==========================================
// 15. MORE / SETTINGS
// ==========================================
class MoreSettingsMockView extends StatelessWidget {
  const MoreSettingsMockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1E293B)),
        title: const Text('More / Settings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100'),
                    radius: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Manisha E.', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        SizedBox(height: 2),
                        Text('View & edit profile', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Menu list
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _menuItem('Settings', Icons.settings),
                  const Divider(height: 1, indent: 48),
                  _menuItem('Reminder Preferences', Icons.notifications),
                  const Divider(height: 1, indent: 48),
                  _menuItem('Privacy & Security', Icons.shield),
                  const Divider(height: 1, indent: 48),
                  _menuItem('Data Backup', Icons.cloud),
                  const Divider(height: 1, indent: 48),
                  _menuItem('Help & Support', Icons.help_outline),
                  const Divider(height: 1, indent: 48),
                  _menuItem('About MediCare+', Icons.info_outline),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logging Out...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEF2F2),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFFEE2E2))),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Logout', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0EA5E9),
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedFontSize: 9,
        unselectedFontSize: 9,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled, size: 20), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.medication, size: 20), label: 'Medicines'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite, size: 20), label: 'Vitals'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications, size: 20), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 20), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _menuItem(String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF64748B), size: 20),
      title: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      trailing: const Icon(Icons.chevron_right, size: 16, color: Color(0xFFCBD5E1)),
      onTap: () {},
      dense: true,
    );
  }
}
