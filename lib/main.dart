import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/services/services.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/presentation_hub.dart';
import 'screens/patient/patient_dashboard.dart';
import 'screens/doctor/doctor_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MedicateProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    AppTheme.updateThemeMode(provider.themeMode == ThemeMode.dark);

    return MaterialApp(
      title: 'SmartMed Portal',
      debugShowCheckedModeBanner: false,
      themeMode: provider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      builder: (context, child) {
        return provider.isPresentationMode
            ? (child ?? const SizedBox())
            : MobileViewFrame(child: child ?? const SizedBox());
      },
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    final user = provider.currentUser;

    if (user == null) {
      return RoleSelectionScreen();
    }

    switch (user.role) {
      case UserRole.patient:
        return PatientDashboard();
      case UserRole.doctor:
        return DoctorDashboard();
      case UserRole.admin:
        return AdminDashboard();
    }
  }
}
