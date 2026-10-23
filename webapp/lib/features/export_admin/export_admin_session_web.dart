import 'package:web/web.dart' as web;

const _key = 'export_site_admin_session_v1';

bool exportAdminIsLoggedIn() => web.window.sessionStorage.getItem(_key) == '1';

void exportAdminSetLoggedIn(bool value) {
  if (value) {
    web.window.sessionStorage.setItem(_key, '1');
  } else {
    web.window.sessionStorage.removeItem(_key);
  }
}
