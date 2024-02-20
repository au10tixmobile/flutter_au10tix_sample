// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_au10tix_sample/flow_toggle_button_widget.dart';
import 'package:sdk_core_flutter/sdk_core_flutter.dart';
import 'package:sdk_sdc_flutter/sdk_sdc_flutter.dart';
import 'package:sdk_pfl_flutter/sdk_pfl_flutter.dart';
import 'package:sdk_core_flutter/ui_config.dart';
import './pfl_page.dart';
import './sdc_page.dart';
import './poa_page.dart';
import './personal_data_dialog.dart';
import 'ui_toggle_button_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Au10tix Flutter PFL Demo',
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
  static const String _authToken =
      'eyJraWQiOiJ1Z3drcXd2V2lqUUoyZ1FrcTVjTlEyV0hKb0JPRzZaVk0xRENrZnZwbHhvIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULjhZYjFvTXFFdHhIVVhyYnpXY0k5dWhZbXZCQlhEQm9TZ2pyTzFGakRUcmciLCJpc3MiOiJodHRwczovL2xvZ2luLmF1MTB0aXguY29tL29hdXRoMi9hdXMzbWx0czVzYmU5V0Q4VjM1NyIsImF1ZCI6ImF1MTB0aXgiLCJpYXQiOjE3MDg0MjQ1MTcsImV4cCI6MTcwODQzODkxNywiY2lkIjoiMG9hOW5wdmxyOVduWWVaY2gzNTciLCJzY3AiOlsib2NzL3Njb3BlOm1vYmlsZXNkayIsInNkYyIsImZlYyIsInBmbCIsIm1vYmlsZXNkayJdLCJzdWIiOiIwb2E5bnB2bHI5V25ZZVpjaDM1NyIsImFwaVVybCI6Imh0dHBzOi8vYXBpLXdldS5hdTEwdGl4c2VydmljZXNxYS5jb20iLCJib3NVcmwiOiJodHRwczovL2Jvcy13ZWIuYXUxMHRpeHNlcnZpY2VzcWEuY29tIiwiY2xpZW50T3JnYW5pemF0aW9uTmFtZSI6IkRldl9UZXN0IiwiY2xpZW50T3JnYW5pemF0aW9uSWQiOjQ3OH0.FrkZ78D77q4qOwx6773mMfEMVq_7Hxsq8bz2e2S82BuMDz_2D_FP-SalFeuRxnq5mWuA768RkSKXQjDMXr5IE1baZpERqRVo4q-IdryPu0xENj_LLDhlZqZAMNZx80w_sEsp2uI5N6gGmsU12Rz47iOv9CVj8Wo53UevjHbWJkFIxDOrKx3K0RgsKQD823RgGNqEWVOXKSGP_tv3G1yJnOkdDZBN6_T8uQIQKzetx09qXwkvdxtBiLcXWTY626QIThDfGNhoPoec73YzXrVsSZEfMbvg_LicZBqwVRTqOqVOlQDGKtPAE08Uml401oSyrsjOBWfO16KrcmCra-FkPA';

  var _sdcUIResult;
  bool _showCloseBtn = true;
  bool _showPrimaryBtn = true;
  bool _showUploadBtn = true;
  bool _showIntro = true;
  bool _isF2F = false;

  Future<void> _prepareSDK(BuildContext context) async {
    try {
      final result = await Au10tix.init(_authToken);
      if (result.containsKey("init")) {
        _showToast(context, result["init"].toString(), Colors.green);
      }
    } on PlatformException catch (error) {
      _showToast(context, error.message!, Colors.red);
      // ignore: empty_catches
    } catch (error) {}
  }

  Future<void> _sendIDV(BuildContext context) async {
    try {
      final result = await Au10tix.sendIDV();
      if (result.containsKey("beKit")) {
        _showToast(context, result["beKit"].toString(), Colors.green);
        print(result["beKit"].toString());
      }
    } on PlatformException catch (error) {
      _showToast(context, error.message!, Colors.red);
      // ignore: empty_catches
    } catch (error) {}
  }

  Future<void> _sendF2F(BuildContext context) async {
    final String? imagePath = await Au10tix.getImageFromGallery();
    print(imagePath);
    try {
      final result = await Au10tix.sendF2F(imagePath!);
      if (result.containsKey("beKit")) {
        _showToast(context, result["beKit"].toString(), Colors.green);
      }
    } on PlatformException catch (error) {
      _showToast(context, error.message!, Colors.red);
      // ignore: empty_catches
    } catch (error) {}
  }

  Future<void> _sendPOA(BuildContext context, String firstName, String lastName,
      String address) async {
    try {
      final result = await Au10tix.sendPOA(firstName, lastName, address);
      if (result.containsKey("beKit")) {
        _showToast(context, result["beKit"].toString(), Colors.green);
      }
    } on PlatformException catch (error) {
      _showToast(context, error.message!, Colors.red);
      // ignore: empty_catches
    } catch (error) {}
  }

  void handleContinue(
      String firstName, String lastName, String address, BuildContext context) {
    _sendPOA(context, firstName, lastName, address);
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
    print("isF2f = $_isF2F");
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
    print("$index is selected $isSelected");
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

  void onFlowToggleButtonChanged(int index, bool isSelected) {
    print("$index is selected $isSelected");

    switch (index) {
      case 0:
        _isF2F = !isSelected;
        break;
      default:
        break;
    }
  }

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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _prepareSDK(context),
                  child: const Text("Prepare SDK"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlowToggleButtonsWidget(
                    onToggle: onFlowToggleButtonChanged,
                  ),
                ),
              ],
            ),
            const Divider(
              height: 20,
              thickness: 3,
              indent: 20,
              endIndent: 20,
              color: Colors.black,
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
                  onPressed: () =>
                      Navigator.of(context).pushNamed(PFLPage.routeName),
                  child: const Text("Start PFL"),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(POAPage.routeName),
                  child: const Text("Start POA"),
                ),
              ],
            ),
            const Divider(
              height: 20,
              thickness: 3,
              indent: 20,
              endIndent: 20,
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: UIToggleButtonsWidget(
                onToggle: onUIToggleButtonChanged,
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
            const Divider(
              height: 20,
              thickness: 3,
              indent: 20,
              endIndent: 20,
              color: Colors.black,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _sendIDV(context),
                  child: const Text("Send IDV Request"),
                ),
                ElevatedButton(
                  onPressed: () => _sendF2F(context),
                  child: const Text("Send F2F Request"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => {
                    showDialog(
                      context: context,
                      builder: (context) => WillPopScope(
                        onWillPop: () async => false,
                        child: PersonalDataDialog(onContinue: handleContinue),
                      ),
                    )
                  },
                  child: const Text("Send POA Request"),
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
