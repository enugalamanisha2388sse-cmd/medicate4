import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';
import '../patient/patient_dashboard.dart';
import '../doctor/doctor_dashboard.dart';
import '../admin/admin_dashboard.dart';

class LoginSignupScreen extends StatefulWidget {
  final UserRole role;

  LoginSignupScreen({super.key, required this.role});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Input Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminCodeController = TextEditingController();

  bool _isEmailOtp = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }

  String get _roleName {
    switch (widget.role) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  Color get _roleColor {
    switch (widget.role) {
      case UserRole.patient:
        return AppTheme.primaryTeal;
      case UserRole.doctor:
        return AppTheme.primaryIndigo;
      case UserRole.admin:
        return Colors.amber;
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.role == UserRole.admin && _adminCodeController.text.trim() != 'ADMIN2026') {
      _showErrorSnackBar('Invalid Admin Verification Token.');
      return;
    }

    final provider = Provider.of<MedicateProvider>(context, listen: false);
    setState(() => _isLoading = true);

    await Future.delayed(Duration(milliseconds: 600)); // Network simulation

    if (_tabController.index == 0) {
      // LOGIN
      final success = await provider.login(
        _emailController.text,
        _passwordController.text,
        widget.role,
      );

      setState(() => _isLoading = false);

      if (success) {
        _navigateToDashboard();
      } else {
        _showErrorSnackBar('Invalid email, password, or portal mismatch.');
      }
    } else {
      // SIGN UP (Requires OTP)
      try {
        final email = _emailController.text.trim();
        final phone = _phoneController.text.trim();
        final exists = provider.checkEmailExists(email);
        if (exists) {
          setState(() => _isLoading = false);
          _showDuplicateEmailDialog();
          return;
        }

        // Request OTP via Email or SMS
        await provider.requestSignUpOtp(email, phone, _isEmailOtp);
        setState(() => _isLoading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _roleColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            duration: Duration(seconds: 5),
            content: Row(
              children: [
                Icon(Icons.mark_email_read_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Verification OTP requested for ${_isEmailOtp ? email : phone}. Please check your messages.',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
        _showOtpBottomSheet(provider);
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(e.toString());
      }
    }
  }

  void _showDuplicateEmailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.redAccent, width: 1)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Account Exists', style: TextStyle(color: AppTheme.textPrimary)),
          ],
        ),
        content: Text(
          'An account with this email address already exists. Please login or use a different email address.',
          style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _tabController.animateTo(0); // Switch to Login tab
            },
            child: Text('GO TO LOGIN', style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CLOSE', style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _showOtpBottomSheet(MedicateProvider provider) {
    final otpController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: GlassCard(
                radius: 30,
                borderColor: _roleColor.withOpacity(0.3),
                fillColor: AppTheme.background.withOpacity(0.95),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(color: AppTheme.textSecondary.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Security Verification',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _roleColor),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'We have generated a 6-digit OTP code to verify your request. Enter it below to register.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                      SizedBox(height: 24),
                      TextField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, letterSpacing: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: '000000',
                          hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.3), letterSpacing: 16),
                          counterText: '',
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.borderCard)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _roleColor)),
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          if (otpController.text.length == 6) {
                            try {
                              final verified = await provider.verifyOtpAndRegister(
                                _nameController.text,
                                _emailController.text,
                                _passwordController.text,
                                widget.role,
                                _phoneController.text,
                                otpController.text,
                              );
                              if (verified) {
                                Navigator.pop(context); // close sheet
                                _navigateToDashboard();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Verification Failed. Invalid OTP.')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Registration Error: $e')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _roleColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                        ),
                        child: Text('VERIFY & REGISTER', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToDashboard() {
    Widget dashboard;
    switch (widget.role) {
      case UserRole.patient:
        dashboard = PatientDashboard();
        break;
      case UserRole.doctor:
        dashboard = DoctorDashboard();
        break;
      case UserRole.admin:
        dashboard = AdminDashboard();
        break;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => dashboard),
      (route) => false,
    );
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(msg, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: _roleColor.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.lock_reset_rounded, color: _roleColor),
            SizedBox(width: 8),
            Text('Reset Password', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your email address below, and we will simulate sending a password reset verification link.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Email Address',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
                prefixIcon: Icon(Icons.mail_outline, color: _roleColor),
                filled: true,
                fillColor: Colors.black.withOpacity(0.15),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.borderCard)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _roleColor)),
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(side: BorderSide(color: AppTheme.borderCard)),
            child: Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final email = resetEmailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid email address.')),
                );
                return;
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: _roleColor,
                  content: Text('SUCCESS: Simulated password reset link sent to $email.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: _roleColor),
            child: Text('SEND LINK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: DynamicBackground(
        child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  _roleName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _roleColor,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome Portal',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Manage and coordinate your medical activities securely.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 32),

                // Beautiful Tab Bar
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppTheme.textSecondary,
                    indicator: BoxDecoration(
                      color: _roleColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tabs: [
                      Tab(text: 'LOGIN'),
                      Tab(text: 'SIGN UP'),
                    ],
                  ),
                ),
                SizedBox(height: 32),

                // Credentials Inputs
                GlassCard(
                  radius: 24,
                  borderColor: _roleColor.withOpacity(0.1),
                  child: AnimatedBuilder(
                    animation: _tabController.animation!,
                    builder: (context, child) {
                      final isSignUp = _tabController.index == 1;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (isSignUp) ...[
                            TextFormField(
                              controller: _nameController,
                              style: TextStyle(color: AppTheme.textPrimary),
                              decoration: _inputDecoration('Full Name', Icons.person_outline),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Please enter your name';
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _phoneController,
                              style: TextStyle(color: AppTheme.textPrimary),
                              keyboardType: TextInputType.phone,
                              decoration: _inputDecoration('Phone Number', Icons.phone_android_rounded),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Please enter your phone number';
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            Text(
                              'OTP Delivery Method:',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ChoiceChip(
                                    label: Text('Gmail / Email', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                    selected: _isEmailOtp,
                                    selectedColor: _roleColor,
                                    backgroundColor: AppTheme.cardColor,
                                    onSelected: (val) {
                                      setState(() => _isEmailOtp = true);
                                    },
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: ChoiceChip(
                                    label: Text('Phone SMS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                    selected: !_isEmailOtp,
                                    selectedColor: _roleColor,
                                    backgroundColor: AppTheme.cardColor,
                                    onSelected: (val) {
                                      setState(() => _isEmailOtp = false);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                          ],
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: AppTheme.textPrimary),
                            decoration: _inputDecoration('Email Address', Icons.mail_outline),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Please enter email';
                              if (!v.contains('@')) return 'Please enter valid email';
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(color: AppTheme.textPrimary),
                            decoration: _inputDecoration(
                              'Password',
                              Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Please enter password';
                              if (v.length < 6) return 'Password must be at least 6 characters';
                              return null;
                            },
                          ),
                          if (!isSignUp) ...[
                            SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showForgotPasswordDialog,
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: _roleColor, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                          if (widget.role == UserRole.admin) ...[
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _adminCodeController,
                              obscureText: true,
                              style: TextStyle(color: AppTheme.textPrimary),
                              decoration: _inputDecoration('Admin Verification Token (ADMIN2026)', Icons.security_rounded),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Please enter admin token';
                                return null;
                              },
                            ),
                          ],
                          SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _roleColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: EdgeInsets.symmetric(vertical: 18),
                              elevation: 0,
                            ),
                            child: _isLoading
                                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text(
                                      isSignUp ? 'SIGN UP & GET OTP' : 'LOGIN NOW',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
      prefixIcon: Icon(icon, color: _roleColor),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.black.withOpacity(0.2),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppTheme.borderCard),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _roleColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
