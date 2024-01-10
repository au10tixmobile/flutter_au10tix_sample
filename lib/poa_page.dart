// ignore_for_file: use_key_in_widget_constructors

import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdk_core_flutter/camera_view.dart';
import 'package:sdk_sdc_flutter/sdk_sdc_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class POAPage extends StatefulWidget {
  static const routeName = '/poa-page';

  @override
  State<POAPage> createState() => _POAPageState();
}

class _POAPageState extends State<POAPage> {
  Map? _hasResult;
  Future<void> _onCaptureClick() async {
    if (_hasResult != null) {}
    final result = await SdkSdcFlutter.onCaptureClicked();
    setState(() {
      _hasResult = result;
    });
  }

  Future<void> _onUploadClick() async {
    final result = await SdkSdcFlutter.onUploadClicked();
    setState(() {
      _hasResult = result;
    });
  }

  void _onRefreshClicked() {
    setState(() {
      _hasResult = null;
    });
    _startPOA();
  }

  void _onApproveClicked() {
    Navigator.of(context).pop();
  }

  Future<void> _startPOA() async {
    if (await Permission.camera.request().isGranted) {
      try {
        final result = await SdkSdcFlutter.startPOA();
        if (kDebugMode) {
          print(result.toString());
        }
        setState(() {
          _hasResult = result;
        });
      } on PlatformException catch (error) {
        if (kDebugMode) {
          print(error.message);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: _onBackPressed),
        title: const Text('POA Page'),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              _hasResult == null
                  ? Au10tixCameraView(
                      featureHandlerFn: _startPOA,
                      viewType: "au10tixCameraViewSDC",
                    )
                  : Image.file(
                      File(_hasResult!['poa']['imagePath']),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width / (3 / 4),
                      fit: BoxFit.fitHeight,
                    ),
              _hasResult == null
                  ? StreamBuilder<String>(
                      stream: SdkSdcFlutter.streamSdkUpdates().map(
                          (event) => SdkSdcFlutter.getPOATextUpdates(event)),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return StatusLabel(snapshot.data!);
                        } else {
                          return const Text('');
                        }
                      })
                  : StatusLabel(
                      SdkSdcFlutter.getPOATextUpdates(_hasResult, true)),
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _onUploadClick,
                  child: Image.asset(
                    'assets/images/upload_btn.png',
                    fit: BoxFit.cover,
                  ),
                ),
                GestureDetector(
                  onTap: _hasResult == null
                      ? _onCaptureClick
                      : _hasResult!['poa']['status'] == 1
                          ? _onApproveClicked
                          : _onRefreshClicked,
                  child: Image.asset(
                    _hasResult == null
                        ? 'assets/images/capture_btn.png'
                        : _hasResult!['poa']['status'] == 1
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

  void _onBackPressed() {
    SdkSdcFlutter.stopSession();
    Navigator.of(context).pop();
  }
}

class StatusLabel extends StatelessWidget {
  String data;

  StatusLabel(this.data);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.grey[800],
            padding: const EdgeInsets.all(5),
            child: Text(
              data,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
