import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  bool _isProcessing = false;
  String? _pendingCode;
  int _countdown = 3;

  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: const [BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.upcA, BarcodeFormat.upcE],
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 500,
      returnImage: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Logic Delay 3s
  void _handleBarcodeDetected(String code) async {
    if (_isProcessing) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _isProcessing = true;
      _pendingCode = code;
      _countdown = 3;
    });

    // Bắt đầu đếm ngược
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      if (!_isProcessing) return;

      setState(() {
        _countdown--;
      });
    }

    if (mounted && _isProcessing) {
      Navigator.pop(context, _pendingCode);
    }
  }

  void _cancelScan() {
    setState(() {
      _isProcessing = false;
      _pendingCode = null;
      _countdown = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double scanWindowWidth = MediaQuery.of(context).size.width * 0.8;
    final double scanWindowHeight = 250.0;
    final Rect scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: scanWindowWidth,
      height: scanWindowHeight,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan the barcode"),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            scanWindow: scanWindow,
            onDetect: (capture) {
              if (_isProcessing) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleBarcodeDetected(barcode.rawValue!);
                  break;
                }
              }
            },
            errorBuilder: (context, error, child) {
              return Center(
                child: Text("Camera Error: $error", style: const TextStyle(color: Colors.white)),
              );
            },
          ),

          // LỚP 2: Overlay
          CustomPaint(
            painter: ScannerOverlayPainter(scanWindow),
            child: Container(),
          ),

          //Giao diện Đếm ngược
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 60),
                    const SizedBox(height: 20),
                    Text(
                      "Code found: $_pendingCode",
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Adding in $_countdown s...",
                      style: const TextStyle(color: Colors.orangeAccent, fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _cancelScan,
                      icon: const Icon(Icons.close),
                      label: const Text("Cancel & Rescan"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),

          if (!_isProcessing)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Text(
                "Move the barcode into the frame.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Rect scanWindow;
  final double borderRadius;

  ScannerOverlayPainter(this.scanWindow, {this.borderRadius = 20.0});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          scanWindow,
          Radius.circular(borderRadius),
        ),
      );

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawPath(backgroundWithCutout, backgroundPaint);

    //Vẽ viền cam bao quanh lỗ khoét
    final borderPaint = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        scanWindow,
        Radius.circular(borderRadius),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}