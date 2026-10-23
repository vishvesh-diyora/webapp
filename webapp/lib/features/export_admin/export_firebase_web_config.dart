import 'dart:convert';

/// Public Firebase web app settings (`firebase-config.json` on Cloudflare).
/// Does not contain admin password or GitHub token — those live in Remote Config.
class ExportFirebaseWebConfig {
  const ExportFirebaseWebConfig({
    required this.apiKey,
    required this.authDomain,
    required this.projectId,
    required this.storageBucket,
    required this.messagingSenderId,
    required this.appId,
  });

  final String apiKey;
  final String authDomain;
  final String projectId;
  final String storageBucket;
  final String messagingSenderId;
  final String appId;

  bool get isConfigured =>
      projectId.isNotEmpty &&
      !projectId.startsWith('YOUR_') &&
      apiKey.isNotEmpty &&
      !apiKey.startsWith('YOUR_') &&
      appId.isNotEmpty &&
      !appId.startsWith('YOUR_');

  factory ExportFirebaseWebConfig.fromJson(Map<String, dynamic> json) {
    return ExportFirebaseWebConfig(
      apiKey: json['apiKey'] as String? ?? '',
      authDomain: json['authDomain'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      storageBucket: json['storageBucket'] as String? ?? '',
      messagingSenderId: json['messagingSenderId'] as String? ?? '',
      appId: json['appId'] as String? ?? '',
    );
  }

  static ExportFirebaseWebConfig parse(String body) =>
      ExportFirebaseWebConfig.fromJson(jsonDecode(body) as Map<String, dynamic>);

  static Map<String, dynamic> deployTemplate() => {
        'apiKey': 'YOUR_API_KEY',
        'authDomain': 'YOUR_PROJECT_ID.firebaseapp.com',
        'projectId': 'YOUR_PROJECT_ID',
        'storageBucket': 'YOUR_PROJECT_ID.appspot.com',
        'messagingSenderId': 'YOUR_SENDER_ID',
        'appId': 'YOUR_WEB_APP_ID',
      };
}
