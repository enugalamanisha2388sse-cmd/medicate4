import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../theme.dart';

// ==========================================
// MODELS
// ==========================================

enum UserRole { patient, doctor, admin }

enum BluetoothDeviceType { watch, ring, none }
enum BluetoothConnectionStatus { disconnected, scanning, connecting, connected }

class BluetoothSensorDevice {
  final String id;
  final String name;
  final BluetoothDeviceType type;
  final int batteryLevel;
  final int signalStrength; // RSSI in dBm

  BluetoothSensorDevice({
    required this.id,
    required this.name,
    required this.type,
    this.batteryLevel = 85,
    this.signalStrength = -60,
  });
}

class UserAccount {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String phone;
  final String bio;
  final String licenseNumber;
  final String specialty;
  final double rating;
  final double consultFee;
  final String hospitalId;
  final String hospitalName;
  final List<int> patientsThisWeek; // length 7, mon to sun

  UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.phone = '+1 (555) 000-0000',
    this.bio = 'No bio provided.',
    this.licenseNumber = 'N/A',
    this.specialty = 'General Practice',
    this.rating = 4.8,
    this.consultFee = 50.0,
    this.hospitalId = '',
    this.hospitalName = '',
    List<int>? patientsThisWeek,
  }) : this.patientsThisWeek = patientsThisWeek ?? [5, 8, 6, 7, 5, 2, 0];

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'role': role.name,
    'phone': phone,
    'bio': bio,
    'licenseNumber': licenseNumber,
    'specialty': specialty,
    'rating': rating,
    'consultFee': consultFee,
    'hospitalId': hospitalId,
    'hospitalName': hospitalName,
    'patientsThisWeek': patientsThisWeek,
  };

  factory UserAccount.fromMap(Map<String, dynamic> map) => UserAccount(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    password: map['password'] ?? '',
    role: UserRole.values.firstWhere((e) => e.name == map['role'], orElse: () => UserRole.patient),
    phone: map['phone'] ?? '+1 (555) 000-0000',
    bio: map['bio'] ?? 'No bio provided.',
    licenseNumber: map['licenseNumber'] ?? 'N/A',
    specialty: map['specialty'] ?? 'General Practice',
    rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
    consultFee: (map['consultFee'] as num?)?.toDouble() ?? 50.0,
    hospitalId: map['hospitalId'] ?? '',
    hospitalName: map['hospitalName'] ?? '',
    patientsThisWeek: List<int>.from(map['patientsThisWeek'] ?? [5, 8, 6, 7, 5, 2, 0]),
  );
}

class AppNotification {
  final String id;
  final String text;
  final DateTime timestamp;
  bool isRead;

  AppNotification({
    required this.id,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'isRead': isRead,
  };

  factory AppNotification.fromMap(Map<String, dynamic> map) => AppNotification(
    id: map['id'] ?? '',
    text: map['text'] ?? '',
    timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
    isRead: map['isRead'] ?? false,
  );
}

class VaccineRecord {
  final String id;
  final String name;
  final String status; // 'Taken', 'Scheduled', 'Available'
  final DateTime? date;

  VaccineRecord({
    required this.id,
    required this.name,
    required this.status,
    this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'status': status,
    'date': date?.millisecondsSinceEpoch,
  };

  factory VaccineRecord.fromMap(Map<String, dynamic> map) => VaccineRecord(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    status: map['status'] ?? 'Available',
    date: map['date'] != null ? DateTime.fromMillisecondsSinceEpoch(map['date']) : null,
  );
}

class Hospital {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String contact;
  int vacancy;
  final int totalBeds;

  Hospital({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.contact,
    required this.vacancy,
    required this.totalBeds,
  });

  Hospital copyWith({int? vacancy}) {
    return Hospital(
      id: id,
      name: name,
      lat: lat,
      lng: lng,
      contact: contact,
      vacancy: vacancy ?? this.vacancy,
      totalBeds: totalBeds,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'lat': lat,
    'lng': lng,
    'contact': contact,
    'vacancy': vacancy,
    'totalBeds': totalBeds,
  };

  factory Hospital.fromMap(Map<String, dynamic> map) => Hospital(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
    lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
    contact: map['contact'] ?? '',
    vacancy: map['vacancy'] ?? 0,
    totalBeds: map['totalBeds'] ?? 0,
  );
}

class Medicine {
  final String id;
  final String name;
  final String category;
  final double price;
  final String description;
  int stock;

  Medicine({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.stock,
  });

  Medicine copyWith({int? stock, double? price}) {
    return Medicine(
      id: id,
      name: name,
      category: category,
      price: price ?? this.price,
      description: description,
      stock: stock ?? this.stock,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'price': price,
    'description': description,
    'stock': stock,
  };

  factory Medicine.fromMap(Map<String, dynamic> map) => Medicine(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    category: map['category'] ?? '',
    price: (map['price'] as num?)?.toDouble() ?? 0.0,
    description: map['description'] ?? '',
    stock: map['stock'] ?? 0,
  );
}

class CartItem {
  final Medicine medicine;
  int quantity;

  CartItem({required this.medicine, this.quantity = 1});

  Map<String, dynamic> toMap() => {
    'medicine': medicine.toMap(),
    'quantity': quantity,
  };

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
    medicine: Medicine.fromMap(map['medicine'] ?? {}),
    quantity: map['quantity'] ?? 1,
  );
}

class InventoryItem {
  final String id;
  final String name;
  final String category;
  int stock;
  final int threshold; // low stock alert below this
  final DateTime expiryDate;
  final String unit; // tablets, ml, capsules

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.stock,
    required this.threshold,
    required this.expiryDate,
    this.unit = 'tablets',
  });

  bool get isLowStock => stock <= threshold;
  bool get isExpiringSoon => expiryDate.difference(DateTime.now()).inDays <= 30;
  bool get isExpired => expiryDate.isBefore(DateTime.now());

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'stock': stock,
    'threshold': threshold,
    'expiryDate': expiryDate.toIso8601String(),
    'unit': unit,
  };

  factory InventoryItem.fromMap(Map<String, dynamic> map) => InventoryItem(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    category: map['category'] ?? '',
    stock: map['stock'] ?? 0,
    threshold: map['threshold'] ?? 0,
    expiryDate: DateTime.parse(map['expiryDate'] ?? DateTime.now().toIso8601String()),
    unit: map['unit'] ?? 'tablets',
  );
}

class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorName;
  final String department;
  final DateTime dateTime;
  String status; // 'Pending', 'Approved', 'Cancelled', 'Completed'

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorName,
    required this.department,
    required this.dateTime,
    this.status = 'Pending',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'patientId': patientId,
    'patientName': patientName,
    'doctorName': doctorName,
    'department': department,
    'dateTime': dateTime.millisecondsSinceEpoch,
    'status': status,
  };

  factory Appointment.fromMap(Map<String, dynamic> map) => Appointment(
    id: map['id'] ?? '',
    patientId: map['patientId'] ?? '',
    patientName: map['patientName'] ?? '',
    doctorName: map['doctorName'] ?? '',
    department: map['department'] ?? '',
    dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime'] ?? DateTime.now().millisecondsSinceEpoch),
    status: map['status'] ?? 'Pending',
  );
}

class MedicineReminder {
  final String id;
  final String medicineName;
  final String dosage;
  final String time; // e.g., "08:00 AM"
  bool isTaken;

  MedicineReminder({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.time,
    this.isTaken = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'medicineName': medicineName,
    'dosage': dosage,
    'time': time,
    'isTaken': isTaken,
  };

  factory MedicineReminder.fromMap(Map<String, dynamic> map) => MedicineReminder(
    id: map['id'] ?? '',
    medicineName: map['medicineName'] ?? '',
    dosage: map['dosage'] ?? '',
    time: map['time'] ?? '',
    isTaken: map['isTaken'] ?? false,
  );
}

class SymptomLog {
  final String id;
  final String symptom;
  final double severity; // 1.0 to 10.0
  final DateTime timestamp;

  SymptomLog({
    required this.id,
    required this.symptom,
    required this.severity,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'symptom': symptom,
    'severity': severity,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };

  factory SymptomLog.fromMap(Map<String, dynamic> map) => SymptomLog(
    id: map['id'] ?? '',
    symptom: map['symptom'] ?? '',
    severity: (map['severity'] as num?)?.toDouble() ?? 1.0,
    timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
  );
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
    id: map['id'] ?? '',
    text: map['text'] ?? '',
    isUser: map['isUser'] ?? false,
    timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
  );
}

class Prescription {
  final String id;
  final String patientId;
  final String doctorName;
  final String medicineName;
  final String dosage;
  final DateTime date;

  Prescription({
    required this.id,
    required this.patientId,
    required this.doctorName,
    required this.medicineName,
    required this.dosage,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'patientId': patientId,
    'doctorName': doctorName,
    'medicineName': medicineName,
    'dosage': dosage,
    'date': date.millisecondsSinceEpoch,
  };

  factory Prescription.fromMap(Map<String, dynamic> map) => Prescription(
    id: map['id'] ?? '',
    patientId: map['patientId'] ?? '',
    doctorName: map['doctorName'] ?? '',
    medicineName: map['medicineName'] ?? '',
    dosage: map['dosage'] ?? '',
    date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? DateTime.now().millisecondsSinceEpoch),
  );
}

class LiveVehicle {
  final String id;
  final String type; // 'Ambulance' or 'Med-Drone'
  final String status; // 'Responding', 'Returning', 'Dispatched'
  double lat;
  double lng;
  final String targetHospital;

  LiveVehicle({
    required this.id,
    required this.type,
    required this.status,
    required this.lat,
    required this.lng,
    required this.targetHospital,
  });
}

// ==========================================
// CENTRAL STATE & SERVICE PROVIDER
// ==========================================

class PatientRecord {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String medicalHistory;
  final String allergies;

  PatientRecord({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.medicalHistory,
    required this.allergies,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'age': age,
    'gender': gender,
    'medicalHistory': medicalHistory,
    'allergies': allergies,
  };

  factory PatientRecord.fromMap(Map<String, dynamic> map) => PatientRecord(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    age: map['age'] ?? 0,
    gender: map['gender'] ?? 'Male',
    medicalHistory: map['medicalHistory'] ?? '',
    allergies: map['allergies'] ?? '',
  );
}

class FirebaseService {
  static bool isInitialized = false;

