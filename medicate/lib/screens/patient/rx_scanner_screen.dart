import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';

class RxScannerScreen extends StatefulWidget {
  const RxScannerScreen({super.key});

  @override
  State<RxScannerScreen> createState() => _RxScannerScreenState();
}

class _RxScannerScreenState extends State<RxScannerScreen>
    with TickerProviderStateMixin {
  late AnimationController _sweepController;
  late Animation<double> _sweepAnim;

  late AnimationController _cardSlideController;
  late Animation<Offset> _cardSlideAnim;

  bool _isScanning = false;
  bool _scanComplete = false;

  @override
  void initState() {
    super.initState();

    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _sweepAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sweepController, curve: Curves.easeInOut),
    );

    _cardSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _cardSlideAnim = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _cardSlideController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _cardSlideController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _scanComplete = false;
    });

    _sweepController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 1800));
    _sweepController.stop();

    if (!mounted) return;
    setState(() {
      _isScanning = false;
      _scanComplete = true;
    });

    _cardSlideController.forward(from: 0.0);
  }



  void _addMedicineAndReturn() {
    final provider = Provider.of<MedicateProvider>(context, listen: false);
    provider.addMedicineReminder('Amoxicillin 500mg', 'Take 1 Capsule', '09:00 AM');
    provider.addNotification('SUCCESS: Added Amoxicillin 500mg reminder via tablet scan.');
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Amoxicillin 500mg reminder added to your schedule!',
        style: GoogleFonts.poppins(),
      ),
      backgroundColor: const Color(0xFF0D9488),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
    Navigator.pop(context);
  }

  void _showEditDetailsDialog() {
    String name = 'Amoxicillin 500mg';
    String manufacturer = 'Cipla Ltd.';
    String expiry = '12 Dec 2025';
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Edit Scanned Details',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Medicine Name'),
                controller: TextEditingController(text: name),
                onChanged: (val) => name = val,
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Manufacturer'),
                controller: TextEditingController(text: manufacturer),
                onChanged: (val) => manufacturer = val,
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Expiry Date'),
                controller: TextEditingController(text: expiry),
                onChanged: (val) => expiry = val,
                style: TextStyle(color: AppTheme.textPrimary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final provider = Provider.of<MedicateProvider>(context, listen: false);
                provider.addMedicineReminder(name, 'Take 1 Capsule', '09:00 AM');
                provider.addNotification('SUCCESS: Added $name reminder via tablet scan (edited).');
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close scanner
                
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    '$name reminder added to your schedule!',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: const Color(0xFF0D9488),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
              child: const Text('Save & Use', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCornerBracket({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isTop,
    required bool isLeft,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: SizedBox(
        width: 28,
        height: 28,
        child: CustomPaint(
          painter: _CornerBracketPainter(isTop: isTop, isLeft: isLeft),
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
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
            'Detected Medicine',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0D9488),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Amoxicillin 500mg',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          Text(
            'Capsule',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manufacturer',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                'Cipla Ltd.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expiry',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                '12 Dec 2025',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          GestureDetector(
            onTap: _addMedicineAndReturn,
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
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Use This Medicine',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          Center(
            child: TextButton(
              onPressed: _showEditDetailsDialog,
              child: Text(
                'Edit Details',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF0D9488),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MobileViewFrame(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 1. Full-screen Camera preview (simulated using blister_pack.jpg)
            Positioned.fill(
              child: Image.asset(
                'assets/images/blister_pack.jpg',
                fit: BoxFit.cover,
              ),
            ),
            
            // 2. Translucent dark overlay with a transparent viewport cutout in the center
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.srcOut,
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        backgroundBlendMode: BlendMode.dstOut,
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Center viewport border lines & brackets
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    _buildCornerBracket(top: 10, left: 10, isTop: true, isLeft: true),
                    _buildCornerBracket(top: 10, right: 10, isTop: true, isLeft: false),
                    _buildCornerBracket(bottom: 10, left: 10, isTop: false, isLeft: true),
                    _buildCornerBracket(bottom: 10, right: 10, isTop: false, isLeft: false),
                    
                    if (_isScanning)
                      AnimatedBuilder(
                        animation: _sweepAnim,
                        builder: (context, _) {
                          return Positioned(
                            top: _sweepAnim.value * 240 + 20,
                            left: 16,
                            right: 16,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.cyanAccent,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyanAccent.withOpacity(0.8),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            // 4. Custom App Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Place the medicine package\ninside the frame',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 5. Bottom controls (Gallery, Focus, Capture, Share)
            if (!_scanComplete)
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo_outlined, color: Colors.white, size: 28),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.filter_center_focus_outlined, color: Colors.white, size: 28),
                        onPressed: () {},
                      ),
                      GestureDetector(
                        onTap: _isScanning ? null : _startScan,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Center(
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.ios_share_outlined, color: Colors.white, size: 28),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),

            // 6. Sliding results card overlay (when scan complete)
            if (_scanComplete)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _cardSlideAnim,
                  child: _buildDetailsCard(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;

  _CornerBracketPainter({required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    if (isTop && isLeft) {
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(0, size.height);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, 0);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
