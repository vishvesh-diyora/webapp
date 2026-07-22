import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webapp/core/config/cloudflare_config.dart';
import 'package:webapp/core/utils/web_url_cleaner.dart';
import 'package:webapp/features/cloudflare/data/cloudflare_token_storage.dart';
import 'package:webapp/features/cloudflare/domain/entities/cloudflare_tokens.dart';

class CloudflareOAuthException implements Exception {
  CloudflareOAuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Authorization Code + PKCE against Cloudflare's official OAuth endpoints.
class CloudflareOAuthService {
  CloudflareOAuthService({
    CloudflareTokenStorage? tokenStorage,
    http.Client? client,
  })  : _tokenStorage = tokenStorage ?? CloudflareTokenStorage(),
        _client = client ?? http.Client();

  static const _verifierKey = 'cf_oauth_pkce_verifier';
  static const _stateKey = 'cf_oauth_state';

  final CloudflareTokenStorage _tokenStorage;
  final http.Client _client;

  Completer<CloudflareTokens>? _webCompleter;

  Future<bool> isConnected() => _tokenStorage.hasTokens();

  Future<CloudflareTokens?> readTokens() => _tokenStorage.read();

  Future<void> disconnect() async {
    final tokens = await _tokenStorage.read();
    if (tokens != null) {
      try {
        await _client.post(
          Uri.parse(CloudflareConfig.revokeEndpoint),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'client_id': CloudflareConfig.clientId,
            'token': tokens.accessToken,
          },
        );
      } catch (_) {
        // Best-effort revoke.
      }
    }
    await _tokenStorage.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_verifierKey);
    await prefs.remove(_stateKey);
  }

  /// Starts OAuth. On mobile returns when callback completes; on web the page reloads.
  Future<CloudflareTokens> connect() async {
    CloudflareConfig.assertConfigured();

    final verifier = _generateCodeVerifier();
    final challenge = _codeChallengeS256(verifier);
    final state = '${CloudflareConfig.oauthStatePrefix}${_randomString(24)}';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_verifierKey, verifier);
    await prefs.setString(_stateKey, state);

    final authUri = Uri.parse(CloudflareConfig.authorizationEndpoint).replace(
      queryParameters: {
        'client_id': CloudflareConfig.clientId,
        'redirect_uri': CloudflareConfig.redirectUri(),
        'response_type': 'code',
        'scope': CloudflareConfig.scopes,
        'state': state,
        'code_challenge': challenge,
        'code_challenge_method': 'S256',
      },
    );

    if (kIsWeb) {
      _webCompleter = Completer<CloudflareTokens>();
      final launched = await launchUrl(authUri, webOnlyWindowName: '_self');
      if (!launched) {
        throw CloudflareOAuthException('Could not open Cloudflare authorization page.');
      }
      return _webCompleter!.future;
    }

    final result = await FlutterWebAuth2.authenticate(
      url: authUri.toString(),
      callbackUrlScheme: Uri.parse(CloudflareConfig.redirectUri()).scheme,
    );

    final callbackUri = Uri.parse(result);
    return _exchangeAuthorizationResponse(callbackUri);
  }

  /// Call on app startup when the browser returns with ?code=…&state=cf_oauth_….
  Future<CloudflareTokens?> completeWebCallbackIfPresent() async {
    if (!kIsWeb) return null;

    final uri = Uri.base;
    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];
    if (code == null || state == null || !state.startsWith(CloudflareConfig.oauthStatePrefix)) {
      return null;
    }

    final tokens = await _exchangeAuthorizationResponse(uri);
    _webCompleter?.complete(tokens);
    _webCompleter = null;
    return tokens;
  }

  Future<CloudflareTokens> getValidAccessToken() async {
    var tokens = await _tokenStorage.read();
    if (tokens == null) {
      throw CloudflareOAuthException('Connect Cloudflare before publishing.');
    }
    if (!tokens.isExpired) return tokens;

    if (tokens.refreshToken == null || tokens.refreshToken!.isEmpty) {
      throw CloudflareOAuthException('Cloudflare session expired. Connect again.');
    }

    tokens = await _refresh(tokens);
    await _tokenStorage.write(tokens);
    return tokens;
  }

  Future<CloudflareTokens> _exchangeAuthorizationResponse(Uri uri) async {
    final error = uri.queryParameters['error'];
    if (error != null) {
      throw CloudflareOAuthException(
        uri.queryParameters['error_description'] ?? error,
      );
    }

    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];
    if (code == null || state == null) {
      throw CloudflareOAuthException('Cloudflare authorization response missing code.');
    }

    final prefs = await SharedPreferences.getInstance();
    final expectedState = prefs.getString(_stateKey);
    if (expectedState != null && expectedState != state) {
      throw CloudflareOAuthException('OAuth state mismatch. Try connecting again.');
    }

    final verifier = prefs.getString(_verifierKey);
    if (verifier == null || verifier.isEmpty) {
      throw CloudflareOAuthException('OAuth session expired. Connect again.');
    }

    final tokens = await _exchangeCode(code, verifier);
    await _tokenStorage.write(tokens);
    await prefs.remove(_verifierKey);
    await prefs.remove(_stateKey);
    stripCloudflareOAuthParams();
    return tokens;
  }

  Future<CloudflareTokens> _exchangeCode(String code, String verifier) async {
    final response = await _client.post(
      Uri.parse(CloudflareConfig.tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'client_id': CloudflareConfig.clientId,
        'code': code,
        'redirect_uri': CloudflareConfig.redirectUri(),
        'code_verifier': verifier,
      },
    );

    return _parseTokenResponse(response);
  }

  Future<CloudflareTokens> _refresh(CloudflareTokens current) async {
    final response = await _client.post(
      Uri.parse(CloudflareConfig.tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'client_id': CloudflareConfig.clientId,
        'refresh_token': current.refreshToken!,
      },
    );

    final refreshed = _parseTokenResponse(response);
    return refreshed.copyWith(
      refreshToken: refreshed.refreshToken ?? current.refreshToken,
      accountId: refreshed.accountId ?? current.accountId,
    );
  }

  CloudflareTokens _parseTokenResponse(http.Response response) {
    Map<String, dynamic> body;
    try {
      body = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    } catch (_) {
      throw CloudflareOAuthException('Invalid token response from Cloudflare.');
    }

    if (response.statusCode >= 400 || body['error'] != null) {
      final message = body['error_description'] as String? ??
          body['error'] as String? ??
          'Token request failed (${response.statusCode}).';
      throw CloudflareOAuthException(message);
    }

    final accessToken = body['access_token'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw CloudflareOAuthException('Cloudflare did not return an access token.');
    }

    final expiresIn = (body['expires_in'] as num?)?.toInt();
    return CloudflareTokens(
      accessToken: accessToken,
      refreshToken: body['refresh_token'] as String?,
      expiresAt: expiresIn != null
          ? DateTime.now().add(Duration(seconds: expiresIn))
          : null,
    );
  }

  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  String _codeChallengeS256(String verifier) {
    final digest = sha256.convert(utf8.encode(verifier));
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  Future<void> updateStoredAccountId(String accountId) async {
    final tokens = await _tokenStorage.read();
    if (tokens != null) {
      await _tokenStorage.write(tokens.copyWith(accountId: accountId));
    }
  }

  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
