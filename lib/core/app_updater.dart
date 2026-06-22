import 'package:in_app_update/in_app_update.dart';

/// Checks Google Play for a newer version and, if found, downloads it in the
/// background (flexible) then prompts a restart — so users update without
/// having to do it manually. No-op when the app isn't installed from Play.
class AppUpdater {
  AppUpdater._();

  static Future<void> check() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) return;
      if (info.flexibleUpdateAllowed) {
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
      } else if (info.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (_) {
      // sideloaded / no Play / no update available — ignore silently
    }
  }
}
