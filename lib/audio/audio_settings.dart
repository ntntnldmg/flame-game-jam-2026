/// App-wide audio preference shared across intro and gameplay.
class AudioSettings {
  static bool? _enabled;

  static bool get hasPreference => _enabled != null;
  static bool get isEnabled => _enabled ?? false;

  static void setEnabled(bool value) {
    _enabled = value;
  }
}
