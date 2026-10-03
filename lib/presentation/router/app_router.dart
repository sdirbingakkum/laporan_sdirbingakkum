import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../application/providers/commander_access_context_providers.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/commander_access_context_entities.dart';
import '../pages/access_denied_page.dart';
import '../pages/criminal_offense_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/data_quality_page.dart';
import '../pages/gakkum_page.dart';
import '../pages/laka_page.dart';
import '../pages/login_page.dart';
import '../pages/pomdam_page.dart';
import '../pages/provos_page.dart';
import '../pages/reports_page.dart';
import '../pages/sim_tni_page.dart';
import '../pages/violation_page.dart';
import '../shell/app_shell.dart';

String _initialWebLocation() {
  if (!kIsWeb) return '/';

  final path = Uri.base.path;
  const githubPagesBase = '/laporan_sdirbingakkum';

  if (path == githubPagesBase || path == '$githubPagesBase/') {
    return '/';
  }

  if (path.startsWith('$githubPagesBase/')) {
    final route = path.substring(githubPagesBase.length);
    return route.isEmpty ? '/' : route;
  }

  const knownRoutes = {
    '/',
    '/login',
    '/access-denied',
    '/gakkum',
    '/pelanggaran',
    '/sim-tni',
    '/provos',
    '/laka-lalin',
    '/tindak-pidana',
    '/pomdam',
    '/reports',
    '/data-quality',
  };

  return knownRoutes.contains(path) ? path : '/';
}

String _loginLocationFor(String path) {
  return Uri(
    path: '/login',
    queryParameters: {'returnTo': path},
  ).toString();
}

String? _safeReturnPath(String? value) {
  if (value == null ||
      value.isEmpty ||
      !value.startsWith('/') ||
      value.startsWith('//')) {
    return null;
  }

  const allowedRoutes = {
    '/',
    '/gakkum',
    '/pelanggaran',
    '/sim-tni',
    '/provos',
    '/laka-lalin',
    '/tindak-pidana',
    '/pomdam',
    '/reports',
    '/data-quality',
  };

  return allowedRoutes.contains(value) ? value : null;
}

String? _requiredCapabilityFor(String location) {
  if (location == '/') {
    return CommanderCapabilities.viewCommanderCop;
  }

  if (location == '/reports') {
    return CommanderCapabilities.viewReports;
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

  if (!authenticated && location != '/login') {
    return _loginLocationFor(location);
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
      final requestedPath = returnPath ?? access.defaultLocation;
      final required = _requiredCapabilityFor(requestedPath);

      if (required != null && !access.hasCapability(required)) {
        return access.defaultLocation;
      }

      return requestedPath;
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
    refreshListenable: authRefresh,
    redirect: (context, state) => _authRedirect(state, ref),
    routes: [
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
