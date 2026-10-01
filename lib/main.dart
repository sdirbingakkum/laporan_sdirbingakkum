import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  if (config.isConfigured) {
    await Supabase.initialize(
      url: config.supabaseUrl!,
      publishableKey: config.supabasePublishableKey!,
    );
  }

  runApp(
    const ProviderScope(
      child: LaporanSdirbinGakkumApp(),
    ),
  );

  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }
}
