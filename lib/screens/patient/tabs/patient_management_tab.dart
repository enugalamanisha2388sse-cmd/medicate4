import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/services/services.dart';

class PatientManagementTab extends StatefulWidget {
  PatientManagementTab({super.key});

  @override
  State<PatientManagementTab> createState() => _PatientManagementTabState();
}

class _PatientManagementTabState extends State<PatientManagementTab> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  void _showAddEditPatientDialog(BuildContext context, {PatientRecord? patient}) {
    final provider = Provider.of<MedicateProvider>(context, listen: false);
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: patient?.name ?? '');
    final ageController = TextEditingController(text: patient?.age.toString() ?? '');
    final historyController = TextEditingController(text: patient?.medicalHistory ?? '');
    final allergiesController = TextEditingController(text: patient?.allergies ?? '');
    String selectedGender = patient?.gender ?? 'Male';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.green.withOpacity(0.3)),
              ),
              title: Row(
                children: [
                  Icon(patient == null ? Icons.person_add_alt_1_rounded : Icons.edit_note_rounded, color: Colors.green),
                  SizedBox(width: 10),
                  Text(
                    patient == null ? 'Add Patient Record' : 'Edit Patient Record',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 18),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: nameController,
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                          decoration: _inputDecoration('Full Name', Icons.person_outline),
                          validator: (v) => (v == null || v.isEmpty) ? 'Please enter a name' : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: ageController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                          decoration: _inputDecoration('Age', Icons.calendar_today_outlined),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please enter age';
                            if (int.tryParse(v) == null) return 'Enter a valid number';
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedGender,
                          dropdownColor: AppTheme.cardColor,
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                          decoration: _inputDecoration('Gender', Icons.wc_outlined),
                          items: [
                            DropdownMenuItem(value: 'Male', child: Text('Male')),
                            DropdownMenuItem(value: 'Female', child: Text('Female')),
                            DropdownMenuItem(value: 'Other', child: Text('Other')),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                selectedGender = v;
                              });
                            }
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: allergiesController,
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                          decoration: _inputDecoration('Allergies / Drug Sensitivities', Icons.warning_amber_rounded),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: historyController,
                          maxLines: 3,
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                          decoration: _inputDecoration('Medical History & Diagnoses', Icons.history_edu_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: AppTheme.borderCard)),
                  child: Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final name = nameController.text.trim();
                      final age = int.parse(ageController.text.trim());
                      final history = historyController.text.trim();
                      final allergies = allergiesController.text.trim();
                      
                      if (patient == null) {
                        provider.addPatient(name, age, selectedGender, history, allergies);
                      } else {
                        provider.updatePatient(patient.id, name, age, selectedGender, history, allergies);
                      }
                      
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text(
                    patient == null ? 'CREATE' : 'SAVE CHANGES',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeletePatient(BuildContext context, PatientRecord patient) {
    final provider = Provider.of<MedicateProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.redAccent, width: 1),
          ),
          title: Row(
            children: [
              Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Delete Record?',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete the clinical record for "${patient.name}"? This action cannot be undone.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.4),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(side: BorderSide(color: AppTheme.borderCard)),
              child: Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                provider.deletePatient(patient.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: Text('DELETE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.green, size: 18),
      filled: true,
      fillColor: Colors.black.withOpacity(0.12),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.borderCard)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    final allPatients = provider.patients;
    
    final filteredPatients = allPatients.where((p) {
      final query = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(query) ||
             p.medicalHistory.toLowerCase().contains(query) ||
             p.allergies.toLowerCase().contains(query);
    }).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clinical Files',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Patient Management',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditPatientDialog(context),
                icon: Icon(Icons.person_add_rounded, size: 16, color: Colors.white),
                label: Text('NEW', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Search Box
          GlassCard(
            radius: 20,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            borderColor: AppTheme.borderCard,
            fillColor: Colors.black.withOpacity(0.12),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: AppTheme.textPrimary),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search patients, history, or allergies...',
                hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search_rounded, color: Colors.green),
              ),
            ),
          ),
          SizedBox(height: 20),

          Expanded(
            child: filteredPatients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded, size: 48, color: AppTheme.textSecondary.withOpacity(0.5)),
                        SizedBox(height: 16),
                        Text(
                          'No patient files found.',
                          style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(bottom: 24),
                    itemCount: filteredPatients.length,
                    itemBuilder: (context, idx) {
                      final patient = filteredPatients[idx];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          radius: 20,
                          borderColor: Colors.green.withOpacity(0.12),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.green.withOpacity(0.1),
                                        child: Icon(Icons.person, color: Colors.green),
                                      ),
                                      SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            patient.name,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            '${patient.age} yrs • ${patient.gender}',
                                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit_note_rounded, color: Colors.green, size: 20),
                                        onPressed: () => _showAddEditPatientDialog(context, patient: patient),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                        onPressed: () => _confirmDeletePatient(context, patient),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (patient.allergies.isNotEmpty) ...[
                                Divider(color: AppTheme.borderCard, height: 20),
                                Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, size: 14, color: Colors.redAccent),
                                    SizedBox(width: 6),
                                    Text('Allergies: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                    Expanded(
                                      child: Text(
                                        patient.allergies,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 11, color: AppTheme.textPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (patient.medicalHistory.isNotEmpty) ...[
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.history_edu_rounded, size: 14, color: Colors.blueAccent),
                                    SizedBox(width: 6),
                                    Text('History: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                                    Expanded(
                                      child: Text(
                                        patient.medicalHistory,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
