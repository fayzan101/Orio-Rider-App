import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGenerator {
  // Generate QR code widget for tracking number
  static Widget generateQRCode(String trackingNumber, {double size = 200}) {
    return QrImageView(
      data: trackingNumber,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    );
  }

  // Get all test tracking numbers
  static List<String> getTestTrackingNumbers() {
    return [
      'TRK123456789',
      'TRK987654321', 
      'TRK456789123',
      'TRK789123456',
      'TRK321654987',
    ];
  }
} 