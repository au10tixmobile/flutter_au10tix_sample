// ignore_for_file: use_key_in_widget_constructors

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_au10tix_sample/constants.dart';
import 'package:sdk_core_flutter/sdk_core_flutter.dart';
import 'package:sdk_sdc_flutter/sdk_sdc_flutter.dart';
import 'package:sdk_pfl_flutter/sdk_pfl_flutter.dart';
import 'package:sdk_core_flutter/ui_config.dart';
import './pfl_page.dart';
import './sdc_page.dart';
import './poa_page.dart';
import 'ui_toggle_button_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Au10tix Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      routes: {
        PFLPage.routeName: (ctx) => PFLPage(),
        SDCPage.routeName: (ctx) => SDCPage(),
        POAPage.routeName: (ctx) => POAPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  String _authToken = workflowResponse;

  var _sdcUIResult;
  bool _showCloseBtn = true;
  bool _showPrimaryBtn = true;
  bool _showUploadBtn = true;
  bool _showIntro = true;

  bool _isF2F = false;

  Future<void> _prepareSDK(BuildContext context) async {
    try {
      if (_controller.text.isNotEmpty) {
        _authToken = _controller.text;
      }
      final result = await Au10tix.init(_authToken);
      if (result.containsKey("init")) {
        _showToast(context, result["init"].toString(), Colors.green);
      }
    } on PlatformException catch (error) {
      _showToast(context, error.message!, Colors.red);
      // ignore: empty_catches
    } catch (error) {}
  }

  Future<void> _processWorkflow(BuildContext context) async {
    try {
      final result = await Au10tix.sendWorkflowRequest();
      if (result.containsKey("beKit")) {
        _showToast(context, result["beKit"].toString(), Colors.green);
        print(result["beKit"].toString());
      }
    } on PlatformException catch (error) {
      _showToast(context, error.message!, Colors.red);
      // ignore: empty_catches
    } catch (error) {}
  }

  Future<void> _startSDCUI({bool isFrontSide = true}) async {
    try {
      //UI config is optional
      UIConfig uiConfig = UIConfig(
          showIntroScreen: _showIntro,
          showCloseButton: _showCloseBtn,
          showPrimaryButton: _showPrimaryBtn,
          canUpload: _showUploadBtn);
      _sdcUIResult = await SdkSdcFlutter.startSDCUI(
          uiConfig: uiConfig, isFrontSide: isFrontSide);
      if (kDebugMode) {
        print(_sdcUIResult.toString());
      }
    } on PlatformException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
    }
  }

  Future<void> _startPFLUI() async {
    try {
      //UI config is optional
      UIConfig uiConfig = UIConfig(
        showIntroScreen: _showIntro,
        showCloseButton: _showCloseBtn,
        showPrimaryButton: _showPrimaryBtn,
      );
      final result =
          await SdkPflFlutter.startPFLUI(uiConfig: uiConfig, isF2F: _isF2F);
      if (kDebugMode) {
        print(result.toString());
      }
    } on PlatformException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
    }
  }

  Future<void> _startPOAUI() async {
    try {
      //UI config is optional
      UIConfig uiConfig = UIConfig(
          showIntroScreen: _showIntro,
          showCloseButton: _showCloseBtn,
          showPrimaryButton: _showPrimaryBtn,
          canUpload: _showUploadBtn);
      final result = await SdkSdcFlutter.startPOAUI(uiConfig: uiConfig);
      if (kDebugMode) {
        print(result.toString());
      }
    } on PlatformException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
    }
  }

  Future<void> _sendFEC(BuildContext context) async {
    try {
      final result = await SdkSdcFlutter.performFEC(
          _sdcUIResult['sdc']['croppedFilePath']);
      if (result.containsKey("fec")) {
        print(result["fec"].toString());
        _showToast(
            context,
            'FEC Result = ${result["fec"]["classificationResult"].toString()}',
            Colors.green);
      }
    } on PlatformException catch (error) {
      _showToast(context, error.message!, Colors.red);
      // ignore: empty_catches
    } catch (error) {}
  }

  void onUIToggleButtonChanged(int index, bool isSelected) {
    switch (index) {
      case 0:
        _showCloseBtn = isSelected;
        break;
      case 1:
        _showPrimaryBtn = isSelected;
        break;
      case 2:
        _showUploadBtn = isSelected;
        break;
      case 3:
        _showIntro = isSelected;
        break;
      default:
        break;
    }
  }

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Au10tix Flutter Plugin Example App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Insert Workflow Response',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _prepareSDK(context),
                  child: const Text("Prepare SDK"),
                ),
                ElevatedButton(
                  onPressed: () => _uploadFaceForCompare(),
                  child: const Text("F2F Image Upload"),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Divider(
                height: 20,
                thickness: 3,
                indent: 20,
                endIndent: 20,
                color: Colors.black,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                      SDCPage.routeName,
                      arguments: {"isFrontSide": true}),
                  child: const Text("Start SDC - Front"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                      SDCPage.routeName,
                      arguments: {"isFrontSide": false}),
                  child: const Text("Start SDC - Back"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                      PFLPage.routeName,
                      arguments: {"isF2F": _isF2F}),
                  child: const Text("Start PFL"),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(POAPage.routeName),
                  child: const Text("Start POA"),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Divider(
                height: 20,
                thickness: 3,
                indent: 20,
                endIndent: 20,
                color: Colors.black,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _startSDCUI(),
                  child: const Text("Start SDC UI - Front"),
                ),
                ElevatedButton(
                  onPressed: () => _startSDCUI(isFrontSide: false),
                  child: const Text("Start SDC UI - Back"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _startPFLUI(),
                  child: const Text("Start PFL UI"),
                ),
                ElevatedButton(
                  onPressed: () => _startPOAUI(),
                  child: const Text("Start POA UI"),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
              child: UIToggleButtonsWidget(
                onToggle: onUIToggleButtonChanged,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Divider(
                height: 20,
                thickness: 3,
                indent: 20,
                endIndent: 20,
                color: Colors.black,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _processWorkflow(context),
                  child: const Text("Process Workflow"),
                ),
                ElevatedButton(
                  onPressed: () => _sendFEC(context),
                  child: const Text("Send FEC Request"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _uploadFaceForCompare() async {
    _isF2F = true;
    final imagePath = await Au10tix.getImageFromGallery();
    print(imagePath);
    final Map<String, dynamic> jsonData = json.decode(_authToken);
    final List<dynamic> assets = jsonData['response']['assets'];

    final asset = assets.firstWhere((asset) => asset['type'] == 'ff2');
    final sasToken = asset['sasTokenUri'];
    uploadFile(sasToken, imagePath!);
  }

  Future<void> uploadFile(String? sasToken, String filePath) async {
    if (sasToken == null) {
      return;
    }

    try {
      final File file = File(filePath);
      final int fileLength = await file.length();
      final Stream<List<int>> fileStream = file.openRead();

      final dio = Dio();
      final response = await dio.put(
        sasToken,
        data: fileStream,
        options: Options(
          headers: {
            'x-ms-blob-type': 'BlockBlob',
            'Content-Length': fileLength.toString(),
            'Content-Type': 'application/octet-stream',
          },
        ),
      );

      print('uploadFile response code: ${response.statusCode}');
    } catch (e) {
      print('Error uploading file: $e');
    }
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
