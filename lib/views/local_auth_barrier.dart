import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthBarrier extends StatefulWidget {
  final Widget child;

  const LocalAuthBarrier({super.key, required this.child});

  @override
  State<LocalAuthBarrier> createState() => _LocalAuthBarrierState();
}

class _LocalAuthBarrierState extends State<LocalAuthBarrier> with WidgetsBindingObserver {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;
  bool _isCheckingStatus = true; // Prevents flickers on launch
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Request authentication on startup after the widget is fully laid out
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the app goes to background (paused), we lock it.
    // Note: We use paused instead of inactive to prevent locking the app 
    // when the native biometric prompt dialog is displayed.
    if (state == AppLifecycleState.paused) {
      setState(() {
        _isAuthenticated = false;
      });
    } else if (state == AppLifecycleState.resumed) {
      if (!_isAuthenticated && !_isAuthenticating) {
        _authenticate();
      }
    }
  }

  void _showSecurityWarning() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'For your security, please configure a screen lock (PIN, pattern, passcode, or biometrics) in your device settings.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.amber[800],
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
    });

    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();

      if (!canCheck && !isSupported) {
        // Device doesn't support local auth at all
        setState(() {
          _isAuthenticated = true; // Bypass
          _isAuthenticating = false;
          _isCheckingStatus = false;
        });
        _showSecurityWarning();
        return;
      }

      final bool didAuth = await _auth.authenticate(
        localizedReason: 'Authenticate to access your AI Personal Trainer',
        biometricOnly: false, // Allow PIN, pattern, passcode
        persistAcrossBackgrounding: true, // Keep auth active on backgrounding
      );

      setState(() {
        _isAuthenticated = didAuth;
        _isAuthenticating = false;
        _isCheckingStatus = false;
        if (!didAuth) {
          _errorMessage = 'Authentication failed. Please try again.';
        }
      });
    } on LocalAuthException catch (e) {
      setState(() {
        _isAuthenticating = false;
        _isCheckingStatus = false;
        if (e.code == LocalAuthExceptionCode.noCredentialsSet) {
          _isAuthenticated = true; // Bypass
          _showSecurityWarning();
        } else {
          _errorMessage = 'Error: ${e.description ?? e.code.name}';
        }
      });
    } on PlatformException catch (e) {
      setState(() {
        _isAuthenticating = false;
        _isCheckingStatus = false;
        // If passcode is not set, we bypass
        if (e.code == 'NotAvailable' || e.code == 'PasscodeNotSet') {
          _isAuthenticated = true; 
          _showSecurityWarning();
        } else {
          _errorMessage = 'Error: ${e.message ?? e.code}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return widget.child;
    }

    if (_isCheckingStatus) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4F46E5),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Cohesive Slate 100 bg
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Lock / App Logo illustration
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.indigo.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.psychology,
                        size: 80,
                        color: Color(0xFF4F46E5),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4F46E5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_outline,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'App Locked',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'For your security, please unlock the app using your device lock pattern, PIN, or biometrics.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                if (_errorMessage.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isAuthenticating ? null : _authenticate,
                    icon: _isAuthenticating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.fingerprint, color: Colors.white),
                    label: Text(
                      _isAuthenticating ? 'Authenticating...' : 'Unlock App',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      shadowColor: Colors.indigo.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
