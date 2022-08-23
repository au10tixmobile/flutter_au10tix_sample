// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdk_core_flutter/sdk_core_flutter.dart';
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
      'eyJraWQiOiJTUWhzTHV4SGdtdjd5cEk3TXRWbW9icGxPNEhSRVJVRzU4ZmMycjI1dFVvIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULmR6dTlUd1hoOTdGdFNoNmliVTZLV2tNM24ySDd1NlhRT2RZTXRfOTdFUEUiLCJpc3MiOiJodHRwczovL2xvZ2luLmF1MTB0aXguY29tL29hdXRoMi9hdXMzbWx0czVzYmU5V0Q4VjM1NyIsImF1ZCI6ImF1MTB0aXgiLCJpYXQiOjE2NTk4NzQ1MzAsImV4cCI6MTY1OTk2MDkzMCwiY2lkIjoiMG9hM25yNGI5Ym12NjBuQWUzNTciLCJzY3AiOlsib2NzL3Njb3BlOm1vYmlsZXNkayIsInNkYyIsInBmbCIsIm1vYmlsZXNkayJdLCJnbG9iYWxBcGlVcmwiOiJodHRwczovL3dldS1jbS1hcGltLWRldi5henVyZS1hcGkubmV0Iiwic3ViIjoiMG9hM25yNGI5Ym12NjBuQWUzNTciLCJhcGlVcmwiOiJodHRwczovL3dldS1jbS1hcGltLWRldi5henVyZS1hcGkubmV0IiwiYm9zVXJsIjoiaHR0cHM6Ly9ib3Mtd2ViLmF1MTB0aXhzZXJ2aWNlc2Rldi5jb20iLCJjbGllbnRPcmdhbml6YXRpb25OYW1lIjoiQVUxMHRUSVgiLCJjbGllbnRPcmdhbml6YXRpb25JZCI6IjMyNiJ9.NhQPCidI5deoHmfgbyj1XkYqYN125PgA81Vf1YanlW6nFd2v6wvt-YzUbiN09db_HYJD8aGT61zraoU208SvR5FjvAMyD4UfSDgKQcVr-cZ6R8WlNZYaOGhxxPskQSEpR-xU1OuE2RtZTPrUmJmoHyPy_SIGEhuCkd3uY68lQJys5DFKvCdG0wdU-twQ5_AkDtmWRONsL3kiNaX93e8dsxm94_YA665YSrqKtsmTT-_pE1OnGiNttRPIQyNKl8pVcVmfKzHHzLdWFcEbIikwon3s9JEhyvFUB2cIAW9c3J2P2vWibJOPbM-r1BfPljiP7wUNbohcgtYLhxakd6JpPA';

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
              onPressed: () =>
                  Navigator.of(context).pushNamed(PFLPage.routeName),
              child: const Text("Start PFL"),
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
