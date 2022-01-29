import 'package:flutter/material.dart';
import 'QR_reading/qr_reading.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QRViewExample(),
    );
  }
}
