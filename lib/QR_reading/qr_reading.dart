import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  bool checkURL(code) {
    bool isurl = Uri.tryParse(code)?.hasAbsolutePath ?? false;
    return isurl;
  }

  void _launchURL(_url) async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  reset() {
    setState(() {
      result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ink(
          color: Colors.black87,
          child: Column(
            children: <Widget>[
              Expanded(flex: 4, child: _buildQrView(context)),
              result == null ? scanControls() : controls(),
            ],
          )),
    );
  }

  Widget scanControls() {
    return Expanded(
      flex: 1,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Text(
              'Scan a code',
              style: TextStyle(color: Colors.white),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 35,
                  margin: const EdgeInsets.all(8),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.white24),
                      onPressed: () async {
                        await controller?.toggleFlash();
                        setState(() {});
                      },
                      child: FutureBuilder(
                        future: controller?.getFlashStatus(),
                        builder: (context, snapshot) {
                          return snapshot.data == true
                              ? const Icon(Icons.flash_on)
                              : const Icon(Icons.flash_off);

                          // Text('Flash: ${snapshot.data}');
                        },
                      )),
                ),
                Container(
                  height: 50,
                  margin: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.white24),
                    onPressed: () async {
                      await controller?.pauseCamera();
                    },
                    child: const Icon(Icons.pause),
                    // const Text('pause', style: TextStyle(fontSize: 20)),
                  ),
                ),
                Container(
                  height: 50,
                  margin: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.white24),
                    onPressed: () async {
                      await controller?.resumeCamera();
                    },
                    child: const Icon(Icons.play_arrow),
                    // const Text('resume', style: TextStyle(fontSize: 20)),
                  ),
                ),
                Container(
                  height: 35,
                  margin: const EdgeInsets.all(8),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.white24),
                      onPressed: () async {
                        await controller?.flipCamera();
                        setState(() {});
                      },
                      child: FutureBuilder(
                        future: controller?.getCameraInfo(),
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            return const Icon(Icons.flip_camera_android);
                            // Text('Camera facing ${describeEnum(snapshot.data!)}');
                          } else {
                            return const Text('loading');
                          }
                        },
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget controls() {
    return Expanded(
      child: Column(
        children: [
          Center(
              child: Text(
            'Barcode Type: ${describeEnum(result!.format)}',
            style: const TextStyle(color: Colors.white),
          )),
          Center(
              child: Text(
            'Data: ${result!.code}',
            style: const TextStyle(color: Colors.white),
          )),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Container(
                margin: const EdgeInsets.all(8),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.white24),
                    onPressed: () {
                      reset();
                    },
                    child: const Icon(Icons.close)
                    // const Text('ok', style: TextStyle(fontSize: 20)),
                    )),
            Container(
                margin: const EdgeInsets.all(8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.white24),
                  onPressed: checkURL(result!.code)
                      ? () {
                          _launchURL(result!.code);
                        }
                      : null,
                  child:
                      const Text('Visit URL', style: TextStyle(fontSize: 20)),
                )),
          ])
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
