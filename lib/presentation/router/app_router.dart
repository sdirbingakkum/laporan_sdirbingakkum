import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../application/providers/commander_access_context_providers.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/commander_access_context_entities.dart';
import '../pages/access_denied_page.dart';
import '../pages/commander_drilldown_page.dart';
import '../pages/comparison_page.dart';
import '../pages/criminal_offense_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/data_quality_page.dart';
import '../pages/gakkum_page.dart';
import '../pages/laka_page.dart';
import '../pages/login_page.dart';
import '../pages/laporan_hub_page.dart';
import '../pages/pomdam_page.dart';
import '../pages/provos_page.dart';
import '../pages/reports_page.dart';
import '../pages/report_input_page.dart';
import '../pages/sim_tni_page.dart';
import '../pages/violation_page.dart';
import '../pages/visual_preview_page.dart';
import '../shell/app_shell.dart';

const _visualPreviewMode = bool.fromEnvironment('VISUAL_PREVIEW', defaultValue: false);

String _initialWebLocation() {
  if (_visualPreviewMode) return '/visual-preview';
  if (!kIsWeb) return '/';

  final path = Uri.base.path;
  const githubPagesBases = [
    '/laporan_sdirbingakkum/preview/ui-animated-visual-analytics',
    '/preview/ui-animated-visual-analytics',
    '/laporan_sdirbingakkum',
  ];

  for (final base in githubPagesBases) {
    if (path == base || path == '$base/') {
      return '/';
    }

    if (path.startsWith('$base/')) {
      final route = path.substring(base.length);
      final normalized = route.length > 1 && route.endsWith('/')
          ? route.substring(0, route.length - 1)
          : route;
      return normalized.isEmpty ? '/' : normalized;
    }
  }

  const knownRoutes = {
    '/',
    '/login',
    '/access-denied',
    '/commander/drilldown',
    '/laporan',
    '/perbandingan',
    '/gakkum',
    '/pelanggaran',
    '/sim-tni',
    '/provos',
    '/laka-lalin',
    '/tindak-pidana',
    '/pomdam',
    '/reports',
    '/input-laporan',
    '/data-quality',
  };

  return knownRoutes.contains(path) ? path : '/';
}

String _loginLocationFor(Uri target) {
  return Uri(
    path: '/login',
    queryParameters: {'returnTo': target.toString()},
  ).toString();
}

String? _safeReturnPath(String? value) {
  if (value == null || value.isEmpty) return null;

  final uri = Uri.tryParse(value);
  if (uri == null || !uri.path.startsWith('/') || uri.path.startsWith('//')) {
    return null;
  }

  const allowedRoutes = {
    '/',
    '/commander/drilldown',
    '/laporan',
    '/perbandingan',
    '/gakkum',
    '/pelanggaran',
    '/sim-tni',
    '/provos',
    '/laka-lalin',
    '/tindak-pidana',
    '/pomdam',
    '/reports',
    '/input-laporan',
    '/data-quality',
  };

  return allowedRoutes.contains(uri.path) ? uri.toString() : null;
}

String? _requiredCapabilityFor(String location) {
  if (location == '/') {
    return CommanderCapabilities.viewCommanderCop;
  }

  if (location == '/commander/drilldown') {
    return CommanderCapabilities.viewCommanderCop;
  }

  if (location == '/laporan') {
    return CommanderCapabilities.viewDomainData;
  }

  if (location == '/perbandingan') {
    return CommanderCapabilities.viewCommanderCop;
  }

  if (location == '/reports') {
    return CommanderCapabilities.viewReports;
  }

  if (location == '/input-laporan') {
    return CommanderCapabilities.manageReportData;
  }

  if (location == '/data-quality') {
    return CommanderCapabilities.viewDataQuality;
  }

  if (location == '/pomdam') {
    return CommanderCapabilities.viewPomdamDirectory;
  }

  if ({
    '/gakkum',
    '/pelanggaran',
    '/sim-tni',
    '/provos',
    '/laka-lalin',
    '/tindak-pidana',
  }.contains(location)) {
    return CommanderCapabilities.viewDomainData;
  }

  return null;
}

Future<CommanderAccessContext> _readAccessContext(Ref ref) {
  return ref.read(commanderAccessContextProvider.future);
}

