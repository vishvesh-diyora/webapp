/// Firebase Remote Config keys for the **exported website** (not the Flutter builder app).
abstract final class ExportRemoteConfigKeys {
  static const adminUsername = 'admin_username';
  static const adminPassword = 'admin_password';
  static const siteDataUrl = 'site_data_url';

  static const githubOwner = 'github_owner';
  static const githubRepo = 'github_repo';
  static const githubBranch = 'github_branch';
  static const githubToken = 'github_token';
  static const githubSiteJsonPath = 'github_site_json_path';
  static const githubMediaFolder = 'github_media_folder';

  static const loginKeys = [adminUsername, adminPassword];

  static const githubKeys = [
    githubOwner,
    githubRepo,
    githubBranch,
    githubToken,
    githubSiteJsonPath,
    githubMediaFolder,
  ];

  static const allKeys = [
    ...loginKeys,
    siteDataUrl,
    ...githubKeys,
  ];
}