  static Future<void> initialize() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      isInitialized = true;
      print("Firebase successfully initialized!");
    } catch (e) {
      isInitialized = false;
      print("Firebase initialization failed/skipped: $e. Using local database fallback.");
    }
  }
}

class SecurityLogger {
  static const String baseUrl = 'http://localhost:3000/api/security';
  static const String apiKey = 'medicate-security-key-2026';

  static Future<void> logEvent({
    required String type,
    String? userId,
    String? requestInfo,
    String? status,
    String? description,
  }) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/events'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'type': type,
          'userId': userId,
          'requestInfo': requestInfo,
          'status': status,
          'description': description,
        }),
      ).timeout(const Duration(seconds: 3));
    } catch (e) {
      print('SecurityLogger failed: $e');
    }
  }

  static Future<List<dynamic>> getEvents() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/events'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) {}
    return [];
  }

  static Future<List<dynamic>> getAlerts() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/alerts'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) {}
    return [];
  }

  static Future<Map<String, dynamic>> getStats() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/stats'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) {}
    return {
      'totalEvents': 0, 'successfulLogins': 0, 'failedLogins': 0, 'unauthorizedRequests': 0
    };
  }
}

class MedicateProvider with ChangeNotifier {
  MedicateProvider() {
    initDatabase();
    startRealTimeSimulation();
  }

  Future<void> initDatabase() async {
    if (FirebaseService.isInitialized) {
      _setupFirestoreSync();
      await _seedFirestoreIfEmpty();
    } else {
      await _loadLocalData();
    }
  }

  // Local persistence loaders/savers
  Future<void> _loadLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final usersJson = prefs.getString('users');
      if (usersJson != null) {
        final List decoded = jsonDecode(usersJson);
        _users.clear();
        _users.addAll(decoded.map((e) => UserAccount.fromMap(e)).toList());
      }
      
      final patientsJson = prefs.getString('patients');
      if (patientsJson != null) {
        final List decoded = jsonDecode(patientsJson);
        _patients.clear();
        _patients.addAll(decoded.map((e) => PatientRecord.fromMap(e)).toList());
      }

      final hospitalsJson = prefs.getString('hospitals');
      if (hospitalsJson != null) {
        final List decoded = jsonDecode(hospitalsJson);
        _hospitals.clear();
        _hospitals.addAll(decoded.map((e) => Hospital.fromMap(e)).toList());
      }

      final medicinesJson = prefs.getString('medicines');
      if (medicinesJson != null) {
        final List decoded = jsonDecode(medicinesJson);
        _medicines.clear();
        _medicines.addAll(decoded.map((e) => Medicine.fromMap(e)).toList());
      }

      final apptsJson = prefs.getString('appointments');
      if (apptsJson != null) {
        final List decoded = jsonDecode(apptsJson);
        _appointments.clear();
        _appointments.addAll(decoded.map((e) => Appointment.fromMap(e)).toList());
      }

      final remindersJson = prefs.getString('reminders');
      if (remindersJson != null) {
        final List decoded = jsonDecode(remindersJson);
        _reminders.clear();
        _reminders.addAll(decoded.map((e) => MedicineReminder.fromMap(e)).toList());
      }

      final symptomsJson = prefs.getString('symptoms');
      if (symptomsJson != null) {
        final List decoded = jsonDecode(symptomsJson);
        _symptoms.clear();
        _symptoms.addAll(decoded.map((e) => SymptomLog.fromMap(e)).toList());
      }

      final chatJson = prefs.getString('chat_messages');
      if (chatJson != null) {
        final List decoded = jsonDecode(chatJson);
        _chatMessages.clear();
        _chatMessages.addAll(decoded.map((e) => ChatMessage.fromMap(e)).toList());
      }

      final prescriptionsJson = prefs.getString('prescriptions');
      if (prescriptionsJson != null) {
        final List decoded = jsonDecode(prescriptionsJson);
        _prescriptions.clear();
        _prescriptions.addAll(decoded.map((e) => Prescription.fromMap(e)).toList());
      }

      final notifsJson = prefs.getString('notifications');
      if (notifsJson != null) {
        final List decoded = jsonDecode(notifsJson);
        _notifications.clear();
        _notifications.addAll(decoded.map((e) => AppNotification.fromMap(e)).toList());
      }

      final vaccinesJson = prefs.getString('vaccines');
      if (vaccinesJson != null) {
        final List decoded = jsonDecode(vaccinesJson);
        _vaccines.clear();
        _vaccines.addAll(decoded.map((e) => VaccineRecord.fromMap(e)).toList());
      }

      final inventoryJson = prefs.getString('inventory');
      if (inventoryJson != null) {
        final List decoded = jsonDecode(inventoryJson);
        _inventory.clear();
        _inventory.addAll(decoded.map((e) => InventoryItem.fromMap(e)).toList());
      }
      
      final curUserId = prefs.getString('current_user_id');
      if (curUserId != null) {
        _currentUser = _users.firstWhere((u) => u.id == curUserId, orElse: () => _users.first);
      }