FutureOr<String?> _authRedirect(
  GoRouterState state,
  Ref ref,
) async {
  final authenticated =
      Supabase.instance.client.auth.currentSession != null;
  final location = state.uri.path;

  if (_visualPreviewMode) return null;

  if ({
    '/visual-preview',
    '/preview/ui-animated-visual-analytics/visual-preview',
    '/visual-preview/',
  }.contains(location)) {
    return null;
  }

  if (!authenticated && location != '/login') {
    return _loginLocationFor(state.uri);
  }

  if (!authenticated) {
    return null;
  }

  try {
    final access = await _readAccessContext(ref);

    if (location == '/access-denied') {
      return access.defaultLocation;
    }

    if (location == '/login') {
      final returnPath =
          _safeReturnPath(state.uri.queryParameters['returnTo']);
      final requestedUri = Uri.parse(returnPath ?? access.defaultLocation);
      final required = _requiredCapabilityFor(requestedUri.path);

      if (required != null && !access.hasCapability(required)) {
        return access.defaultLocation;
      }

      return requestedUri.toString();
    }

    final required = _requiredCapabilityFor(location);
    if (required != null && !access.hasCapability(required)) {
      return access.defaultLocation;
    }

    return null;
  } on AuthorizationException {
    return location == '/access-denied' ? null : '/access-denied';
  } on AppException {
    return location == '/access-denied' ? null : '/access-denied';
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRefresh = _AuthRefreshNotifier(
    Supabase.instance.client.auth.onAuthStateChange,
    onAuthStateChanged: () {
      ref.invalidate(commanderAccessContextProvider);
    },
  );
  ref.onDispose(authRefresh.dispose);

  return GoRouter(
    initialLocation: _initialWebLocation(),
    overridePlatformDefaultLocation: true,
    refreshListenable: authRefresh,
    redirect: (context, state) => _authRedirect(state, ref),
    routes: [
      GoRoute(
        path: '/visual-preview',
        builder: (context, state) => const VisualPreviewPage(),
      ),
      GoRoute(
        path: '/preview/ui-animated-visual-analytics/visual-preview',
        builder: (context, state) => const VisualPreviewPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/access-denied',
        builder: (context, state) => const AccessDeniedPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(
            location: state.uri.path,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/laporan',
            builder: (context, state) => const LaporanHubPage(),
          ),
          GoRoute(
            path: '/perbandingan',
            builder: (context, state) => const ComparisonPage(),
          ),
          GoRoute(
            path: '/commander/drilldown',
            builder: (context, state) {
              final domainCode =
                  state.uri.queryParameters['domain']?.trim() ?? '';
              final pomdamId =
                  state.uri.queryParameters['pomdamId']?.trim();
              final dimensionCode =
                  state.uri.queryParameters['dimensionCode']?.trim();
              final recordId =
                  state.uri.queryParameters['recordId']?.trim();

              return CommanderDrilldownPage(
                domainCode: domainCode,
                pomdamId: pomdamId,
                dimensionCode: dimensionCode,
                recordId: recordId,
              );
            },
          ),
          GoRoute(
            path: '/gakkum',
            builder: (context, state) => const GakkumPage(),
          ),
          GoRoute(
            path: '/pelanggaran',
            builder: (context, state) => const ViolationPage(),
          ),
          GoRoute(
            path: '/sim-tni',
            builder: (context, state) => const SimTniPage(),
          ),
          GoRoute(
            path: '/provos',
            builder: (context, state) => const ProvosPage(),
          ),
          GoRoute(
            path: '/laka-lalin',
            builder: (context, state) => const LakaPage(),
          ),
          GoRoute(
            path: '/tindak-pidana',
            builder: (context, state) => const CriminalOffensePage(),
          ),
          GoRoute(
            path: '/pomdam',
            builder: (context, state) => const PomdamPage(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsPage(),
          ),
          GoRoute(
            path: '/input-laporan',
            builder: (context, state) => const ReportInputPage(),
          ),
          GoRoute(
            path: '/data-quality',
            builder: (context, state) => const DataQualityPage(),
          ),
        ],
      ),
    ],
  );
});

final class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(
    Stream<AuthState> authStateStream, {
    required this.onAuthStateChanged,
  }) {
    _subscription = authStateStream.listen(
      (_) {
        onAuthStateChanged();
        notifyListeners();
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Supabase auth state error: $error');
      },
    );
  }

  final VoidCallback onAuthStateChanged;
  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
