import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/services/services.dart';

class CalendarTab extends StatefulWidget {
  CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  DateTime _selectedDate = DateTime.now();
  String _selectedDept = 'Cardiology';
  String? _selectedDoctor;
  TimeOfDay _selectedTime = TimeOfDay(hour: 10, minute: 0);

  final List<String> _departments = ['Cardiology', 'Neurology', 'Diagnostics', 'Pediatrics'];

  @override
  void initState() {
    super.initState();
  }

  void _bookAppointment(BuildContext context, MedicateProvider provider) {
    final doctorList = provider.doctors.where((d) => d.specialty.toLowerCase().contains(_selectedDept.toLowerCase()) || _selectedDept == 'General Practice').toList();
    final doctorName = _selectedDoctor ?? (doctorList.isNotEmpty ? doctorList[0].name : 'Dr. Reed Richards');
    
    final appointmentDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    provider.bookAppointment(doctorName, _selectedDept, appointmentDateTime);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.warning,
        behavior: SnackBarBehavior.floating,
        content: Text(
          'SUCCESS: Appointment booked with $doctorName on ${_selectedDate.day}/${_selectedDate.month} at ${_selectedTime.format(context)}.',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 30)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: AppTheme.warning, size: 18),
      filled: true,
      fillColor: Colors.black.withOpacity(0.12),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.borderCard)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.warning)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    final user = provider.currentUser;
    final doctorList = provider.doctors.where((d) => d.specialty.toLowerCase().contains(_selectedDept.toLowerCase()) || _selectedDept == 'General Practice').toList();
    if (_selectedDoctor == null && doctorList.isNotEmpty) {
      _selectedDoctor = doctorList[0].name;
    } else if (doctorList.isNotEmpty && !doctorList.any((d) => d.name == _selectedDoctor)) {
      _selectedDoctor = doctorList[0].name;
    }

    final myAppointments = provider.appointments.where((a) => a.patientId == user?.id).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scheduling Center',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          SizedBox(height: 4),
          Text(
            'Appointment Bookings',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          SizedBox(height: 20),

          // Interactive Date Picker Card
          GestureDetector(
            onTap: () => _pickDate(context),
            child: GlassCard(
              radius: 20,
              borderColor: AppTheme.warning.withOpacity(0.15),
              fillColor: AppTheme.warning.withOpacity(0.04),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.calendar_month_rounded, color: AppTheme.warning),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SELECTED DATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                        SizedBox(height: 4),
                        Text(
                          '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.edit_calendar_rounded, color: AppTheme.warning, size: 20),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Booking Form
          Text('Book Consult', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          SizedBox(height: 12),
          GlassCard(
            radius: 20,
            borderColor: AppTheme.borderCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedDept,
                  dropdownColor: AppTheme.cardColor,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: _inputDecoration('Department', Icons.business_rounded),
                  items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _selectedDept = v;
                        _selectedDoctor = null; // force recalculation of default doctor
                      });
                    }
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedDoctor,
                  dropdownColor: AppTheme.cardColor,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: _inputDecoration('Choose Doctor', Icons.medical_services_outlined),
                  items: doctorList.map((d) => DropdownMenuItem(value: d.name, child: Text(d.name))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedDoctor = v);
                  },
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Consultation Time: ${_selectedTime.format(context)}',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _pickTime(context),
                      icon: Icon(Icons.access_time_rounded, size: 14, color: AppTheme.warning),
                      label: Text('SET TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.warning)),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: AppTheme.warning)),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _bookAppointment(context, provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warning,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('SCHEDULE CONSULTATION', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
          SizedBox(height: 28),

          Text('Scheduled Consultations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          SizedBox(height: 12),
          if (myAppointments.isEmpty)
            GlassCard(
              radius: 16,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text('No booked appointments found.', style: TextStyle(color: AppTheme.textSecondary)),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: myAppointments.length,
              itemBuilder: (context, idx) {
                final appt = myAppointments[idx];
                final dateStr = '${appt.dateTime.day}/${appt.dateTime.month}/${appt.dateTime.year}';
                final timeStr = '${appt.dateTime.hour.toString().padLeft(2, '0')}:${appt.dateTime.minute.toString().padLeft(2, '0')}';
                
                Color statusColor = AppTheme.warning;
                if (appt.status == 'Approved') statusColor = AppTheme.success;
                if (appt.status == 'Cancelled') statusColor = AppTheme.error;
                if (appt.status == 'Completed') statusColor = AppTheme.info;

                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    radius: 20,
                    borderColor: statusColor.withOpacity(0.15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              appt.doctorName,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                appt.status.toUpperCase(),
                                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 1),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          '${appt.department} Department • $dateStr @ $timeStr',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                        Divider(color: AppTheme.borderCard, height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (appt.status == 'Pending') ...[
                              OutlinedButton(
                                onPressed: () {
                                  provider.updateAppointmentStatus(appt.id, 'Cancelled');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Appointment Cancelled.')),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppTheme.error),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('CANCEL', style: TextStyle(color: AppTheme.error, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  provider.updateAppointmentStatus(appt.id, 'Approved');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Appointment Approved.')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.success,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('APPROVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                            if (appt.status == 'Approved')
                              ElevatedButton(
                                onPressed: () {
                                  provider.updateAppointmentStatus(appt.id, 'Completed');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.info,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('MARK COMPLETE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                          ],
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

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
