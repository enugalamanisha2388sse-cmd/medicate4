import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/services/services.dart';

class MedicinesTab extends StatefulWidget {
  MedicinesTab({super.key});

  @override
  State<MedicinesTab> createState() => _MedicinesTabState();
}

class _MedicinesTabState extends State<MedicinesTab> with SingleTickerProviderStateMixin {
  late TabController _subTabController;
  
  // Drug Checker inputs
  String _selectedDrugA = 'Paracetamol 500mg (Crocin)';
  String _selectedDrugB = 'Ibuprofen 400mg (Combiflam)';

  // Reminder creation inputs
  final _reminderMedName = TextEditingController();
  final _reminderDosage = TextEditingController();
  TimeOfDay _reminderTime = TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    _reminderMedName.dispose();
    _reminderDosage.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(context: context, initialTime: _reminderTime);
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  void _addReminder(MedicateProvider provider) {
    final med = _reminderMedName.text.trim();
    final dosage = _reminderDosage.text.trim();
    if (med.isEmpty || dosage.isEmpty) return;
    
    provider.addMedicineReminder(med, dosage, _reminderTime.format(context));
    _reminderMedName.clear();
    _reminderDosage.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Medicine reminder scheduled.')),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: AppTheme.primaryPurple, size: 18),
      filled: true,
      fillColor: Colors.black.withOpacity(0.12),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.borderCard)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.primaryPurple)),
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
              controller: _subTabController,
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textSecondary,
              indicator: BoxDecoration(color: AppTheme.primaryPurple, borderRadius: BorderRadius.circular(12)),
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              tabs: [
                Tab(text: 'REMINDERS'),
                Tab(text: 'CHECKER'),
                Tab(text: 'INVENTORY'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _subTabController,
        children: [
          _buildRemindersView(provider),
          _buildCheckerView(provider),
          _buildInventoryView(provider),
        ],
      ),
    );
  }

  Widget _buildRemindersView(MedicateProvider provider) {
    final reminders = provider.reminders;
    final takenCount = reminders.where((r) => r.isTaken).length;
    final missedCount = reminders.length - takenCount;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Stats
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  radius: 20,
                  borderColor: AppTheme.success.withOpacity(0.15),
                  fillColor: AppTheme.success.withOpacity(0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TAKEN TODAY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                      SizedBox(height: 8),
                      Text('$takenCount Pills', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.success)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: GlassCard(
                  radius: 20,
                  borderColor: AppTheme.warning.withOpacity(0.15),
                  fillColor: AppTheme.warning.withOpacity(0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PENDING/MISSED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                      SizedBox(height: 8),
                      Text('$missedCount Pills', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.warning)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 28),

          // Add reminder form
          Text('New Medicine Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          SizedBox(height: 12),
          GlassCard(
            radius: 20,
            borderColor: AppTheme.primaryPurple.withOpacity(0.15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _reminderMedName,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: _inputDecoration('Medicine Name (e.g. Lipitor)', Icons.medication_rounded),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _reminderDosage,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: _inputDecoration('Dosage Details (e.g. 1 Pill)', Icons.healing_rounded),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Alert Time: ${_reminderTime.format(context)}',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _selectTime(context),
                      icon: Icon(Icons.timer_outlined, size: 14, color: AppTheme.primaryPurple),
                      label: Text('SET TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple)),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: AppTheme.primaryPurple)),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _addReminder(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('SCHEDULE ALARM', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
          SizedBox(height: 28),

          Text('Alarms List', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          SizedBox(height: 12),
          if (reminders.isEmpty)
            GlassCard(
              radius: 16,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text('No active medication schedules.', style: TextStyle(color: AppTheme.textSecondary)),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: reminders.length,
              itemBuilder: (context, idx) {
                final rem = reminders[idx];
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    radius: 20,
                    borderColor: rem.isTaken ? AppTheme.success.withOpacity(0.2) : AppTheme.borderCard,
                    fillColor: rem.isTaken ? AppTheme.success.withOpacity(0.04) : Color(0x0AFFFFFF),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: rem.isTaken,
                              activeColor: AppTheme.success,
                              onChanged: (val) {
                                provider.toggleReminderTaken(rem.id);
                              },
                            ),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rem.medicineName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppTheme.textPrimary,
                                    decoration: rem.isTaken ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${rem.dosage} • Time: ${rem.time}',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_sweep_outlined, color: AppTheme.error, size: 22),
                          onPressed: () => provider.removeReminder(rem.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCheckerView(MedicateProvider provider) {
    final listNames = provider.medicines.map((m) => m.name).toList();
    if (!listNames.contains(_selectedDrugA) && listNames.isNotEmpty) _selectedDrugA = listNames[0];
    if (!listNames.contains(_selectedDrugB) && listNames.isNotEmpty) _selectedDrugB = listNames.length > 1 ? listNames[1] : listNames[0];

    final result = provider.checkDrugInteraction(_selectedDrugA, _selectedDrugB);
    Color statusColor = AppTheme.success;
    if (result['color'] == 'red') statusColor = AppTheme.error;
    if (result['color'] == 'orange') statusColor = AppTheme.warning;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Clinical Drug Interaction Checker', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          SizedBox(height: 6),
          Text(
            'Check for adverse reactions or contraindications between two medications.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          SizedBox(height: 20),

          GlassCard(
            radius: 20,
            borderColor: AppTheme.primaryPurple.withOpacity(0.15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedDrugA,
                  dropdownColor: AppTheme.cardColor,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                  decoration: _inputDecoration('First Medication', Icons.medication_rounded),
                  items: listNames.map((n) => DropdownMenuItem(value: n, child: Text(n, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedDrugA = v);
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedDrugB,
                  dropdownColor: AppTheme.cardColor,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                  decoration: _inputDecoration('Second Medication', Icons.medication_rounded),
                  items: listNames.map((n) => DropdownMenuItem(value: n, child: Text(n, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedDrugB = v);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          Text('Analysis Results', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          SizedBox(height: 12),
          GlassCard(
            radius: 20,
            borderColor: statusColor.withOpacity(0.3),
            fillColor: statusColor.withOpacity(0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      result['color'] == 'red' 
                        ? Icons.error_rounded 
                        : (result['color'] == 'orange' ? Icons.warning_rounded : Icons.check_circle_rounded),
                      color: statusColor,
                      size: 24,
                    ),
                    SizedBox(width: 10),
                    Text(
                      result['status']!.toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: statusColor, letterSpacing: 1),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  result['details']!,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryView(MedicateProvider provider) {
    final list = provider.medicines;

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final med = list[idx];
        final isLowStock = med.stock <= 50;
        final stockColor = isLowStock ? AppTheme.error : AppTheme.success;

        // Mock expiry dates
        final int hash = med.name.hashCode.abs();
        final String expiryDate = '${(hash % 28) + 1}/${(hash % 12) + 1}/2027';

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: GlassCard(
            radius: 20,
            borderColor: isLowStock ? AppTheme.error.withOpacity(0.15) : AppTheme.borderCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        med.name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: stockColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Stock: ${med.stock}',
                        style: TextStyle(color: stockColor, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(med.description, style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.3)),
                Divider(color: AppTheme.borderCard, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.date_range_rounded, size: 14, color: AppTheme.textSecondary),
                        SizedBox(width: 6),
                        Text('Expires: $expiryDate', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                    if (isLowStock)
                      Row(
                        children: [
                          Icon(Icons.error_outline_rounded, size: 14, color: AppTheme.error),
                          SizedBox(width: 4),
                          Text('LOW STOCK ALERT', style: TextStyle(color: AppTheme.error, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
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
}
