import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_colors.dart';

class ScannerScreen extends StatefulWidget {
  final void Function(String) onBarcodeDetected;
  final VoidCallback onBack;

  const ScannerScreen({
    super.key,
    required this.onBarcodeDetected,
    required this.onBack,
  });

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _hasPermission = false;
  String _language = 'de';

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _language = prefs.getString('language') ?? 'de';
    });
  }

  String _t(String de, String en) => _language == 'de' ? de : en;

  Future<void> _requestPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }
    if (!mounted) return;
    setState(() {
      _hasPermission = status.isGranted || status.isLimited;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Container(
        color: AppColors.colorBackground,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.no_photography,
                color: AppColors.colorNeutral,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                _t('Kamera-Berechtigung fehlt', 'Camera permission missing'),
                style: const TextStyle(color: AppColors.colorLight),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async => openAppSettings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.colorPrimary,
                  foregroundColor: AppColors.colorDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(_t('Einstellungen öffnen', 'Open Settings')),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Container(color: AppColors.colorBackground),
        Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.colorPrimary,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: MobileScanner(
                          onDetect: (capture) {
                            final value =
                                capture.barcodes.firstOrNull?.rawValue ??
                                capture.barcodes.firstOrNull?.displayValue;
                            if (value != null) widget.onBarcodeDetected(value);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      _t('QR-Code scannen', 'Scan QR Code'),
                      style: const TextStyle(
                        color: AppColors.colorLight,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _t(
                        'Halte die Karte vor den Scanner',
                        'Hold the card in front of the scanner',
                      ),
                      style: TextStyle(
                        color: AppColors.colorLight.withOpacity(0.4),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 16,
          left: 16,
          child: SafeArea(
            child: GestureDetector(
              onTap: widget.onBack,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.colorCard,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.colorNeutral.withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.colorLight,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
