// ignore_for_file: use_key_in_widget_constructors

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sdk_sdc_flutter/sdk_sdc_flutter.dart';
import 'package:sdk_pfl_flutter/sdk_pfl_flutter.dart';
import 'package:sdk_nfc_flutter/sdk_nfc_flutter.dart';
import 'package:sdk_vc_flutter/sdk_vc_flutter.dart';
import './pfl_page.dart';
import './sdc_page.dart';
import './poa_page.dart';
import 'ui_toggle_button_widget.dart';
import 'screens/home_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Au10tix Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
      routes: {
        '/hub': (ctx) => HomePage(),
        PFLPage.routeName: (ctx) => PFLPage(),
        SDCPage.routeName: (ctx) => SDCPage(),
        POAPage.routeName: (ctx) => POAPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // UI component config
  dynamic _sdcUIResult;
  bool _showCloseBtn = true;
  bool _showPrimaryBtn = true;
  bool _showUploadBtn = true;
  bool _showIntro = true;

  // PFL options
  bool _isF2F = false;
  bool _enableMicrophone = true;

  // Suspicious behavior
  bool _enableSuspiciousBehavior = true;

  // Local SDC
  bool _useLocalSDC = false;
  bool _isDownloadingModels = false;
  bool _isDeletingModels = false;
  bool _isWarmingUp = false;

  // NFC options
  bool _nfcIsID = false;
  NFCScannerType _nfcScannerType = NFCScannerType.mrz;

  // Voice Consent options
  bool _vcShowConsent = false;
  double _vcSessionTime = 20.0;
  final _vcConsentTextController = TextEditingController(
    text: 'I agree to provide my voice consent for verification purposes.',
  );

  // Video Session options
  bool _vsShowConsent = false;
  double _vsSelfieDuration = 7.0;
  double _vsIdDuration = 5.0;
  final _vsConsentTextController = TextEditingController(
    text: 'I consent to this video session for verification purposes.',
  );

  // ID Thickness options
  bool _idtShowConsent = false;
  double _idtFrontDuration = 8.0;
  double _idtBackDuration = 8.0;
  double _idtTiltedDuration = 8.0;
  double _idtInstructionsDuration = 3.0;
  final _idtConsentTextController = TextEditingController(
    text: 'I consent to capture images of my ID for thickness verification.',
  );


  @override
  void dispose() {
    _vcConsentTextController.dispose();
    _vsConsentTextController.dispose();
    _idtConsentTextController.dispose();
    super.dispose();
  }

  SuspiciousBehaviorConfig? get _suspiciousBehaviorConfig =>
      _enableSuspiciousBehavior ? SuspiciousBehaviorConfig() : null;

  // ── SDK Core ────────────────────────────────────────────────────

  Future<void> _processWorkflow() async {
    try {
      final result = await Au10tix.sendWorkflowRequest();
      if (!mounted) return;
      if (result.containsKey("beKit")) {
        _showToast(context, result["beKit"].toString(), Colors.green);
        if (kDebugMode) print(result["beKit"].toString());
      }
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showToast(context, error.message!, Colors.red);
    } catch (_) {}
  }

  Future<void> _sendFEC() async {
    try {
      final result = await SdkSdcFlutter.performFEC(
          _sdcUIResult['sdc']['croppedFilePath']);
      if (!mounted) return;
      if (result.containsKey("fec")) {
        if (kDebugMode) print(result["fec"].toString());
        _showToast(
            context,
            'FEC Result = ${result["fec"]["classificationResult"].toString()}',
            Colors.green);
      }
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showToast(context, error.message!, Colors.red);
    } catch (_) {}
  }

  Future<void> _uploadFaceForCompare() async {
    _isF2F = true;
    final imagePath = await Au10tix.getImageFromGallery();
    if (!mounted) return;
    await Au10tix.updatePhotoForComparison(imagePath!);
    if (!mounted) return;
    _showToast(context, 'PROCEED WITH PFL', Colors.green);
  }

  // ── PFL ─────────────────────────────────────────────────────────

  Future<void> _startPFLUI() async {
    await [Permission.camera, Permission.microphone].request();
    if (!await Permission.camera.isGranted) return;
    try {
      final uiConfig = UIConfig(
        showIntroScreen: _showIntro,
        showCloseButton: _showCloseBtn,
        showPrimaryButton: _showPrimaryBtn,
      );
      final result = await SdkPflFlutter.startPFLUI(
        uiConfig: uiConfig,
        isF2F: _isF2F,
        enableMicrophone: _enableMicrophone,
        suspiciousBehaviorConfig: _suspiciousBehaviorConfig,
      );
      if (kDebugMode) print(result.toString());
    } on PlatformException catch (error) {
      if (kDebugMode) print(error.message);
    }
  }

  // ── SDC ─────────────────────────────────────────────────────────

  Future<void> _startSDCUI({bool isFrontSide = true}) async {
    try {
      final uiConfig = UIConfig(
          showIntroScreen: _showIntro,
          showCloseButton: _showCloseBtn,
          showPrimaryButton: _showPrimaryBtn,
          canUpload: _showUploadBtn);
      _sdcUIResult = await SdkSdcFlutter.startSDCUI(
        uiConfig: uiConfig,
        isFrontSide: isFrontSide,
        localClassification: _useLocalSDC,
        suspiciousBehaviorConfig: _suspiciousBehaviorConfig,
      );
      if (kDebugMode) print(_sdcUIResult.toString());
    } on PlatformException catch (error) {
      if (kDebugMode) print(error.message);
    }
  }

  Future<void> _startPOAUI() async {
    try {
      final uiConfig = UIConfig(
          showIntroScreen: _showIntro,
          showCloseButton: _showCloseBtn,
          showPrimaryButton: _showPrimaryBtn,
          canUpload: _showUploadBtn);
      final result = await SdkSdcFlutter.startPOAUI(uiConfig: uiConfig);
      if (kDebugMode) print(result.toString());
    } on PlatformException catch (error) {
      if (kDebugMode) print(error.message);
    }
  }

  // ── Local SDC ───────────────────────────────────────────────────

  Future<void> _downloadLocalSDCModels() async {
    setState(() => _isDownloadingModels = true);
    try {
      await SdkSdcFlutter.downloadModels();
      if (!mounted) return;
      _showToast(context, 'Local SDC models downloaded', Colors.green);
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showToast(context, error.message ?? 'Failed to download models', Colors.red);
    } catch (_) {
      if (!mounted) return;
      _showToast(context, 'Failed to download models', Colors.red);
    } finally {
      if (mounted) setState(() => _isDownloadingModels = false);
    }
  }

  Future<void> _deleteLocalSDCModels() async {
    setState(() => _isDeletingModels = true);
    try {
      await SdkSdcFlutter.deleteModels();
      if (!mounted) return;
      _showToast(context, 'Local SDC models deleted', Colors.green);
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showToast(context, error.message ?? 'Failed to delete models', Colors.red);
    } catch (_) {
      if (!mounted) return;
      _showToast(context, 'Failed to delete models', Colors.red);
    } finally {
      if (mounted) setState(() => _isDeletingModels = false);
    }
  }

  Future<void> _warmupLocalSDC() async {
    setState(() => _isWarmingUp = true);
    try {
      await SdkSdcFlutter.warmupClassificationManager();
      if (!mounted) return;
      _showToast(context, 'Local SDC warmed up', Colors.green);
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showToast(context, error.message ?? 'Failed to warm up', Colors.red);
    } catch (_) {
      if (!mounted) return;
      _showToast(context, 'Failed to warm up', Colors.red);
    } finally {
      if (mounted) setState(() => _isWarmingUp = false);
    }
  }

  // ── NFC ─────────────────────────────────────────────────────────

  Future<void> _startNfcUI() async {
    if (!await Permission.camera.request().isGranted) return;
    try {
      final uiConfig = UIConfig(
        showIntroScreen: _showIntro,
        showCloseButton: _showCloseBtn,
        showPrimaryButton: _showPrimaryBtn,
      );
      final result = await SdkNfcFlutter.startUI(
        uiConfig: uiConfig,
        isID: _nfcIsID,
        scannerType: _nfcScannerType,
      );
      if (!mounted) return;
      if (kDebugMode) print(result.toString());
      _showToast(context, 'NFC completed', Colors.green);
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showToast(context, error.message ?? 'NFC Error', Colors.red);
    }
  }

  // ── VC / VS / ID Thickness ───────────────────────────────────────

  Future<void> _startVoiceConsent() async {
    try {
      final result = await SdkVcFlutter.startVCUI(
        vcSessionTime: _vcSessionTime,
        consentText: _vcConsentTextController.text,
        showConsent: _vcShowConsent,
      );
      if (!mounted) return;
      if (result is Map && result.containsKey('vc')) {
        _showToast(context, 'VC: ${result['vc']['videoPath']}', Colors.green);
      }
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showToast(context, error.message ?? 'Voice Consent Error', Colors.red);
    }
  }

  Future<void> _startVideoSession() async {
    try {
      final result = await SdkVcFlutter.startVideoSession(
        consentText: _vsConsentTextController.text,
        showConsent: _vsShowConsent,
        selfieDuration: _vsSelfieDuration,
        idDuration: _vsIdDuration,
      );
      if (!mounted) return;
      if (result is Map && result.containsKey('vc')) {
        _showToast(context, 'VS: ${result['vc']['videoPath'] ?? 'done'}', Colors.green);
      }
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showToast(context, error.message ?? 'Video Session Error', Colors.red);
    }
  }

  Future<void> _startIDThickness() async {
    try {
      final result = await SdkVcFlutter.startIDThickness(
        consentText: _idtConsentTextController.text,
        showConsent: _idtShowConsent,
        frontDuration: _idtFrontDuration,
        backDuration: _idtBackDuration,
        tiltedDuration: _idtTiltedDuration,
        instructionsDuration: _idtInstructionsDuration,
      );
      if (!mounted) return;
      if (result is Map && result.containsKey('vc')) {
        _showToast(context, 'IDT: ${result['vc']['videoPath'] ?? 'done'}', Colors.orange);
      }
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showToast(context, error.message ?? 'ID Thickness Error', Colors.red);
    }
  }

  // ── UI helpers ───────────────────────────────────────────────────

  void onUIToggleButtonChanged(int index, bool isSelected) {
    switch (index) {
      case 0: _showCloseBtn = isSelected; break;
      case 1: _showPrimaryBtn = isSelected; break;
      case 2: _showUploadBtn = isSelected; break;
      case 3: _showIntro = isSelected; break;
    }
  }

  Future<void> uploadFile(String? sasToken, String filePath) async {
    if (sasToken == null) return;
    try {
      final file = File(filePath);
      final fileLength = await file.length();
      final fileStream = file.openRead();
      final dio = Dio();
      final response = await dio.put(
        sasToken,
        data: fileStream,
        options: Options(headers: {
          'x-ms-blob-type': 'BlockBlob',
          'Content-Length': fileLength.toString(),
          'Content-Type': 'application/octet-stream',
        }),
      );
      if (kDebugMode) print('uploadFile: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('uploadFile error: $e');
    }
  }

  // ── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Au10tix Flutter Plugin Example App')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildNavigationCard(context),
              const SizedBox(height: 20),
              _buildUIComponentsCard(),
              const SizedBox(height: 20),
              _buildNfcCard(),
              const SizedBox(height: 20),
              _buildVoiceConsentCard(),
              const SizedBox(height: 20),
              _buildVideoSessionCard(),
              const SizedBox(height: 20),
              _buildIDThicknessCard(),
              const SizedBox(height: 20),
              _buildActionsCard(context),
              const SizedBox(height: 20),
              _buildLocalSDCCard(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Cards ────────────────────────────────────────────────────────

  Widget _buildNavigationCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Navigation Pages'),
            const SizedBox(height: 16),
            _rowButtons([
              _btn('SDC – Front', () => Navigator.of(context).pushNamed(SDCPage.routeName, arguments: {"isFrontSide": true, "enableSuspiciousBehavior": _enableSuspiciousBehavior})),
              _btn('SDC – Back', () => Navigator.of(context).pushNamed(SDCPage.routeName, arguments: {"isFrontSide": false, "enableSuspiciousBehavior": _enableSuspiciousBehavior})),
            ]),
            const SizedBox(height: 12),
            _rowButtons([
              _btn('PFL', () => Navigator.of(context).pushNamed(PFLPage.routeName, arguments: {"isF2F": _isF2F, "enableMicrophone": _enableMicrophone, "enableSuspiciousBehavior": _enableSuspiciousBehavior})),
              _btn('POA', () => Navigator.of(context).pushNamed(POAPage.routeName)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildUIComponentsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('UI Components'),
            const SizedBox(height: 16),
            _rowButtons([
              _btn('SDC UI – Front', () => _startSDCUI()),
              _btn('SDC UI – Back', () => _startSDCUI(isFrontSide: false)),
            ]),
            const SizedBox(height: 12),
            _rowButtons([
              _btn('PFL UI', _startPFLUI),
              _btn('POA UI', _startPOAUI),
            ]),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Suspicious Behavior Detection'),
              value: _enableSuspiciousBehavior,
              dense: true,
              onChanged: (val) => setState(() => _enableSuspiciousBehavior = val),
            ),
            SwitchListTile(
              title: const Text('Enable Microphone (PFL)'),
              value: _enableMicrophone,
              dense: true,
              onChanged: (val) => setState(() => _enableMicrophone = val),
            ),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: UIToggleButtonsWidget(onToggle: onUIToggleButtonChanged),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNfcCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('NFC'),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Is ID (vs Passport)'),
              value: _nfcIsID,
              dense: true,
              onChanged: (val) => setState(() => _nfcIsID = val),
            ),
            const SizedBox(height: 8),
            const Text('Scanner Type', style: TextStyle(fontWeight: FontWeight.w500)),
            RadioGroup<NFCScannerType>(
              groupValue: _nfcScannerType,
              onChanged: (val) => setState(() => _nfcScannerType = val!),
              child: Row(
                children: [
                  Expanded(
                    child: RadioListTile<NFCScannerType>(
                      title: const Text('MRZ'),
                      value: NFCScannerType.mrz,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<NFCScannerType>(
                      title: const Text('SDC'),
                      value: NFCScannerType.sdc,
                      dense: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startNfcUI,
                child: const Text('Start NFC UI'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceConsentCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Voice Consent'),
            const SizedBox(height: 16),
            TextField(
              controller: _vcConsentTextController,
              decoration: const InputDecoration(
                labelText: 'Consent Text',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            SwitchListTile(
              title: const Text('Show Consent'),
              value: _vcShowConsent,
              dense: true,
              onChanged: (val) => setState(() => _vcShowConsent = val),
            ),
            Text('Session Duration: ${_vcSessionTime.toInt()}s  (5–30)'),
            Slider(
              value: _vcSessionTime,
              min: 5, max: 30, divisions: 25,
              label: '${_vcSessionTime.toInt()}s',
              onChanged: (val) => setState(() => _vcSessionTime = val),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startVoiceConsent,
                child: const Text('Start Voice Consent'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSessionCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Video Session'),
            const SizedBox(height: 16),
            TextField(
              controller: _vsConsentTextController,
              decoration: const InputDecoration(
                labelText: 'Consent Text',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            SwitchListTile(
              title: const Text('Show Consent'),
              value: _vsShowConsent,
              dense: true,
              onChanged: (val) => setState(() => _vsShowConsent = val),
            ),
            Text('Selfie Duration: ${_vsSelfieDuration.toInt()}s  (4–30)'),
            Slider(
              value: _vsSelfieDuration,
              min: 4, max: 30, divisions: 26,
              label: '${_vsSelfieDuration.toInt()}s',
              onChanged: (val) => setState(() => _vsSelfieDuration = val),
            ),
            Text('ID Duration: ${_vsIdDuration.toInt()}s  (4–30)'),
            Slider(
              value: _vsIdDuration,
              min: 4, max: 30, divisions: 26,
              label: '${_vsIdDuration.toInt()}s',
              onChanged: (val) => setState(() => _vsIdDuration = val),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startVideoSession,
                child: const Text('Start Video Session'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIDThicknessCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('ID Thickness'),
            const SizedBox(height: 16),
            TextField(
              controller: _idtConsentTextController,
              decoration: const InputDecoration(
                labelText: 'Consent Text',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            SwitchListTile(
              title: const Text('Show Consent'),
              value: _idtShowConsent,
              dense: true,
              onChanged: (val) => setState(() => _idtShowConsent = val),
            ),
            Text('Front: ${_idtFrontDuration.toInt()}s  (1–15)'),
            Slider(value: _idtFrontDuration, min: 1, max: 15, divisions: 14, label: '${_idtFrontDuration.toInt()}s', onChanged: (v) => setState(() => _idtFrontDuration = v)),
            Text('Back: ${_idtBackDuration.toInt()}s  (1–15)'),
            Slider(value: _idtBackDuration, min: 1, max: 15, divisions: 14, label: '${_idtBackDuration.toInt()}s', onChanged: (v) => setState(() => _idtBackDuration = v)),
            Text('Tilted: ${_idtTiltedDuration.toInt()}s  (1–15)'),
            Slider(value: _idtTiltedDuration, min: 1, max: 15, divisions: 14, label: '${_idtTiltedDuration.toInt()}s', onChanged: (v) => setState(() => _idtTiltedDuration = v)),
            Text('Instructions: ${_idtInstructionsDuration.toInt()}s  (1–6)'),
            Slider(value: _idtInstructionsDuration, min: 1, max: 6, divisions: 5, label: '${_idtInstructionsDuration.toInt()}s', onChanged: (v) => setState(() => _idtInstructionsDuration = v)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startIDThickness,
                child: const Text('Start ID Thickness'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Actions'),
            const SizedBox(height: 16),
            _rowButtons([
              _btn('Process Workflow', _processWorkflow),
              _btn('Send FEC', _sendFEC),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _uploadFaceForCompare,
                child: const Text('F2F Image Upload'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalSDCCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Local SDC'),
            const SizedBox(height: 16),
            _rowButtons([
              _loadingBtn('Download Models', _isDownloadingModels, _downloadLocalSDCModels),
              _loadingBtn('Delete Models', _isDeletingModels, _deleteLocalSDCModels),
            ]),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _loadingBtn('Warmup', _isWarmingUp, _warmupLocalSDC)),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Use Locally'),
                      Switch(
                        value: _useLocalSDC,
                        onChanged: (val) => setState(() => _useLocalSDC = val),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Widget helpers ───────────────────────────────────────────────

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );

  Widget _rowButtons(List<Widget> buttons) => Row(
        children: buttons
            .expand((b) => [Expanded(child: b), const SizedBox(width: 12)])
            .toList()
          ..removeLast(),
      );

  Widget _btn(String label, VoidCallback onPressed) => ElevatedButton(
        onPressed: onPressed,
        child: Text(label, textAlign: TextAlign.center),
      );

  Widget _loadingBtn(String label, bool loading, VoidCallback onPressed) =>
      ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                height: 18, width: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
            : Text(label, textAlign: TextAlign.center),
      );
}

void _showToast(BuildContext context, String message, Color bgColor) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: bgColor),
  );
}
