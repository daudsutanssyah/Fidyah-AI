import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fidyah_ai/core/services/hive_storage_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final storageService = HiveStorageService();
  await storageService.init();

  runApp(
    DevicePreview(
      enabled: kIsWeb,
      builder: (context) => ProviderScope(
        overrides: [hiveStorageProvider.overrideWithValue(storageService)],
        child: const App(),
      ),
    ),
  );
}

/// Provider so it can be injected everywhere
final hiveStorageProvider = Provider<HiveStorageService>((ref) {
  throw UnimplementedError('Provider was not initialized');
});
