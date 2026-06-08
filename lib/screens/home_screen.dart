import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdk_core_flutter/sdk_core_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAuth = false;
  bool _isStarting = false;
  final TextEditingController _workflowController = TextEditingController();

  static const _titleColor = Color(0xFF181244);
  static const _buttonColor = Color(0xFF5189DD);
  static const _buttonDisabledColor = Color(0xFFC7D3F8);

  bool get _isStartDisabled =>
      _isAuth && (_workflowController.text.trim().isEmpty || _isStarting);

  @override
  void dispose() {
    _workflowController.dispose();
    super.dispose();
  }

  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    if (text.isNotEmpty) {
      setState(() => _workflowController.text = text);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clipboard is empty')),
      );
    }
  }

  Future<void> _handleStart() async {
    final trimmed = _workflowController.text.trim();
    if (trimmed.isEmpty) return;

    setState(() => _isStarting = true);
    try {
      await Au10tix.init(trimmed);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/hub');
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Initialization failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Initialization failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _isAuth ? _buildAuthContent() : _buildIntroContent()),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Image.asset(
        'assets/images/top_logo.png',
        width: 168,
        height: 25,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildIntroContent() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Image.asset(
              'assets/images/shield.png',
              width: 245,
              height: 245,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Column(
          children: [
            Text(
              'Flutter SDK',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _titleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sample app',
              style: TextStyle(fontSize: 16, color: _titleColor),
            ),
          ],
        ),
        const Expanded(child: SizedBox()),
      ],
    );
  }

  Widget _buildAuthContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Please paste your workflow response',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _titleColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 80, maxHeight: 320),
            child: TextField(
              controller: _workflowController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              autocorrect: false,
              textCapitalization: TextCapitalization.none,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF9F9FB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD1D1D6)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD1D1D6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD1D1D6)),
                ),
                hintText: 'Paste workflow response here...',
                hintStyle: const TextStyle(color: Color(0xFFAEAEB2)),
                contentPadding: const EdgeInsets.all(14),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _handlePaste,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 28),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Paste',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _buttonColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isStartDisabled
                  ? null
                  : (_isAuth ? _handleStart : () => setState(() => _isAuth = true)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor,
                disabledBackgroundColor: _buttonDisabledColor,
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isStarting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      _isAuth ? 'Initialize SDK' : 'Start',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Image.asset(
            'assets/images/LogoAU10TIX.jpg',
            height: 22,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
