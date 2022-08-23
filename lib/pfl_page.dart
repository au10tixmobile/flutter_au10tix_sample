import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdk_pfl_flutter/sdk_pfl_flutter.dart';
import 'package:sdk_core_flutter/camera_view.dart';
import 'package:permission_handler/permission_handler.dart';

class PFLPage extends StatefulWidget {
  static const routeName = '/pfl-page';

  @override
  State<PFLPage> createState() => _PFLPageState();
}

class _PFLPageState extends State<PFLPage> {
  Map? _hasResult;
  Map? _hasValidation;
  String featureType = 'pfl';

  @override
  void dispose() {
    super.dispose();
    SdkPflFlutter.stopSession();
  }

  Future<void> _onCaptureClick() async {
    if (_hasResult != null) {}
    final result = await SdkPflFlutter.onCaptureClicked();
    setState(() {
      _hasResult = result;
    });
  }

  Future<void> _validateLiveness() async {
    try {
      _hasValidation = await SdkPflFlutter.validateLiveness();
      int passed = _hasValidation?['pfl']['status'];
      _showToast(context, _hasValidation?['pfl']['details'],
          passed == 1 ? Colors.green : Colors.red);
    } on PlatformException catch (e) {
      _showToast(context, e.message!, Colors.red);
    }
  }

  void _showToast(BuildContext context, String message, Color bgColor) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor,
      ),
    );
  }

  void _onRefreshClicked() {
    setState(() {
      _hasResult = null;
    });
    _startPFL();
    _hasResult = null;
    _hasValidation = null;
  }

  void _onApproveClicked() {
    Navigator.of(context).pop();
  }

  Future<void> _startPFL() async {
    if (await Permission.camera.request().isGranted) {
      try {
        final result = await SdkPflFlutter.startPFL();
        setState(() {
          _hasResult = result;
        });
      } on PlatformException catch (error) {
        print(error.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("hasResult = ${_hasResult?['pfl']['status']}");
    return Scaffold(
      appBar: AppBar(
        title: const Text('PFL Page'),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              _hasResult == null
                  ? Au10tixCameraView(
                      featureHandlerFn: _startPFL,
                      viewType: "au10tixCameraViewPFL")
                  : Image.file(
                      File(_hasResult!['pfl']['imagePath']),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width / (3 / 4),
                      fit: BoxFit.fitHeight,
                    ),
              StreamBuilder<String>(
                stream: SdkPflFlutter.streamPFLUpdates()
                    .map((event) => SdkPflFlutter.getPFLTextUpdates(event)),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            color: Colors.grey[800],
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              '${snapshot.data}',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const Text('');
                  }
                },
              ),
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _hasResult == null
                      ? _onCaptureClick
                      : _hasValidation != null
                          ? _hasValidation!['pfl']['status'] == 1
                              ? _onApproveClicked
                              : _onRefreshClicked
                          : _hasResult!['pfl']['status'] == 1
                              ? _validateLiveness
                              : _onRefreshClicked,
                  child: Image.asset(
                    _hasResult == null
                        ? 'assets/images/capture_btn.png'
                        : _hasValidation != null
                            ? _hasValidation!['pfl']['status'] == 1
                                ? 'assets/images/approve_btn.png'
                                : 'assets/images/refresh_btn.png'
                            : _hasResult!['pfl']['status'] == 1
                                ? 'assets/images/approve_btn.png'
                                : 'assets/images/refresh_btn.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
