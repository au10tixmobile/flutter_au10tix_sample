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
  static const String _authToken =
      'eyJraWQiOiJhelE4LVF5ZzZmTVdxZnZoUnpyX1VVUVB2aEdmSkVob0ZiZjd2SzVMcGxFIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULmdtMkY3YWFRa2ZUcDgyMnJ3UmtEcE16enR1RklDcmRFWmFCX1oxNENocTQiLCJpc3MiOiJodHRwczovL2xvZ2luLmF1MTB0aXguY29tL29hdXRoMi9hdXMzbWx0czVzYmU5V0Q4VjM1NyIsImF1ZCI6ImF1MTB0aXgiLCJpYXQiOjE2NzMzNTQwMjQsImV4cCI6MTY3MzQ0MDQyNCwiY2lkIjoiMG9hM25yNGI5Ym12NjBuQWUzNTciLCJzY3AiOlsib2NzL3Njb3BlOm1vYmlsZXNkayIsInNkYyIsInBmbCIsIm1vYmlsZXNkayJdLCJnbG9iYWxBcGlVcmwiOiJodHRwczovL3dldS1jbS1hcGltLWRldi5henVyZS1hcGkubmV0Iiwic3ViIjoiMG9hM25yNGI5Ym12NjBuQWUzNTciLCJhcGlVcmwiOiJodHRwczovL3dldS1jbS1hcGltLWRldi5henVyZS1hcGkubmV0IiwiYm9zVXJsIjoiaHR0cHM6Ly9ib3Mtd2ViLmF1MTB0aXhzZXJ2aWNlc2Rldi5jb20iLCJjbGllbnRPcmdhbml6YXRpb25OYW1lIjoiQVUxMHRUSVgiLCJjbGllbnRPcmdhbml6YXRpb25JZCI6IjMyNiJ9.IsGTLOj_P9Qg644V6AoLB7l5MDI2cio4VWzOC7J7XS13AXWTid8gjZ1mvUP93VFyewBfCvaQ1YYYyN-vzU5HHkysgj1rSA4zb5Xo4QZWolMRS2OlLUM5jY5eBzNSxSUHukWlzPsNarsiorvUtNrkRKJyCVgSVSYcfSwcMx3w0avBUIl109HfDxeOnSRDI424QxX97BFpVarlJT1QCAUiL-Iu-qgdF_mE7qZbHFmQV0HELD0RLppWmqN1geKJLBVLxlc_g83O-f5ek5WGu2Cj-PkdlGyJWidVF7Qeq-ABbBsGLo0LQvHjA9ktam-S6TFGp6FXCq8RjoVfaFcLKelcNw';

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
