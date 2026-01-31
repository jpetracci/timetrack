import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/settings_storage.dart';
import 'settings_state.dart';

class SettingsController extends Notifier<SettingsState> {
  SettingsStorage get _storage => ref.read(settingsStorageProvider);

  @override
  SettingsState build() {
    return SettingsState.initial();
  }

  Future<void> hydrate() async {
    final int? stored = await _storage.loadPrecision();
    if (stored == null) {
      return;
    }
    final int clamped = SettingsState.clampPrecision(stored);
    state = state.copyWith(precision: clamped);
  }

  Future<void> setPrecision(int value) async {
    final int clamped = SettingsState.clampPrecision(value);
    if (clamped == state.precision) {
      return;
    }
    state = state.copyWith(precision: clamped);
    await _storage.savePrecision(clamped);
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(
  SettingsController.new,
);
