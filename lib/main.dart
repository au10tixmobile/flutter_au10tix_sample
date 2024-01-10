// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:sdk_core_flutter/sdk_core_flutter.dart';
import 'package:sdk_sdc_flutter/sdk_sdc_flutter.dart';
import 'package:sdk_pfl_flutter/sdk_pfl_flutter.dart';
import 'package:sdk_core_flutter/ui_config.dart';
import './pfl_page.dart';
import './sdc_page.dart';
import './poa_page.dart';

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
      'eyJraWQiOiJSYW1XZlpMc3VZdVFwMzUzRV9ETmRQWWo0YnphUEhyT2JGLWNVMm9uSktNIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULk1UZnFqaW9NYTF4LTdUSzVVRGlRQ21VS1ltSXJBeEQ4Z0FDLXFKZjBCQWMiLCJpc3MiOiJodHRwczovL2xvZ2luLmF1MTB0aXguY29tL29hdXRoMi9hdXMzbWx0czVzYmU5V0Q4VjM1NyIsImF1ZCI6ImF1MTB0aXgiLCJpYXQiOjE3MDQ4ODcwNzEsImV4cCI6MTcwNDkwMTQ3MSwiY2lkIjoiMG9hOW5wdmxyOVduWWVaY2gzNTciLCJzY3AiOlsib2NzL3Njb3BlOm1vYmlsZXNkayIsInNkYyIsImRvY3JlcGxheSIsImZlYyIsInBmbCIsIm1vYmlsZXNkayJdLCJzdWIiOiIwb2E5bnB2bHI5V25ZZVpjaDM1NyIsImFwaVVybCI6Imh0dHBzOi8vYXBpLXdldS5hdTEwdGl4c2VydmljZXNxYS5jb20iLCJib3NVcmwiOiJodHRwczovL2Jvcy13ZWIuYXUxMHRpeHNlcnZpY2VzcWEuY29tIiwiY2xpZW50T3JnYW5pemF0aW9uTmFtZSI6IkRldl9UZXN0IiwiY2xpZW50T3JnYW5pemF0aW9uSWQiOjQ3OH0.j3LsgTWHwS_zI40IlIN1hJNEPY0QztSimDlFcL2H-GoEx6NZmf9tq9ZnTHymFiJGbBxhU4dJGb9Pj2PzdbfziJKH71uNM7cbyrud7KQfXq-iUt8q39kMAlWpwd6O7pciQGQInDsCWLnNjh-xNDKGo9rKBlLD1jT4nNL_0q2fZ2d6SRfO98DXNinm2gX-z0PnjG2EAv07fZsth_cX25WTogoJKzWGkfjShibZbYckniQGIZzLBZtHdsyFHYry_hKWa8VA2ghKXjsIfw_6uO9Wn7rMdWLXOY6aUTJe3iexvKk953nkd9h8VsCL4zN-Fn1qVzJJ_70ApLSoQOOfm6bwfA';

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
      }
    } on PlatformException catch (error) {
      _showToast(context, error.message!, Colors.red);
      // ignore: empty_catches
    } catch (error) {}
  }

  Future<void> _sendF2F(BuildContext context) async {
    final String? imagePath = await Au10tix.getImageFromGallery();
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

  Future<void> _sendPOA(BuildContext context) async {
    try {
      final result = await Au10tix.sendPOA("shai", "herman", "123 abbey rd");
      if (result.containsKey("beKit")) {
        _showToast(context, result["beKit"].toString(), Colors.green);
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
          showIntroScreen: true,
          showCloseButton: true,
          showPrimaryButton: true,
          canUpload: true);
      final result = await SdkSdcFlutter.startSDCUI(
          uiConfig: uiConfig, isFrontSide: isFrontSide);
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
      //UI config is optional
      UIConfig uiConfig = UIConfig(
          showIntroScreen: true,
          showCloseButton: true,
          showPrimaryButton: true);
      final result = await SdkPflFlutter.startPFLUI(uiConfig: uiConfig);
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
          showIntroScreen: true,
          showCloseButton: true,
          showPrimaryButton: true,
          canUpload: true);
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
            ElevatedButton(
              onPressed: () => _prepareSDK(context),
              child: const Text("Prepare SDK"),
            ),
            const Divider(
              height: 20,
              thickness: 3,
              indent: 20,
              endIndent: 20,
              color: Colors.black,
            ),
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
            const Divider(
              height: 20,
              thickness: 3,
              indent: 20,
              endIndent: 20,
              color: Colors.black,
            ),
            ElevatedButton(
              onPressed: () => _startSDCUI(),
              child: const Text("Start SDC UI - Front"),
            ),
            ElevatedButton(
              onPressed: () => _startSDCUI(isFrontSide: false),
              child: const Text("Start SDC UI - Back"),
            ),
            ElevatedButton(
              onPressed: () => _startPFLUI(),
              child: const Text("Start PFL UI"),
            ),
            ElevatedButton(
              onPressed: () => _startPOAUI(),
              child: const Text("Start POA UI"),
            ),
            const Divider(
              height: 20,
              thickness: 3,
              indent: 20,
              endIndent: 20,
              color: Colors.black,
            ),
            ElevatedButton(
              onPressed: () => _sendIDV(context),
              child: const Text("Send IDV Request"),
            ),
            ElevatedButton(
              onPressed: () => _sendF2F(context),
              child: const Text("Send F2F Request"),
            ),
            ElevatedButton(
              onPressed: () => _sendPOA(context),
              child: const Text("Send POA Request"),
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
