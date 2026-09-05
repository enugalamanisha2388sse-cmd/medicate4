import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool _addedToRefillList = false;

  void _onAddToRefillList() {
    setState(() {
      _addedToRefillList = !_addedToRefillList;
    });

    final provider = Provider.of<MedicateProvider>(context, listen: false);
    if (_addedToRefillList) {
      provider.addNotification('SUCCESS: Added Amoxicillin 500mg to your Refill List.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Amoxicillin 500mg added to Refill List!', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF0D9488),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  void _onViewAllInventory() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Complete Inventory List',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 12),
              _buildInventoryListItem('Amoxicillin 500mg', '12 Capsules Left', 'Daily usage: 3'),
              _buildInventoryListItem('Ibuprofen 400mg', '18 Tablets Left', 'Daily usage: 3'),
              _buildInventoryListItem('Vitamin D3 1000IU', '30 Softgels Left', 'Daily usage: 1'),
              _buildInventoryListItem('Paracetamol 500mg', '24 Tablets Left', 'Daily usage: 2'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInventoryListItem(String name, String stock, String usage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
              Text(usage, style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
          Text(stock, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF0D9488))),
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
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Stock Prediction',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Details
              Text(
                'Amoxicillin 500mg',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                'Capsule',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Remaining Days Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.isDark ? Colors.transparent : const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Remaining',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '4 Days',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D9488),
                      ),
                    ),
                    Text(
                      'Based on your current schedule',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.33,
                        backgroundColor: const Color(0xFFE2E8F0),
                        color: const Color(0xFF0D9488),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Stock Stats Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stock Left',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '12 Capsules',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Usage',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '3 Capsules',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. Add to Refill List button
              GestureDetector(
                onTap: _onAddToRefillList,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _addedToRefillList
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : [const Color(0xFF0D9488), const Color(0xFF0F766E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _addedToRefillList ? 'Added to Refill List ✓' : 'Add to Refill List',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 5. Upcoming Refills section
              Text(
                'Upcoming Refills',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              
              // Refill List Item 1
              _buildRefillItem(
                Icons.medication_rounded,
                'Ibuprofen 400mg',
                'In 6 Days',
                const Color(0xFFEF4444),
                const Color(0xFFFEE2E2),
              ),
              const SizedBox(height: 10),
              // Refill List Item 2
              _buildRefillItem(
                Icons.medication_rounded,
                'Vitamin D3 1000IU',
                'In 10 Days',
                const Color(0xFFF59E0B),
                const Color(0xFFFEF3C7),
              ),
              const SizedBox(height: 28),

              // 6. View All Inventory button at the bottom
              GestureDetector(
                onTap: _onViewAllInventory,
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
                      'View All Inventory',
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
    );
  }

  Widget _buildRefillItem(
    IconData icon,
    String name,
    String time,
    Color color,
    Color bg,
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
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