      _isMaintenanceMode = prefs.getBool('is_maintenance_mode') ?? false;
      _isDebugTelemetryLogging = prefs.getBool('is_debug_telemetry_logging') ?? true;
      _emailNotifications = prefs.getBool('emailNotifications') ?? true;
      _smsAlertsBroadcast = prefs.getBool('smsAlertsBroadcast') ?? true;
      _pushNotifications = prefs.getBool('pushNotifications') ?? true;
      _lowAdherenceAlerts = prefs.getBool('lowAdherenceAlerts') ?? true;
      _highRiskContraindications = prefs.getBool('highRiskContraindications') ?? true;
      _lowStockWarnings = prefs.getBool('lowStockWarnings') ?? true;
      _weeklyPerformanceSummary = prefs.getBool('weeklyPerformanceSummary') ?? false;
      _twoFactorAuth = prefs.getBool('twoFactorAuth') ?? true;
      _biometricAuth = prefs.getBool('biometricAuth') ?? false;
      _enforcePasswordRotation = prefs.getBool('enforcePasswordRotation') ?? true;
      _automatedDailyBackup = prefs.getBool('automatedDailyBackup') ?? true;
      _autoInstallSecurityPatches = prefs.getBool('autoInstallSecurityPatches') ?? true;
      _betaReleaseChannel = prefs.getBool('betaReleaseChannel') ?? false;
      _systemVersion = prefs.getString('systemVersion') ?? 'Version 2.4.0 (Build 24082)';
      _lastUpdateCheck = prefs.getString('lastUpdateCheck') ?? 'Today, 06:15 PM';
    } catch (e) {
      print("Error loading local data: $e");
    }
  }

  Future<void> _saveLocalData(String key, List list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mapped = list.map((e) {
        if (e is UserAccount) return e.toMap();
        if (e is PatientRecord) return e.toMap();
        if (e is Hospital) return e.toMap();
        if (e is Medicine) return e.toMap();
        if (e is Appointment) return e.toMap();
        if (e is MedicineReminder) return e.toMap();
        if (e is SymptomLog) return e.toMap();
        if (e is ChatMessage) return e.toMap();
        if (e is Prescription) return e.toMap();
        if (e is AppNotification) return e.toMap();
        if (e is VaccineRecord) return e.toMap();
        if (e is InventoryItem) return e.toMap();
        return {};
      }).toList();
      await prefs.setString(key, jsonEncode(mapped));
    } catch (e) {
      print("Error saving local data key '$key': $e");
    }
  }

  // Firestore Sync Listeners
  void _setupFirestoreSync() {
    FirebaseFirestore.instance.collection('users').snapshots().listen((snapshot) {
      _users.clear();
      for (var doc in snapshot.docs) {
        _users.add(UserAccount.fromMap(doc.data()));
      }
      notifyListeners();
    });

    FirebaseFirestore.instance.collection('patients').snapshots().listen((snapshot) {
      _patients.clear();
      for (var doc in snapshot.docs) {
        _patients.add(PatientRecord.fromMap(doc.data()));
      }
      notifyListeners();
    });

    FirebaseFirestore.instance.collection('hospitals').snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _hospitals.clear();
        for (var doc in snapshot.docs) {
          _hospitals.add(Hospital.fromMap(doc.data()));
        }
        notifyListeners();
      }
    });

    FirebaseFirestore.instance.collection('medicines').snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _medicines.clear();
        for (var doc in snapshot.docs) {
          _medicines.add(Medicine.fromMap(doc.data()));
        }
        notifyListeners();
      }
    });

    FirebaseFirestore.instance.collection('appointments').snapshots().listen((snapshot) {
      _appointments.clear();
      for (var doc in snapshot.docs) {
        _appointments.add(Appointment.fromMap(doc.data()));
      }
      notifyListeners();
    });

    FirebaseFirestore.instance.collection('reminders').snapshots().listen((snapshot) {
      _reminders.clear();
      for (var doc in snapshot.docs) {
        _reminders.add(MedicineReminder.fromMap(doc.data()));
      }
      notifyListeners();
    });

    FirebaseFirestore.instance.collection('symptoms').snapshots().listen((snapshot) {
      _symptoms.clear();
      for (var doc in snapshot.docs) {
        _symptoms.add(SymptomLog.fromMap(doc.data()));
      }
      notifyListeners();
    });

    FirebaseFirestore.instance.collection('chat_messages').snapshots().listen((snapshot) {
      _chatMessages.clear();
      for (var doc in snapshot.docs) {
        _chatMessages.add(ChatMessage.fromMap(doc.data()));
      }
      _chatMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      notifyListeners();
    });

    FirebaseFirestore.instance.collection('prescriptions').snapshots().listen((snapshot) {
      _prescriptions.clear();
      for (var doc in snapshot.docs) {
        _prescriptions.add(Prescription.fromMap(doc.data()));
      }
      notifyListeners();
    });

    FirebaseFirestore.instance.collection('notifications').snapshots().listen((snapshot) {
      _notifications.clear();
      for (var doc in snapshot.docs) {
        _notifications.add(AppNotification.fromMap(doc.data()));
      }
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    });

    FirebaseFirestore.instance.collection('vaccines').snapshots().listen((snapshot) {
      _vaccines.clear();
      for (var doc in snapshot.docs) {
        _vaccines.add(VaccineRecord.fromMap(doc.data()));
      }
      notifyListeners();
    });

    FirebaseFirestore.instance.collection('inventory').snapshots().listen((snapshot) {
      _inventory.clear();
      for (var doc in snapshot.docs) {
        _inventory.add(InventoryItem.fromMap(doc.data()));
      }
      notifyListeners();
    });
    
    fb.FirebaseAuth.instance.authStateChanges().listen((fbUser) async {
      if (fbUser != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).get();
        if (doc.exists) {
          _currentUser = UserAccount.fromMap(doc.data()!);
        } else {
          _currentUser = UserAccount(
            id: fbUser.uid,
            name: fbUser.displayName ?? 'Standard Patient',
            email: fbUser.email ?? '',
            password: '',
            role: UserRole.patient,
          );
        }
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  Future<void> _seedFirestoreIfEmpty() async {
    try {
      final hs = await FirebaseFirestore.instance.collection('hospitals').limit(1).get();
      if (hs.docs.isEmpty) {
        for (var h in _hospitals) {
          await FirebaseFirestore.instance.collection('hospitals').doc(h.id).set(h.toMap());
        }
      }
      final ms = await FirebaseFirestore.instance.collection('medicines').limit(1).get();
      if (ms.docs.isEmpty) {
        for (var m in _medicines) {
          await FirebaseFirestore.instance.collection('medicines').doc(m.id).set(m.toMap());
        }
      }
      final ns = await FirebaseFirestore.instance.collection('notifications').limit(1).get();
      if (ns.docs.isEmpty) {
        for (var n in _notifications) {
          await FirebaseFirestore.instance.collection('notifications').doc(n.id).set(n.toMap());
        }
      }
      final vs = await FirebaseFirestore.instance.collection('vaccines').limit(1).get();
      if (vs.docs.isEmpty) {
        for (var v in _vaccines) {
          await FirebaseFirestore.instance.collection('vaccines').doc(v.id).set(v.toMap());
        }
      }
      final invs = await FirebaseFirestore.instance.collection('inventory').limit(1).get();
      if (invs.docs.isEmpty) {
        for (var i in _inventory) {
          await FirebaseFirestore.instance.collection('inventory').doc(i.id).set(i.toMap());
        }
      }
    } catch (e) {
      print("Error seeding Firestore: $e");
    }
  }

  // Theme State
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    AppTheme.updateThemeMode(_themeMode == ThemeMode.dark);
    notifyListeners();
  }

  // Presentation Mode state
  bool _isPresentationMode = true;
  bool get isPresentationMode => _isPresentationMode;

  void setPresentationMode(bool value) {
    _isPresentationMode = value;
    notifyListeners();
  }

  // Maintenance Mode & Debug Telemetry Logging state
  bool _isMaintenanceMode = false;
  bool get isMaintenanceMode => _isMaintenanceMode;

  void setMaintenanceMode(bool value) async {
    _isMaintenanceMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_maintenance_mode', value);
    await addNotification(value 
        ? "SYSTEM WARNING: Maintenance Mode activated by Admin." 
        : "SYSTEM INFO: Maintenance Mode deactivated.");
    notifyListeners();
  }

  bool _isDebugTelemetryLogging = true;
  bool get isDebugTelemetryLogging => _isDebugTelemetryLogging;

  void setDebugTelemetryLogging(bool value) async {
    _isDebugTelemetryLogging = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_debug_telemetry_logging', value);
    await addNotification(value 
        ? "SYSTEM INFO: Debug Telemetry Logging enabled." 
        : "SYSTEM INFO: Debug Telemetry Logging disabled.");
    notifyListeners();
  }

  // System & Notification Toggle Preferences
  bool _emailNotifications = true;
  bool get emailNotifications => _emailNotifications;
  void setEmailNotifications(bool value) async {
    _emailNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('emailNotifications', value);
    notifyListeners();
  }

  bool _smsAlertsBroadcast = true;
  bool get smsAlertsBroadcast => _smsAlertsBroadcast;
  void setSmsAlertsBroadcast(bool value) async {
    _smsAlertsBroadcast = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('smsAlertsBroadcast', value);
    notifyListeners();
  }

  bool _pushNotifications = true;
  bool get pushNotifications => _pushNotifications;
  void setPushNotifications(bool value) async {
    _pushNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pushNotifications', value);
    notifyListeners();
  }

  bool _lowAdherenceAlerts = true;
  bool get lowAdherenceAlerts => _lowAdherenceAlerts;
  void setLowAdherenceAlerts(bool value) async {
    _lowAdherenceAlerts = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lowAdherenceAlerts', value);
    notifyListeners();
  }

  bool _highRiskContraindications = true;
  bool get highRiskContraindications => _highRiskContraindications;
  void setHighRiskContraindications(bool value) async {
    _highRiskContraindications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('highRiskContraindications', value);
    notifyListeners();
  }

  bool _lowStockWarnings = true;
  bool get lowStockWarnings => _lowStockWarnings;
  void setLowStockWarnings(bool value) async {
    _lowStockWarnings = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lowStockWarnings', value);
    notifyListeners();
  }

  bool _weeklyPerformanceSummary = false;
  bool get weeklyPerformanceSummary => _weeklyPerformanceSummary;
  void setWeeklyPerformanceSummary(bool value) async {
    _weeklyPerformanceSummary = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('weeklyPerformanceSummary', value);
    notifyListeners();
  }

  bool _twoFactorAuth = true;
  bool get twoFactorAuth => _twoFactorAuth;
  void setTwoFactorAuth(bool value) async {
    _twoFactorAuth = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('twoFactorAuth', value);
    notifyListeners();
  }

  bool _biometricAuth = false;
  bool get biometricAuth => _biometricAuth;
  void setBiometricAuth(bool value) async {
    _biometricAuth = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometricAuth', value);
    notifyListeners();
  }

  bool _enforcePasswordRotation = true;
  bool get enforcePasswordRotation => _enforcePasswordRotation;
  void setEnforcePasswordRotation(bool value) async {
    _enforcePasswordRotation = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enforcePasswordRotation', value);
    notifyListeners();
  }

  bool _automatedDailyBackup = true;
  bool get automatedDailyBackup => _automatedDailyBackup;
  void setAutomatedDailyBackup(bool value) async {
    _automatedDailyBackup = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('automatedDailyBackup', value);
    notifyListeners();
  }

  bool _autoInstallSecurityPatches = true;
  bool get autoInstallSecurityPatches => _autoInstallSecurityPatches;
  void setAutoInstallSecurityPatches(bool value) async {
    _autoInstallSecurityPatches = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoInstallSecurityPatches', value);
    notifyListeners();
  }

  bool _betaReleaseChannel = false;
  bool get betaReleaseChannel => _betaReleaseChannel;
  void setBetaReleaseChannel(bool value) async {
    _betaReleaseChannel = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('betaReleaseChannel', value);
    notifyListeners();
  }

  // System Update State
  String _systemVersion = 'Version 2.4.0 (Build 24082)';
  String get systemVersion => _systemVersion;

  String _lastUpdateCheck = 'Today, 06:15 PM';
  String get lastUpdateCheck => _lastUpdateCheck;

  bool _isCheckingUpdates = false;
  bool get isCheckingUpdates => _isCheckingUpdates;

  String _updateProgressStatus = 'Your system is fully up to date with the latest clinical AI models, security patches, and database telemetry drivers.';
  String get updateProgressStatus => _updateProgressStatus;

  double _updateProgress = 0.0;
  double get updateProgress => _updateProgress;

  Future<void> performSystemUpdateCheck() async {
    if (_isCheckingUpdates) return;
    _isCheckingUpdates = true;
    _updateProgress = 0.15;
    _updateProgressStatus = 'Connecting to Medicate Cloud Telemetry Servers...';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    _updateProgress = 0.40;
    _updateProgressStatus = 'Verifying Clinical AI diagnostic models and drug contraindication database...';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));
    _updateProgress = 0.70;
    _updateProgressStatus = 'Downloading security patch v2.4.1 (Build 24105)...';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));
    _updateProgress = 0.90;
    _updateProgressStatus = 'Applying schema migrations and telemetry driver updates...';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));
    _systemVersion = 'Version 2.4.1 (Latest & Verified)';
    _lastUpdateCheck = 'Just now';
    _updateProgress = 1.0;
    _isCheckingUpdates = false;
    _updateProgressStatus = 'Your system has been successfully verified and updated! All clinical AI models, telemetry drivers, and security patches are running on the latest build.';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('systemVersion', _systemVersion);
    await prefs.setString('lastUpdateCheck', _lastUpdateCheck);

    await addNotification('SYSTEM UPDATE: Verification complete. Platform updated to Version 2.4.1.');
    notifyListeners();
  }

  // Patient Records CRUD State
  final List<PatientRecord> _patients = [
    PatientRecord(id: 'p1', name: 'Alice Smith', age: 34, gender: 'Female', medicalHistory: 'Chronic Asthma, Migraine', allergies: 'Penicillin, Dust'),
    PatientRecord(id: 'p2', name: 'Robert Johnson', age: 45, gender: 'Male', medicalHistory: 'Type 2 Diabetes, Hypertension', allergies: 'Peanuts'),
    PatientRecord(id: 'p3', name: 'Emily Davis', age: 29, gender: 'Female', medicalHistory: 'Seasonal Rhinitis', allergies: 'Sulfonamides'),
  ];

  List<PatientRecord> get patients => _patients;

  Future<void> addPatient(String name, int age, String gender, String medicalHistory, String allergies) async {
    final patient = PatientRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      age: age,
      gender: gender,
      medicalHistory: medicalHistory,
      allergies: allergies,
    );

    if (FirebaseService.isInitialized) {
      await FirebaseFirestore.instance.collection('patients').doc(patient.id).set(patient.toMap());
    } else {
      _patients.add(patient);
      await _saveLocalData('patients', _patients);
      notifyListeners();
    }
    await addNotification("SUCCESS: Added patient record for $name.");
  }

  Future<void> addDoctor({
    required String name,
    required String email,
    required String specialty,
    required String phone,
    required String licenseNumber,
    required double consultFee,
    String bio = '',
    String hospitalId = '',
    String hospitalName = '',
  }) async {
    final docId = DateTime.now().millisecondsSinceEpoch.toString();
    final doctor = UserAccount(
      id: docId,
      name: name.startsWith('Dr.') ? name : 'Dr. $name',
      email: email.trim().isEmpty ? 'doctor_$docId@medicate.com' : email.trim().toLowerCase(),
      password: 'password123',
      role: UserRole.doctor,
      phone: phone.isNotEmpty ? phone : '+1 (555) 000-0000',
      licenseNumber: licenseNumber.isNotEmpty ? licenseNumber : 'MD-$docId',
      specialty: specialty.isNotEmpty ? specialty : 'General Practice',
      rating: 4.8,
      consultFee: consultFee > 0 ? consultFee : 500.0,
      bio: bio.isNotEmpty ? bio : 'Medical practitioner specializing in ${specialty.isNotEmpty ? specialty : "General Practice"}.',
      hospitalId: hospitalId,
      hospitalName: hospitalName,
    );

    if (FirebaseService.isInitialized) {
      await FirebaseFirestore.instance.collection('users').doc(doctor.id).set(doctor.toMap());
    } else {
      _users.add(doctor);
      await _saveLocalData('users', _users);
      notifyListeners();
    }
    await addNotification("SUCCESS: Added doctor ${doctor.name} (${doctor.specialty}).");
  }

  Future<void> deleteDoctor(String id) async {
    String name = 'Doctor';
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx != -1) name = _users[idx].name;

    if (FirebaseService.isInitialized) {
      await FirebaseFirestore.instance.collection('users').doc(id).delete();
    } else {
      if (idx != -1) {
        _users.removeAt(idx);
        await _saveLocalData('users', _users);
        notifyListeners();
      }
    }
    await addNotification("WARNING: Removed doctor account for $name.");
  }

  Future<void> addMedicine({
    required String name,
    required String category,
    required int stock,
    required double price,
    String unit = 'tablets',
    int threshold = 15,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newItem = InventoryItem(
      id: 'inv_$timestamp',
      name: name,
      category: category.isEmpty ? 'General' : category,
      stock: stock,
      threshold: threshold,
      expiryDate: DateTime.now().add(const Duration(days: 365)),
      unit: unit.isEmpty ? 'tablets' : unit,
    );

    final newMed = Medicine(
      id: 'm_$timestamp',
      name: name,
      category: category.isEmpty ? 'General' : category,
      price: price > 0 ? price : 50.0,
      description: '$category medication: $name.',
      stock: stock,
    );

    _inventory.insert(0, newItem);
    _medicines.insert(0, newMed);
    await _saveLocalData('inventory', _inventory);
    await _saveLocalData('medicines', _medicines);
    notifyListeners();

    if (FirebaseService.isInitialized) {
      try {
        await FirebaseFirestore.instance.collection('inventory').doc(newItem.id).set(newItem.toMap());
        await FirebaseFirestore.instance.collection('medicines').doc(newMed.id).set(newMed.toMap());
      } catch (e) {
        print("Firestore error adding medicine: $e");
      }
    }
    await addNotification("SUCCESS: Added medicine '$name' ($stock $unit) to Inventory.");
  }

  Future<void> updatePatient(String id, String name, int age, String gender, String medicalHistory, String allergies) async {
    final patient = PatientRecord(
      id: id,
      name: name,
      age: age,
      gender: gender,
      medicalHistory: medicalHistory,
      allergies: allergies,
    );

    if (FirebaseService.isInitialized) {
      await FirebaseFirestore.instance.collection('patients').doc(id).set(patient.toMap());
    } else {
      final idx = _patients.indexWhere((p) => p.id == id);
      if (idx != -1) {
        _patients[idx] = patient;
        await _saveLocalData('patients', _patients);
        notifyListeners();
      }
    }
    await addNotification("SUCCESS: Updated patient record for $name.");
  }

  Future<void> deletePatient(String id) async {
    String name = 'Patient';
    final idx = _patients.indexWhere((p) => p.id == id);
    if (idx != -1) name = _patients[idx].name;

    if (FirebaseService.isInitialized) {
      await FirebaseFirestore.instance.collection('patients').doc(id).delete();
    } else {
      if (idx != -1) {
        _patients.removeAt(idx);
        await _saveLocalData('patients', _patients);
        notifyListeners();
      }
    }
    await addNotification("WARNING: Deleted patient record for $name.");
  }

  // Drug Interaction Checker
  Map<String, String> checkDrugInteraction(String drugA, String drugB) {
    final da = drugA.trim().toLowerCase();
    final db = drugB.trim().toLowerCase();
    
    if ((da.contains('aspirin') && db.contains('ibuprofen')) || (da.contains('ibuprofen') && db.contains('aspirin'))) {
      return {
        'status': 'High Risk',
        'color': 'red',
        'details': 'Combining Aspirin and Ibuprofen can increase the risk of stomach ulcers and gastrointestinal bleeding. They should not be taken together without professional supervision.'
      };
    } else if ((da.contains('warfarin') && db.contains('aspirin')) || (da.contains('aspirin') && db.contains('warfarin'))) {
      return {
        'status': 'High Risk',
        'color': 'red',
        'details': 'Taking Warfarin with Aspirin dramatically increases blood thinning potency, leading to severe hemorrhage and internal bleeding risks.'
      };
    } else if ((da.contains('atorvastatin') && db.contains('clarithromycin')) || (da.contains('clarithromycin') && db.contains('atorvastatin'))) {
      return {
        'status': 'High Risk',
        'color': 'red',
        'details': 'Clarithromycin significantly increases Atorvastatin plasma concentrations, raising severe risks of rhabdomyolysis and muscle breakdown.'
      };
    } else if ((da.contains('metformin') && db.contains('contrast')) || (da.contains('contrast') && db.contains('metformin'))) {
      return {
        'status': 'Moderate Risk',
        'color': 'orange',
        'details': 'Contrast dye used in imaging scans combined with Metformin can increase risks of lactic acidosis. Monitor kidney function.'
      };
    } else if ((da.contains('paracetamol') && db.contains('alcohol')) || (da.contains('alcohol') && db.contains('paracetamol'))) {
      return {
        'status': 'Moderate Risk',
        'color': 'orange',
        'details': 'Taking Paracetamol with regular alcohol use increases the risk of severe liver toxicity and acute hepatic injury.'
      };
    } else if ((da.contains('lisinopril') && db.contains('potassium')) || (da.contains('potassium') && db.contains('lisinopril'))) {
      return {
        'status': 'Moderate Risk',
        'color': 'orange',
        'details': 'Lisinopril impairs potassium excretion. Taking high-dose potassium supplements concurrent with ACE inhibitors may cause severe hyperkalemia.'
      };
    } else if ((da.contains('cetirizine') && db.contains('alcohol')) || (da.contains('alcohol') && db.contains('cetirizine'))) {
      return {
        'status': 'Moderate Risk',
        'color': 'orange',
        'details': 'Combining Cetirizine antihistamine with alcohol can compound central nervous system depression, leading to severe drowsiness.'
      };
    } else if (da.isNotEmpty && db.isNotEmpty) {
      return {
        'status': 'No Known Interaction',
        'color': 'green',
        'details': 'No severe interactions found between $drugA and $drugB. However, always consult with a doctor for personalized medical advice.'
      };
    }
    return {
      'status': 'Select Drugs',
      'color': 'blue',
      'details': 'Enter or select two drugs to check for potential clinical interactions.'
    };
  }

  // OCR Prescription Scanner Mock
  bool _isOcrScanning = false;
  bool get isOcrScanning => _isOcrScanning;

  Future<void> runOcrPrescriptionScan(String filename) async {
    _isOcrScanning = true;
    notifyListeners();

    await Future.delayed(Duration(seconds: 2));

    final random = Random();
    final medList = ['Amoxicillin 250mg', 'Montelukast 10mg', 'Amlodipine 5mg', 'Atorvastatin 10mg'];
    final selectedMed = medList[random.nextInt(medList.length)];
    final selectedTime = random.nextBool() ? '08:00 AM' : '09:00 PM';
    
    await addMedicineReminder(selectedMed, '1 tablet daily', selectedTime);
    await addNotification("SUCCESS: OCR Scanner extracted '$selectedMed' prescription and created a reminder.");
    
    _isOcrScanning = false;
    notifyListeners();
  }

  // Databases (Simulating Firebase Storage)
  final List<UserAccount> _users = [
    UserAccount(
      id: '1', 
      name: 'Manisha E.', 
      email: 'patient@medicate.com', 
      password: 'password123', 
      role: UserRole.patient,
      phone: '+91 98765 43210',
      bio: 'Regular patient since 2024. Hypertension management.',
    ),
    UserAccount(
      id: '2', 
      name: 'Dr. Sarah Connor', 
      email: 'doctor@medicate.com', 
      password: 'password123', 
      role: UserRole.doctor,
      phone: '+1 (555) 123-9876',
      bio: 'Senior Cardiologist with 15+ years of diagnostic experience. Specializes in heart valve repairs and coronary artery diseases.',
      licenseNumber: 'MD-998877',
      specialty: 'Cardiology',
      rating: 4.9,
      consultFee: 500.0,
      hospitalId: 'h2',
      hospitalName: 'St. Jude Cardiac Institute',
      patientsThisWeek: [8, 12, 10, 14, 9, 4, 1],
    ),
    UserAccount(
      id: '3', 
      name: 'Elena Admin', 
      email: 'admin@medicate.com', 
      password: 'password123', 
      role: UserRole.admin,
      phone: '+1 (555) 555-1234',
      bio: 'Lead Operations Director for Central Medicate Hub.',
      licenseNumber: 'LIC-ADMIN-01',
    ),
    UserAccount(
      id: '4', 
      name: 'Dr. Reed Richards', 
      email: 'reed@medicate.com', 
      password: 'password123', 
      role: UserRole.doctor,
      phone: '+1 (555) 234-5678',
      bio: 'Director of Advanced Medical Diagnostics. Developer of holographic biometrics trackers and telemetry networks.',
      licenseNumber: 'MD-112233',
      specialty: 'General Diagnostics',
      rating: 4.8,
      consultFee: 400.0,
      hospitalId: 'h1',
      hospitalName: 'City Central General Hospital',
      patientsThisWeek: [6, 8, 7, 9, 8, 3, 0],
    ),
    UserAccount(
      id: '5', 
      name: 'Dr. Stephen Strange', 
      email: 'strange@medicate.com', 
      password: 'password123', 
      role: UserRole.doctor,
      phone: '+1 (555) 876-5432',
      bio: 'Acclaimed neurosurgeon with expertise in cognitive mapping, nerve recovery, and complex brain surgeries.',
      licenseNumber: 'MD-445566',
      specialty: 'Neurology & Neuro-surgery',
      rating: 4.9,
      consultFee: 600.0,
      hospitalId: 'h3',
      hospitalName: 'Apex Multi-Specialty Care',
      patientsThisWeek: [4, 5, 5, 6, 4, 2, 0],
    ),
    UserAccount(
      id: '6', 
      name: 'Dr. Bruce Banner', 
      email: 'bruce@medicate.com', 
      password: 'password123', 
      role: UserRole.doctor,
      phone: '+1 (555) 345-6789',
      bio: 'Expert pediatrician and cellular biophysicist. Specializes in child genetics, growth telemetry, and hormone treatments.',
      licenseNumber: 'MD-778899',
      specialty: 'Pediatrics & Biochemistry',
      rating: 4.7,
      consultFee: 350.0,
      hospitalId: 'h4',
      hospitalName: 'Metro Children Clinic',
      patientsThisWeek: [5, 6, 4, 5, 5, 1, 0],
    ),
  ];

  final List<Hospital> _hospitals = [
    Hospital(id: 'h1', name: 'City Central General Hospital', lat: 12.9716, lng: 77.5946, contact: '+1 (555) 123-4567', vacancy: 12, totalBeds: 50),
    Hospital(id: 'h2', name: 'St. Jude Cardiac Institute', lat: 12.9800, lng: 77.6000, contact: '+1 (555) 987-6543', vacancy: 4, totalBeds: 30),
    Hospital(id: 'h3', name: 'Apex Multi-Specialty Care', lat: 12.9600, lng: 77.5800, contact: '+1 (555) 456-7890', vacancy: 0, totalBeds: 25),
    Hospital(id: 'h4', name: 'Metro Children Clinic', lat: 12.9900, lng: 77.6200, contact: '+1 (555) 321-7654', vacancy: 28, totalBeds: 60),
    Hospital(id: 'h5', name: 'Green Valley Trauma Center', lat: 12.9500, lng: 77.6100, contact: '+1 (555) 654-0987', vacancy: 15, totalBeds: 40),
  ];

  final List<Medicine> _medicines = [
    // Analgesics
    Medicine(id: 'm1', name: 'Paracetamol 500mg (Crocin)', category: 'Analgesics', price: 18.00, description: 'Quick relief for mild pain, headache, fever, and common cold symptoms.', stock: 120),
    Medicine(id: 'm2', name: 'Ibuprofen 400mg (Combiflam)', category: 'Analgesics', price: 25.00, description: 'Targets source-level inflammatory triggers to mitigate muscular aches and joint pains.', stock: 80),
    Medicine(id: 'm3', name: 'Aspirin 75mg (Loprin)', category: 'Analgesics', price: 15.00, description: 'Low-dose aspirin used as a blood thinner to prevent cardiovascular episodes.', stock: 150),
    
    // Antibiotics
    Medicine(id: 'm4', name: 'Amoxicillin 250mg (Novamox)', category: 'Antibiotics', price: 65.00, description: 'Broad-spectrum penicillin antibiotic used to treat bacterial infections.', stock: 45),
    Medicine(id: 'm5', name: 'Azithromycin 500mg (Azithral)', category: 'Antibiotics', price: 120.00, description: 'Macrolide antibiotic used for respiratory tract, throat, and skin infections.', stock: 60),
    
    // Antihistamines
    Medicine(id: 'm6', name: 'Cetirizine 10mg (Okacet)', category: 'Antihistamines', price: 35.00, description: 'Non-drowsy 24-hour allergy defense against dust, running nose, and sneezing.', stock: 95),
    Medicine(id: 'm7', name: 'Montelukast 10mg (Montair)', category: 'Antihistamines', price: 98.00, description: 'Used to prevent asthma attacks and relieve seasonal allergic rhinitis.', stock: 70),
    
    // Gastrointestinal
    Medicine(id: 'm8', name: 'Loperamide 2mg (Lopamide)', category: 'Antidiarrheals', price: 22.00, description: 'Assists in restoring physiological balance and slowing intestinal motility.', stock: 65),
    Medicine(id: 'm9', name: 'Pantoprazole 40mg (Pan-40)', category: 'Antacids', price: 115.00, description: 'Proton pump inhibitor that reduces excess stomach acid, treating GERD and acidity.', stock: 110),
    Medicine(id: 'm10', name: 'Digene Gel Tablets', category: 'Antacids', price: 30.00, description: 'Chewable antacid tablets for fast relief from gas, bloating, and heartburn.', stock: 200),
    
    // Antidiabetics
    Medicine(id: 'm11', name: 'Metformin 500mg (Glycomet)', category: 'Antidiabetics', price: 42.00, description: 'Improves insulin sensitivity and glycemic controls for Type-2 Diabetes management.', stock: 110),
    
    // Cardiovascular
    Medicine(id: 'm12', name: 'Amlodipine 5mg (Amlokind)', category: 'Cardiovascular', price: 28.00, description: 'Calcium channel blocker used to treat high blood pressure (hypertension).', stock: 90),
    Medicine(id: 'm13', name: 'Atorvastatin 10mg (Lipvas)', category: 'Cardiovascular', price: 75.00, description: 'Statins used to lower cholesterol and prevent risk of heart attacks.', stock: 85),
    
    // Vitamins & Supplements
    Medicine(id: 'm14', name: 'Vitamin C 500mg (Limcee)', category: 'Vitamins', price: 25.00, description: 'Chewable orange-flavored tablets containing Ascorbic Acid for immunity.', stock: 300),
    Medicine(id: 'm15', name: 'Calcium + Vit D3 (Shelcal)', category: 'Vitamins', price: 95.00, description: 'Supports bone health, joint density, and manages calcium deficiencies.', stock: 130),
    Medicine(id: 'm16', name: 'Salbutamol Inhaler (Asthalin)', category: 'Respiratory', price: 145.00, description: 'Bronchodilator inhaler providing fast relief from asthma spasms and coughing.', stock: 50),
  ];

  final List<Appointment> _appointments = [];
  final List<MedicineReminder> _reminders = [
    MedicineReminder(id: 'r1', medicineName: 'Paracetamol 500mg', dosage: '1 tablet', time: '08:00 AM'),
    MedicineReminder(id: 'r2', medicineName: 'Cetirizine 10mg', dosage: '1 tablet', time: '09:00 PM'),
  ];
  final List<SymptomLog> _symptoms = [
    SymptomLog(id: 's1', symptom: 'Headache', severity: 4.0, timestamp: DateTime.now().subtract(Duration(days: 2))),
    SymptomLog(id: 's2', symptom: 'Fatigue', severity: 6.0, timestamp: DateTime.now().subtract(Duration(days: 1))),
  ];

  final List<ChatMessage> _chatMessages = [
    ChatMessage(id: 'c1', text: 'Hello! I am Medicate AI. How can I help you track your symptoms or health today?', isUser: false, timestamp: DateTime.now()),
  ];

  final List<CartItem> _cart = [];
  final List<Prescription> _prescriptions = [
    Prescription(id: 'pr1', patientId: '1', doctorName: 'Dr. Sarah Connor', medicineName: 'Paracetamol 500mg', dosage: '1 tablet twice daily', date: DateTime.now().subtract(Duration(days: 1))),
  ];

  final List<AppNotification> _notifications = [
    AppNotification(id: 'n1', text: 'Dr. Sarah Connor approved your Cardiology Consultation.', timestamp: DateTime.now().subtract(Duration(hours: 2))),
    AppNotification(id: 'n2', text: 'Simulated Drone Delivery: Your Paracetamol has been dispatched!', timestamp: DateTime.now().subtract(Duration(hours: 5))),
    AppNotification(id: 'n3', text: 'Urgent: Keep tracking your ECG vitals regularly today.', timestamp: DateTime.now().subtract(Duration(days: 1))),
  ];

  final List<VaccineRecord> _vaccines = [
    VaccineRecord(id: 'v1', name: 'COVID-19 mRNA Vaccine (Pfizer)', status: 'Taken', date: DateTime.now().subtract(Duration(days: 180))),
    VaccineRecord(id: 'v2', name: 'Influenza Annual Shot', status: 'Taken', date: DateTime.now().subtract(Duration(days: 45))),
    VaccineRecord(id: 'v3', name: 'Hepatitis B Recombinant', status: 'Available'),
    VaccineRecord(id: 'v4', name: 'Tetanus-Diphtheria Booster', status: 'Available'),
  ];

  final List<InventoryItem> _inventory = [
    InventoryItem(id: 'inv1', name: 'Paracetamol 500mg', category: 'Analgesics', stock: 45, threshold: 20, expiryDate: DateTime.now().add(const Duration(days: 180)), unit: 'tablets'),
    InventoryItem(id: 'inv2', name: 'Amoxicillin 250mg', category: 'Antibiotics', stock: 8, threshold: 15, expiryDate: DateTime.now().add(const Duration(days: 25)), unit: 'capsules'),
    InventoryItem(id: 'inv3', name: 'Cetirizine 10mg', category: 'Antihistamines', stock: 60, threshold: 20, expiryDate: DateTime.now().add(const Duration(days: 365)), unit: 'tablets'),
    InventoryItem(id: 'inv4', name: 'Amlodipine 5mg', category: 'Cardiovascular', stock: 5, threshold: 10, expiryDate: DateTime.now().add(const Duration(days: 90)), unit: 'tablets'),
    InventoryItem(id: 'inv5', name: 'Metformin 500mg', category: 'Antidiabetics', stock: 30, threshold: 15, expiryDate: DateTime.now().subtract(const Duration(days: 5)), unit: 'tablets'),
    InventoryItem(id: 'inv6', name: 'Vitamin C 500mg', category: 'Vitamins', stock: 120, threshold: 30, expiryDate: DateTime.now().add(const Duration(days: 730)), unit: 'tablets'),
  ];

  // Active Sessions
  UserAccount? _currentUser;
  String? _otpVerificationEmail;
  String? _generatedOtp;
  bool _isVerifyingOtp = false;

  // Active Call Status
  bool _isCallActive = false;
  String? _activeCallDoctor;
  String? _activeCallChannel;

  // E-Commerce Delivery Tracking Simulation
  double _deliveryProgress = 0.0;
  String _deliveryStatus = 'Idle';
  Timer? _deliveryTimer;

  // Live Vehicle Telemetry Simulation
  final List<LiveVehicle> _liveVehicles = [
    LiveVehicle(id: 'v1', type: 'Ambulance', status: 'Responding', lat: 12.9750, lng: 77.5900, targetHospital: 'City Central General Hospital'),
    LiveVehicle(id: 'v2', type: 'Med-Drone', status: 'Dispatched', lat: 12.9650, lng: 77.6050, targetHospital: 'St. Jude Cardiac Institute'),
    LiveVehicle(id: 'v3', type: 'Ambulance', status: 'Returning', lat: 12.9850, lng: 77.5850, targetHospital: 'Apex Multi-Specialty Care'),
  ];
  Timer? _realTimeSimulationTimer;

  // Bluetooth Sensor State
  BluetoothConnectionStatus _btStatus = BluetoothConnectionStatus.disconnected;
  BluetoothSensorDevice? _connectedDevice;
  List<BluetoothSensorDevice> _discoveredDevices = [];
  double _glucoseValue = 98.0; // mg/dL
  final List<double> _glucoseHistory = [95.0, 97.0, 96.0, 98.0, 100.0, 98.0, 97.0, 99.0, 98.0, 101.0, 99.0, 98.0];
  int _bpmValue = 76;
  Timer? _vitalsSimulationTimer;

  // Getters
  UserAccount? get currentUser => _currentUser;
  List<Hospital> get hospitals => _hospitals;
  List<UserAccount> get doctors => _users.where((u) => u.role == UserRole.doctor).toList();
  List<LiveVehicle> get liveVehicles => _liveVehicles;
  List<Medicine> get medicines => _medicines;
  List<Appointment> get appointments => _appointments;
  List<MedicineReminder> get reminders => _reminders;
  List<SymptomLog> get symptoms => _symptoms;
  List<ChatMessage> get chatMessages => _chatMessages;
  List<CartItem> get cart => _cart;
  List<Prescription> get prescriptions => _prescriptions;
  List<AppNotification> get notifications => _notifications;
  List<VaccineRecord> get vaccines => _vaccines;
  List<InventoryItem> get inventory => _inventory;
  List<InventoryItem> get lowStockItems => _inventory.where((i) => i.isLowStock).toList();
  List<InventoryItem> get expiredItems => _inventory.where((i) => i.isExpired).toList();
  List<InventoryItem> get expiringSoonItems => _inventory.where((i) => i.isExpiringSoon && !i.isExpired).toList();
  bool get isCallActive => _isCallActive;
  String? get activeCallDoctor => _activeCallDoctor;
  String? get activeCallChannel => _activeCallChannel;
  bool get isVerifyingOtp => _isVerifyingOtp;
  String? get generatedOtp => _generatedOtp;
  double get deliveryProgress => _deliveryProgress;
  String get deliveryStatus => _deliveryStatus;

  List<UserAccount> getDoctorsForHospital(String hospitalId, String hospitalName) {
    final localDocs = _users.where((u) => u.role == UserRole.doctor && u.hospitalId == hospitalId).toList();
    if (localDocs.isNotEmpty) {
      return localDocs;
    }
    
    final allDoctors = _users.where((u) => u.role == UserRole.doctor).toList();
    if (allDoctors.isEmpty) return [];
    
    final int hash = hospitalName.hashCode.abs();
    final int count = (hash % 2) + 1; // 1 or 2 doctors
    final List<UserAccount> assigned = [];
    for (int i = 0; i < count; i++) {
      assigned.add(allDoctors[(hash + i) % allDoctors.length]);
    }
    return assigned;
  }

  // Bluetooth Getters
  BluetoothConnectionStatus get btStatus => _btStatus;
  BluetoothSensorDevice? get connectedDevice => _connectedDevice;
  List<BluetoothSensorDevice> get discoveredDevices => _discoveredDevices;
  double get glucoseValue => _glucoseValue;
  List<double> get glucoseHistory => _glucoseHistory;
  int get bpmValue => _bpmValue;

  // Calculated Getters
  double get cartTotal => _cart.fold(0.0, (total, item) => total + (item.medicine.price * item.quantity));

  // ==========================================
  // AUTHENTICATION LOGIC (with OTP and Checks)
  // ==========================================

  // Check if duplicate email exists
  bool checkEmailExists(String email) {
    return _users.any((u) => u.email.toLowerCase() == email.trim().toLowerCase());
  }

  // Request Registration OTP
  Future<void> requestSignUpOtp(String email, String phone, bool isEmailOtp) async {
    if (checkEmailExists(email)) {
      throw Exception('Already have an account with this email.');
    }
    _otpVerificationEmail = email.trim();
    final random = Random();
    _generatedOtp = (100000 + random.nextInt(900000)).toString();
    _isVerifyingOtp = true;
    notifyListeners();

    print("\n------------------------------------------------");
    print(" [OTP GENERATOR] ");
    print(" Destination: ${isEmailOtp ? email : phone} (${isEmailOtp ? 'Email' : 'Phone'})");
    print(" Code: $_generatedOtp");
    print("------------------------------------------------\n");

    await sendOtpEmailOrSms(isEmailOtp ? email : phone, _generatedOtp!, isEmailOtp);
  }

  Future<void> sendOtpEmailOrSms(String recipient, String code, bool isEmail) async {
    try {
      if (FirebaseService.isInitialized) {
        await FirebaseFirestore.instance.collection('otps').doc(recipient).set({
          'code': code,
          'timestamp': FieldValue.serverTimestamp(),
          'recipient': recipient,
          'type': isEmail ? 'email' : 'phone',
        });
        
        if (isEmail) {
          await FirebaseFirestore.instance.collection('mail').add({
            'to': recipient,
            'message': {
              'subject': 'Medicate Verification OTP',
              'text': 'Your Medicate signup verification OTP code is: $code. Valid for 10 minutes.',
            }
          });
        } else {
          await FirebaseFirestore.instance.collection('sms').add({
            'to': recipient,
            'body': 'Your Medicate signup verification OTP code is: $code',
          });
        }
      }
    } catch (e) {
      print("Firestore OTP register error: $e");
    }

    if (isEmail) {
      try {
        final res = await http.post(
          Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'service_id': 'default_service',
            'template_id': 'medicate_otp_template',
            'user_id': 'user_dummy',
            'template_params': {
              'to_email': recipient,
              'otp_code': code,
            }
          }),
        ).timeout(const Duration(seconds: 3));
        print("API Email send status: ${res.statusCode}");
      } catch (e) {
        print("Direct API email send error: $e");
      }
    } else {
      print("SMS verification code $code sent to phone number: $recipient");
    }
  }

  // Verify OTP & Register Account
  Future<bool> verifyOtpAndRegister(String name, String email, String password, UserRole role, String phone, String enteredOtp) async {
    if (enteredOtp == _generatedOtp) {
      if (FirebaseService.isInitialized) {
        try {
          fb.UserCredential creds = await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email.trim().toLowerCase(),
            password: password,
          );
          await creds.user!.updateDisplayName(name);

          final newAcc = UserAccount(
            id: creds.user!.uid,
            name: name,
            email: email.trim().toLowerCase(),
            password: password,
            role: role,
            phone: phone,
          );
          await FirebaseFirestore.instance.collection('users').doc(creds.user!.uid).set(newAcc.toMap());
          _currentUser = newAcc;
        } catch (e) {
          print("Firebase signup error: $e");
          rethrow;
        }
      } else {
        final newAcc = UserAccount(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          email: email.trim().toLowerCase(),
          password: password,
          role: role,
          phone: phone,
        );
        _users.add(newAcc);
        _currentUser = newAcc;
        await _saveLocalData('users', _users);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user_id', newAcc.id);
      }

      _isVerifyingOtp = false;
      _generatedOtp = null;
      _otpVerificationEmail = null;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Password Reset
  Future<bool> sendPasswordReset(String email) async {
    if (FirebaseService.isInitialized) {
      try {
        await fb.FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim().toLowerCase());
        return true;
      } catch (e) {
        print("Firebase password reset error: $e");
        return false;
      }
    } else {
      final exists = _users.any((u) => u.email.toLowerCase() == email.trim().toLowerCase());
      return exists;
    }
  }

  // Login
  Future<bool> login(String email, String password, UserRole role) async {
    if (FirebaseService.isInitialized) {
      try {
        fb.UserCredential creds = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim().toLowerCase(),
          password: password,
        );
        
        final doc = await FirebaseFirestore.instance.collection('users').doc(creds.user!.uid).get();
        if (doc.exists) {
          final user = UserAccount.fromMap(doc.data()!);
          if (user.role == role) {
            _currentUser = user;
            notifyListeners();
            return true;
          } else {
            await fb.FirebaseAuth.instance.signOut();
            return false;
          }
        }
        return false;
      } catch (_) {
        return false;
      }
    } else {
      try {
        final user = _users.firstWhere(
          (u) => u.email.toLowerCase() == email.trim().toLowerCase() && 
                 u.password == password && 
                 u.role == role
        );
        _currentUser = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user_id', user.id);
        notifyListeners();
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  // Logout
  Future<void> logout() async {
    if (FirebaseService.isInitialized) {
      await fb.FirebaseAuth.instance.signOut();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_id');
    }
    _currentUser = null;
    _cart.clear();
    _isCallActive = false;
    notifyListeners();
  }

  // ==========================================
  // HOSPITAL ADMIN EDITS
  // ==========================================

  Future<void> updateHospitalVacancy(String id, int newVacancy) async {
    final idx = _hospitals.indexWhere((h) => h.id == id);
    if (idx != -1) {
      final updated = _hospitals[idx].copyWith(vacancy: newVacancy.clamp(0, _hospitals[idx].totalBeds));
      if (FirebaseService.isInitialized) {
        await FirebaseFirestore.instance.collection('hospitals').doc(id).set(updated.toMap());
      } else {
        _hospitals[idx] = updated;
        await _saveLocalData('hospitals', _hospitals);
        notifyListeners();
      }
    }
  }

  // ==========================================
  // MEDICAL SHOP OPERATIONS
  // ==========================================

  void addToCart(Medicine med) {
    final idx = _cart.indexWhere((item) => item.medicine.id == med.id);
    if (idx != -1) {
      if (_cart[idx].quantity < med.stock) {
        _cart[idx].quantity++;
      }
    } else {
      _cart.add(CartItem(medicine: med));
    }
    notifyListeners();
  }

  void removeFromCart(String medId) {
    _cart.removeWhere((item) => item.medicine.id == medId);
    notifyListeners();
  }

  void adjustCartQuantity(String medId, int change) {
    final idx = _cart.indexWhere((item) => item.medicine.id == medId);
    if (idx != -1) {
      final newQty = _cart[idx].quantity + change;
      if (newQty <= 0) {
        _cart.removeAt(idx);
      } else if (newQty <= _cart[idx].medicine.stock) {
        _cart[idx].quantity = newQty;
      }
    }
    notifyListeners();
  }

  Future<void> checkoutCart() async {
    for (var item in _cart) {
      final medIdx = _medicines.indexWhere((m) => m.id == item.medicine.id);
      if (medIdx != -1) {
        final newStock = max(0, _medicines[medIdx].stock - item.quantity);
        final updated = _medicines[medIdx].copyWith(stock: newStock);
        if (FirebaseService.isInitialized) {
          await FirebaseFirestore.instance.collection('medicines').doc(item.medicine.id).set(updated.toMap());
        } else {
          _medicines[medIdx] = updated;
        }
      }
    }
    _cart.clear();
    if (!FirebaseService.isInitialized) {
      await _saveLocalData('medicines', _medicines);
    }
    notifyListeners();
  }

  Future<void> restockMedicine(String medId, int amount) async {
    final idx = _medicines.indexWhere((m) => m.id == medId);
    if (idx != -1) {
      final newStock = _medicines[idx].stock + amount;
      final updated = _medicines[idx].copyWith(stock: newStock);
      if (FirebaseService.isInitialized) {
        await FirebaseFirestore.instance.collection('medicines').doc(medId).set(updated.toMap());
      } else {
        _medicines[idx] = updated;
        await _saveLocalData('medicines', _medicines);
        notifyListeners();
      }
    }
  }

  // ==========================================
  // APPOINTMENT CALENDAR
  // ==========================================

  Future<void> bookAppointment(String doctor, String department, DateTime dateTime) async {
    if (_currentUser == null) return;
    final appt = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: _currentUser!.id,
      patientName: _currentUser!.name,
      doctorName: doctor,
      department: department,
      dateTime: dateTime,
    );

    if (FirebaseService.isInitialized) {
      await FirebaseFirestore.instance.collection('appointments').doc(appt.id).set(appt.toMap());
    } else {
      _appointments.add(appt);
      await _saveLocalData('appointments', _appointments);
      notifyListeners();
    }
  }

  Future<void> updateAppointmentStatus(String id, String status) async {
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final appt = _appointments[idx];
      appt.status = status;
      if (FirebaseService.isInitialized) {
        await FirebaseFirestore.instance.collection('appointments').doc(id).set(appt.toMap());
      } else {
        _appointments[idx] = appt;
        await _saveLocalData('appointments', _appointments);
        notifyListeners();
      }
    }
  }

  Future<void> scheduleAppointment(String patientName, String doctorName, String department, DateTime dateTime, String status) async {
    final appt = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: 'PID' + DateTime.now().millisecondsSinceEpoch.toString().substring(8),
      patientName: patientName,
      doctorName: doctorName,
      department: department,
      dateTime: dateTime,
      status: status,
    );

    if (FirebaseService.isInitialized) {
      await FirebaseFirestore.instance.collection('appointments').doc(appt.id).set(appt.toMap());
    } else {
      _appointments.add(appt);
      await _saveLocalData('appointments', _appointments);
      notifyListeners();
    }
  }

  // ==========================================
  // TRACKERS (MEDICINE & PATIENT)
  // ==========================================

  Future<void> addSymptom(String symptom, double severity) async {
    final log = SymptomLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      symptom: symptom,
      severity: severity,
      timestamp: DateTime.now(),
    );

    if (FirebaseService.isInitialized) {
      await FirebaseFirestore.instance.collection('symptoms').doc(log.id).set(log.toMap());
    } else {
      _symptoms.add(log);
      await _saveLocalData('symptoms', _symptoms);
      notifyListeners();
    }
  }

  Future<void> addMedicineReminder(String name, String dosage, String time) async {
    final rem = MedicineReminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicineName: name,
      dosage: dosage,
      time: time,
    );

    _reminders.insert(0, rem);
    await _saveLocalData('reminders', _reminders);
    notifyListeners();

    if (FirebaseService.isInitialized) {
      try {
        await FirebaseFirestore.instance.collection('reminders').doc(rem.id).set(rem.toMap());
      } catch (e) {
        print("Firestore error adding reminder: $e");
      }
    }
  }

  Future<void> toggleReminderTaken(String id) async {
    final idx = _reminders.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final rem = _reminders[idx];
      rem.isTaken = !rem.isTaken;
      _reminders[idx] = rem;
      await _saveLocalData('reminders', _reminders);
      notifyListeners();

      if (FirebaseService.isInitialized) {
        try {
          await FirebaseFirestore.instance.collection('reminders').doc(id).set(rem.toMap());
        } catch (e) {
          print("Firestore error toggling reminder: $e");
        }
      }
    }
  }

  Future<void> removeReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    await _saveLocalData('reminders', _reminders);
    notifyListeners();

    if (FirebaseService.isInitialized) {
      try {
        await FirebaseFirestore.instance.collection('reminders').doc(id).delete();
      } catch (e) {
        print("Firestore error removing reminder: $e");
      }
    }
  }

  // ==========================================
  // BLUETOOTH VITALS CONTROLLER & SIMULATOR
  // ==========================================

  void startScanning() {
    _btStatus = BluetoothConnectionStatus.scanning;
    _discoveredDevices.clear();
    notifyListeners();

    Timer(Duration(seconds: 2), () {
      if (_btStatus == BluetoothConnectionStatus.scanning) {
        _discoveredDevices = [
          BluetoothSensorDevice(id: 'd1', name: 'MediWatch Active 4', type: BluetoothDeviceType.watch, batteryLevel: 92, signalStrength: -58),
          BluetoothSensorDevice(id: 'd2', name: 'Aura Smart Ring Gen 4', type: BluetoothDeviceType.ring, batteryLevel: 87, signalStrength: -65),
          BluetoothSensorDevice(id: 'd3', name: 'VitalsBand S5', type: BluetoothDeviceType.watch, batteryLevel: 76, signalStrength: -72),
          BluetoothSensorDevice(id: 'd4', name: 'Circular Ring Slim', type: BluetoothDeviceType.ring, batteryLevel: 94, signalStrength: -60),
        ];
        _btStatus = BluetoothConnectionStatus.disconnected;
        notifyListeners();
      }
    });
  }

  void connectDevice(BluetoothSensorDevice device) {
    _btStatus = BluetoothConnectionStatus.connecting;
    notifyListeners();

    Timer(Duration(milliseconds: 1500), () {
      _btStatus = BluetoothConnectionStatus.connected;
      _connectedDevice = device;
      addNotification("SUCCESS: Connected to ${device.name} via Bluetooth.");
      
      _startVitalsSimulation();
      notifyListeners();
    });
  }

  void disconnectDevice() {
    if (_connectedDevice != null) {
      addNotification("INFO: Disconnected from ${_connectedDevice!.name}.");
    }
    _btStatus = BluetoothConnectionStatus.disconnected;
    _connectedDevice = null;
    _discoveredDevices.clear();
    _stopVitalsSimulation();
    notifyListeners();
  }

  void _startVitalsSimulation() {
    _vitalsSimulationTimer?.cancel();
    final random = Random();
    _vitalsSimulationTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_btStatus == BluetoothConnectionStatus.connected) {
        final double glucoseChange = (random.nextDouble() * 3.0) - 1.5;
        _glucoseValue = (_glucoseValue + glucoseChange).clamp(75.0, 145.0);
        
        _glucoseHistory.add(_glucoseValue);
        if (_glucoseHistory.length > 15) {
          _glucoseHistory.removeAt(0);
        }

        final int bpmChange = random.nextInt(7) - 3;
        _bpmValue = (_bpmValue + bpmChange).clamp(60, 110);

        notifyListeners();
      }
    });
  }

  void _stopVitalsSimulation() {
    _vitalsSimulationTimer?.cancel();
    _vitalsSimulationTimer = null;
  }

  // ==========================================
  // AI MEDICAL CHATBOT
  // ==========================================

  Future<void> sendPatientMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    if (FirebaseService.isInitialized) {
      await FirebaseFirestore.instance.collection('chat_messages').doc(userMsg.id).set(userMsg.toMap());
    } else {
      _chatMessages.add(userMsg);
      await _saveLocalData('chat_messages', _chatMessages);
      notifyListeners();
    }

    Timer(Duration(milliseconds: 1500), () async {
      final aiText = _generateAIResponse(text);
      final aiMsg = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: aiText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      if (FirebaseService.isInitialized) {
        await FirebaseFirestore.instance.collection('chat_messages').doc(aiMsg.id).set(aiMsg.toMap());
      } else {
        _chatMessages.add(aiMsg);
        await _saveLocalData('chat_messages', _chatMessages);
        notifyListeners();
      }
    });
  }

  String _generateAIResponse(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains('hello') || lower.contains('hi')) {
      return "Hello! I am your Medicate AI medical assistant. How can I help you with your symptoms, medication reminders, or search for clinics today?";
    } else if (lower.contains('headache') || lower.contains('migraine')) {
      return "Headaches can stem from stress, dehydration, lack of sleep, or eye strain. I recommend resting in a dark room and drinking plenty of water. If you log this in your Symptom Tracker, you can monitor its frequency. If it is severe, consider booking an appointment with a General Physician.";
    } else if (lower.contains('fever') || lower.contains('temperature')) {
      return "A fever is typically a sign that your body is fighting an infection. Rest, stay hydrated, and you may take Paracetamol if appropriate. Please monitor your temperature. If it exceeds 103°F (39.4°C) or lasts more than 3 days, you should consult a doctor.";
    } else if (lower.contains('appointment') || lower.contains('doctor')) {
      return "To book an appointment, please head to the 'Calendar' tab. There, you can filter by department, select your preferred doctor, and pick an available date and time.";
    } else if (lower.contains('hospital') || lower.contains('map') || lower.contains('beds')) {
      return "To find nearby medical facilities, navigate to our 'Hospitals' screen. It displays a real-time locator map along with emergency contacts and bed vacancy numbers.";
    } else if (lower.contains('shop') || lower.contains('medicine') || lower.contains('buy')) {
      return "You can buy over-the-counter medicines in our 'Medical Shop' tab. Add items to your cart and proceed to checkout, and the system will update the stock inventory automatically.";
    } else if (lower.contains('cough') || lower.contains('cold') || lower.contains('sore throat')) {
      return "Colds and sore throats are usually viral. Warm fluids, honey, and salt-water gargles can soothe irritation. If you experience shortness of breath, please consult a doctor immediately.";
    } else {
      return "I have noted that. To ensure your safety, please log any symptoms in the Symptom Tracker and consult with our registered doctors via the Video Consultation option for a proper diagnosis.";
    }
  }

  // ==========================================
  // VIDEO CONSULTATION CONTROLLER
  // ==========================================

  void startCall(String doctorName, String department) {
    _isCallActive = true;
    _activeCallDoctor = doctorName;
    _activeCallChannel = department;
    notifyListeners();
  }

  void endCall() {
    _isCallActive = false;
    _activeCallDoctor = null;
    _activeCallChannel = null;
    notifyListeners();
  }

  // ==========================================
  // PRESCRIPTION LINKING & DELIVERY SYSTEM
  // ==========================================

  Future<void> addPrescription(String patientId, String docName, String medicineName, String dosage) async {
    final pres = Prescription(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      doctorName: docName,
      medicineName: medicineName,
      dosage: dosage,
      date: DateTime.now(),
    );

    if (FirebaseService.isInitialized) {
      await FirebaseFirestore.instance.collection('prescriptions').doc(pres.id).set(pres.toMap());
    } else {
      _prescriptions.add(pres);
      await _saveLocalData('prescriptions', _prescriptions);
      notifyListeners();
    }
  }

  void startDeliverySimulation() {
    _deliveryTimer?.cancel();
    _deliveryProgress = 0.0;
    _deliveryStatus = 'Packaging';
    notifyListeners();

    _deliveryTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _deliveryProgress += 0.05;
      if (_deliveryProgress >= 1.0) {
        _deliveryProgress = 1.0;
        _deliveryStatus = 'Delivered';
        timer.cancel();
      } else if (_deliveryProgress >= 0.8) {
        _deliveryStatus = 'Arriving';
      } else if (_deliveryProgress >= 0.4) {
        _deliveryStatus = 'Out for Delivery';
      } else if (_deliveryProgress >= 0.15) {
        _deliveryStatus = 'Dispatched';
      }
      notifyListeners();
    });
  }

  // ==========================================
  // NOTIFICATIONS, VACCINATION & PROFILE SETTINGS
  // ==========================================

  Future<void> addNotification(String text) async {
    final notif = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      timestamp: DateTime.now(),
    );

    if (FirebaseService.isInitialized) {
      await FirebaseFirestore.instance.collection('notifications').doc(notif.id).set(notif.toMap());
    } else {
      _notifications.insert(0, notif);
      await _saveLocalData('notifications', _notifications);
      notifyListeners();
    }
  }

  Future<void> dismissNotification(String id) async {
    if (FirebaseService.isInitialized) {
      await FirebaseFirestore.instance.collection('notifications').doc(id).delete();
    } else {
      _notifications.removeWhere((n) => n.id == id);
      await _saveLocalData('notifications', _notifications);
      notifyListeners();
    }
  }

  Future<void> clearAllNotifications() async {
    if (FirebaseService.isInitialized) {
      final snapshot = await FirebaseFirestore.instance.collection('notifications').get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } else {
      _notifications.clear();
      await _saveLocalData('notifications', _notifications);
      notifyListeners();
    }
  }

  Future<void> bookVaccine(String name, DateTime date) async {
    final idx = _vaccines.indexWhere((v) => v.name == name);
    VaccineRecord updated;
    if (idx != -1) {
      updated = VaccineRecord(
        id: _vaccines[idx].id,
        name: name,
        status: 'Scheduled',
        date: date,
      );
    } else {
      updated = VaccineRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        status: 'Scheduled',
        date: date,
      );
    }

    if (FirebaseService.isInitialized) {
      await FirebaseFirestore.instance.collection('vaccines').doc(updated.id).set(updated.toMap());
    } else {
      if (idx != -1) {
        _vaccines[idx] = updated;
      } else {
        _vaccines.add(updated);
      }
      await _saveLocalData('vaccines', _vaccines);
      notifyListeners();
    }
    await addNotification("Vaccination appointment for $name has been scheduled successfully.");
  }

  // ==========================================
  // INVENTORY MANAGEMENT
  // ==========================================

  Future<void> addInventoryItem(String name, String category, int stock, int threshold, DateTime expiry, String unit) async {
    final item = InventoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: category,
      stock: stock,
      threshold: threshold,
      expiryDate: expiry,
      unit: unit,
    );

    if (FirebaseService.isInitialized) {
      await FirebaseFirestore.instance.collection('inventory').doc(item.id).set(item.toMap());
    } else {
      _inventory.add(item);
      await _saveLocalData('inventory', _inventory);
      notifyListeners();
    }
    await addNotification('Inventory: $name added to stock.');
  }

  Future<void> updateInventoryStock(String id, int newStock) async {
    final idx = _inventory.indexWhere((i) => i.id == id);
    if (idx != -1) {
      if (FirebaseService.isInitialized) {
        final updated = InventoryItem(
          id: _inventory[idx].id,
          name: _inventory[idx].name,
          category: _inventory[idx].category,
          stock: newStock,
          threshold: _inventory[idx].threshold,
          expiryDate: _inventory[idx].expiryDate,
          unit: _inventory[idx].unit,
        );
        await FirebaseFirestore.instance.collection('inventory').doc(id).set(updated.toMap());
      } else {
        _inventory[idx].stock = newStock;
        await _saveLocalData('inventory', _inventory);
        notifyListeners();
      }
    }
  }

  Future<void> deleteInventoryItem(String id) async {
    if (FirebaseService.isInitialized) {
      await FirebaseFirestore.instance.collection('inventory').doc(id).delete();
    } else {
      _inventory.removeWhere((i) => i.id == id);
      await _saveLocalData('inventory', _inventory);
      notifyListeners();
    }
  }

  Future<void> updateUserProfile({required String name, required String email, required String phone, required String bio, String? password}) async {
    if (_currentUser == null) return;
    
    final updatedUser = UserAccount(
      id: _currentUser!.id,
      name: name,
      email: email,
      password: password != null && password.isNotEmpty ? password : _currentUser!.password,
      role: _currentUser!.role,
      phone: phone,
      bio: bio,
      licenseNumber: _currentUser!.licenseNumber,
      specialty: _currentUser!.specialty,
      rating: _currentUser!.rating,
      consultFee: _currentUser!.consultFee,
      patientsThisWeek: _currentUser!.patientsThisWeek,
    );

    if (FirebaseService.isInitialized) {
      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.id).set(updatedUser.toMap());
      try {
        final user = fb.FirebaseAuth.instance.currentUser;
        if (user != null) {
          if (email != user.email) await user.updateEmail(email);
          if (password != null && password.isNotEmpty) await user.updatePassword(password);
          await user.updateDisplayName(name);
        }
      } catch (authError) {
        print("Auth profile update warning: $authError");
      }
    } else {
      final idx = _users.indexWhere((u) => u.id == _currentUser!.id);
      if (idx != -1) {
        _users[idx] = updatedUser;
        _currentUser = updatedUser;
        await _saveLocalData('users', _users);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user_id', updatedUser.id);
        notifyListeners();
      }
    }
    await addNotification("Profile updated successfully.");
  }

  void startRealTimeSimulation() {
    _realTimeSimulationTimer?.cancel();
    final random = Random();
    _realTimeSimulationTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      for (var hospital in _hospitals) {
        final change = random.nextInt(3) - 1;
        if (change != 0) {
          final oldVacancy = hospital.vacancy;
          hospital.vacancy = (hospital.vacancy + change).clamp(0, hospital.totalBeds);
          if (oldVacancy != hospital.vacancy) {
            if (hospital.vacancy == 0) {
              addNotification("ALERT: ${hospital.name} is now at FULL bed capacity.");
            } else if (oldVacancy == 0 && hospital.vacancy > 0) {
              addNotification("UPDATE: Beds have freed up at ${hospital.name}.");
            }
          }
        }
      }

      for (var vehicle in _liveVehicles) {
        final targetHosp = _hospitals.firstWhere((h) => h.name == vehicle.targetHospital, orElse: () => _hospitals[0]);
        final double speedFactor = 0.0004;
        final double dLat = targetHosp.lat - vehicle.lat;
        final double dLng = targetHosp.lng - vehicle.lng;
        final double distance = sqrt(dLat * dLat + dLng * dLng);

        if (distance < 0.001) {
          vehicle.lat = 12.95 + random.nextDouble() * 0.04;
          vehicle.lng = 77.57 + random.nextDouble() * 0.05;
        } else {
          vehicle.lat += (dLat / distance) * speedFactor;
          vehicle.lng += (dLng / distance) * speedFactor;
        }
      }

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _realTimeSimulationTimer?.cancel();
    _deliveryTimer?.cancel();
    _vitalsSimulationTimer?.cancel();
    super.dispose();
  }
}
