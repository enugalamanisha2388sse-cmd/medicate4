import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';
import '../presentation_hub.dart';
import 'login_signup_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: DynamicBackground(
        child: Stack(
          children: [
          // Background decorative glowing circles
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryTeal.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryIndigo.withOpacity(0.12),
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton.icon(
                            onPressed: () {
                              Provider.of<MedicateProvider>(context, listen: false).setPresentationMode(true);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const PresentationHub()),
                              );
                            },
                            icon: Icon(Icons.dashboard_customize, size: 16, color: AppTheme.primaryTeal),
                            label: Text('MOCKUP CANVAS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Animated Logo & Header
                        FadeInSlide(
                          duration: Duration(milliseconds: 700),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.primaryTeal.withOpacity(0.1),
                                  border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.3), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryTeal.withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.health_and_safety,
                                  size: 64,
                                  color: AppTheme.primaryCyan,
                                ),
                              ),
                              SizedBox(height: 24),
                              Text(
                                'MEDICATE',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                  foreground: Paint()
                                    ..shader = AppTheme.tealCyanGradient.createShader(
                                      const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                                    ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Your Intelligent Health Companion',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 50),

                        FadeInSlide(
                          duration: Duration(milliseconds: 900),
                          slideOffset: 60,
                          child: Text(
                            'Select Your Portal',
                            style: TextStyle(
                              fontSize: 22,
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Roles Cards Layout
                        if (isWide)
                          FadeInSlide(
                            duration: Duration(milliseconds: 1100),
                            slideOffset: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _buildRoleCards(context),
                            ),
                          )
                        else
                          FadeInSlide(
                            duration: Duration(milliseconds: 1100),
                            slideOffset: 80,
                            child: Column(
                              children: _buildRoleCards(context),
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
  );
}

  List<Widget> _buildRoleCards(BuildContext context) {
    return [
      _RoleCard(
        title: 'PATIENT',
        icon: Icons.person_search,
        desc: 'Consult doctors, search pharmacies, book appointments, track logs & use AI Chat.',
        color: AppTheme.primaryTeal,
        gradient: AppTheme.tealCyanGradient,
        role: UserRole.patient,
      ),
      _RoleCard(
        title: 'DOCTOR',
        icon: Icons.medical_services,
        desc: 'Manage appointments, consulting times, view patients, and launch video calls.',
        color: AppTheme.primaryIndigo,
        gradient: AppTheme.indigoPurpleGradient,
        role: UserRole.doctor,
      ),
      _RoleCard(
        title: 'ADMINISTRATOR',
        icon: Icons.admin_panel_settings,
        desc: 'Modify hospital vacancies, contact details, update medicine stocks, and edit prices.',
        color: Colors.amber,
        gradient: LinearGradient(
          colors: [Colors.amber, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        role: UserRole.admin,
      ),
    ];
  }
}

class _RoleCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final String desc;
  final Color color;
  final Gradient gradient;
  final UserRole role;

  _RoleCard({
    required this.title,
    required this.icon,
    required this.desc,
    required this.color,
    required this.gradient,
    required this.role,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      width: MediaQuery.of(context).size.width > 700 ? 220 : double.infinity,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) => setState(() => _isHovered = false),
        onTapCancel: () => setState(() => _isHovered = false),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginSignupScreen(role: widget.role),
            ),
          );
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          transform: Matrix4.identity()..scale(_isHovered ? 0.97 : 1.0),
          child: GlassCard(
            radius: 24,
            borderColor: _isHovered ? widget.color.withOpacity(0.5) : Color(0x1AFFFFFF),
            fillColor: _isHovered ? widget.color.withOpacity(0.08) : Color(0x0AFFFFFF),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 12),
                  // Glow icon container
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color.withOpacity(0.1),
                    ),
                    child: ShaderMask(
                      shaderCallback: (bounds) => widget.gradient.createShader(bounds),
                      child: Icon(
                        widget.icon,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: _isHovered ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    widget.desc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16),
                  // "Get Started" Arrow
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 200),
                    opacity: _isHovered ? 1.0 : 0.6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ENTER',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.color,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: widget.color,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
