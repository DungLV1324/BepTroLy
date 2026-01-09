import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/dialog_helper.dart';
import '../../services/receipt_service.dart';
import 'barcode_scanner_page.dart';

class ReceiptScannerPage extends StatefulWidget {
  const ReceiptScannerPage({super.key});

  @override
  State<ReceiptScannerPage> createState() => _ReceiptScannerPageState();
}

class _ReceiptScannerPageState extends State<ReceiptScannerPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final ReceiptService _receiptService = ReceiptService();

  bool _isProcessing = false;
  bool _showSuccessOverlay = false;
  int _countdown = 3;
  int _foundItemsCount = 0;
  List<String> _tempRawItems = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.veryHigh, enableAudio: false);
    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _receiptService.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _takePictureAndScan() async {
    if (_isProcessing || _showSuccessOverlay) return;

    try {
      setState(() => _isProcessing = true);

      await _initializeControllerFuture;
      final image = await _controller!.takePicture();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Processing image..."), duration: Duration(seconds: 1)),
        );
      }

      final File imageFile = File(image.path);
      final List<String> rawItems = await _receiptService.scanReceipt(imageFile);

      if (rawItems.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No text found. Try again.")),
          );
        }
        setState(() => _isProcessing = false);
      } else {
        _startSuccessCountdown(rawItems);
      }
    } catch (e) {
      print(e);
      setState(() => _isProcessing = false);
    }
  }

  void _startSuccessCountdown(List<String> items) {
    setState(() {
      _isProcessing = false;
      _showSuccessOverlay = true;
      _foundItemsCount = items.length;
      _tempRawItems = items;
      _countdown = 3;
    });

    // Bắt đầu đếm lùi
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) return;

      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();
        _openReviewDialog();
      }
    });
  }

  void _cancelScan() {
    _timer?.cancel();
    setState(() {
      _showSuccessOverlay = false;
      _tempRawItems = [];
      _countdown = 3;
    });
  }

  // Hàm mở Dialog chọn món
  Future<void> _openReviewDialog() async {
    setState(() => _showSuccessOverlay = false);

    final List<String>? selectedItems = await DialogHelper.showReceiptReviewDialog(context, _tempRawItems);

    if (selectedItems != null && mounted) {
      Navigator.pop(context, selectedItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double scanWindowWidth = MediaQuery.of(context).size.width * 0.85;
    final double scanWindowHeight = MediaQuery.of(context).size.height * 0.55;
    final Rect scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(const Offset(0, -40)),
      width: scanWindowWidth,
      height: scanWindowHeight,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Scan Receipt", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. CAMERA PREVIEW
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Center(child: CameraPreview(_controller!));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),

          CustomPaint(
            painter: ScannerOverlayPainter(scanWindow),
            child: Container(),
          ),

          if (!_showSuccessOverlay)
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Text(
                "Align receipt within the frame",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
                ),
              ),
            ),

          if (!_showSuccessOverlay)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : GestureDetector(
                  onTap: _takePictureAndScan,
                  child: Container(
                    width: 84, // To hơn một chút
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), // Vòng mờ bên ngoài
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white, // Nút trắng bên trong
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 36, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),

          //Bảng xác nhận đếm ngược
          if (_showSuccessOverlay)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon Tích Xanh
                      const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 64),
                      const SizedBox(height: 16),

                      // Thông báo
                      Text(
                        "Found $_foundItemsCount items!",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Đếm ngược
                      Text(
                        "Reviewing in $_countdown s...",
                        style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _cancelScan,
                          icon: const Icon(Icons.close),
                          label: const Text("Cancel & Rescan"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: () {
                          _timer?.cancel();
                          _openReviewDialog();
                        },
                        child: const Text("Review Now", style: TextStyle(color: Colors.grey)),
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}