import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleAuthService {
  static const String _keyAccessToken = 'GMAIL_ACCESS_TOKEN';
  static const String _keyUserEmail = 'GMAIL_USER_EMAIL';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/gmail.readonly',
      'https://www.googleapis.com/auth/calendar.readonly',
    ],
  );

  String _accessToken = '';
  String _userEmail = '';

  bool get isConnected => _userEmail.isNotEmpty;
  String get userEmail => _userEmail;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_keyAccessToken) ?? '';
    _userEmail = prefs.getString(_keyUserEmail) ?? '';

    if (_userEmail.isNotEmpty) {
      try {
        final account = await _googleSignIn.signInSilently();
        if (account != null) {
          final auth = await account.authentication;
          _accessToken = auth.accessToken ?? _accessToken;
          _userEmail = account.email;
          await prefs.setString(_keyAccessToken, _accessToken);
          await prefs.setString(_keyUserEmail, _userEmail);
        }
      } catch (e) {
        debugPrint('[GoogleAuthService] Silent sign-in error: $e');
      }
    }
  }

  Future<void> clearCredentials() async {
    _accessToken = '';
    _userEmail = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyUserEmail);
    try {
      await _googleSignIn.disconnect();
    } catch (e) {
      debugPrint('[GoogleAuthService] Google Sign-In disconnect error: $e');
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }
  }

  Future<String> startOAuthFlow() async {
    try {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw Exception('Google Sign-In was cancelled by the user.');
      }

      final auth = await account.authentication;
      _accessToken = auth.accessToken ?? '';
      _userEmail = account.email;

      if (_accessToken.isEmpty) {
        throw Exception('Failed to obtain Google access token.');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAccessToken, _accessToken);
      await prefs.setString(_keyUserEmail, _userEmail);

      return _userEmail;
    } catch (e) {
      debugPrint('[GoogleAuthService] Native sign-in error: $e');
      throw Exception('Google Sign-In failed: $e');
    }
  }

  Future<String?> getAccessToken() async {
    if (_userEmail.isEmpty) return null;
    try {
      final account =
          _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
      if (account != null) {
        final auth = await account.authentication;
        if (auth.accessToken != null) {
          _accessToken = auth.accessToken!;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_keyAccessToken, _accessToken);
        }
      }
    } catch (e) {
      debugPrint('[GoogleAuthService] Error getting access token: $e');
    }
    return _accessToken.isNotEmpty ? _accessToken : null;
  }
}
