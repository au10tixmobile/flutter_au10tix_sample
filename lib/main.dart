// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:sdk_core_flutter/sdk_core_flutter.dart';
import 'package:sdk_sdc_flutter/sdk_sdc_flutter.dart';
import 'package:sdk_pfl_flutter/sdk_pfl_flutter.dart';
import './pfl_page.dart';
import './sdc_page.dart';

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
      },
    );
  }
}

class HomePage extends StatelessWidget {
  static const String _authToken = '<your_jwt';

  Future<void> _prepareSDK(BuildContext context) async {
    try {
      final result = await Au10tix.init(_authToken);
      if (result.containsKey("init")) {
        _showToast(context, result["init"].toString(), Colors.green);
      }
    } on PlatformException catch (error) {
      _showToast(context, error.message!, Colors.red);
    } catch (error) {}
  }

  Future<void> _startSDCUI() async {
    try {
      final result = await SdkSdcFlutter.startSDCUI();
      if (kDebugMode) {
        print(result.toString());
      }
    } on PlatformException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
    }
  }

  Future<void> _startPFLUI() async {
    try {
      final result = await SdkPflFlutter.startPFLUI();
      if (kDebugMode) {
        print(result.toString());
      }
    } on PlatformException catch (error) {
      if (kDebugMode) {
        print(error.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Au10tix Flutter Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _prepareSDK(context),
              child: const Text("Prepare SDK"),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(SDCPage.routeName),
              child: const Text("Start SDC"),
            ),
            ElevatedButton(
              onPressed: () => _startSDCUI(),
              child: const Text("Start SDC UI"),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(PFLPage.routeName),
              child: const Text("Start PFL"),
            ),
            ElevatedButton(
              onPressed: () => _startPFLUI(),
              child: const Text("Start PFL UI"),
            ),
          ],
        ),
      ),
    );
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
}
