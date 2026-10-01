import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  if (value == null || value.isEmpty || !value.startsWith('/') || value.startsWith('//')) {
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

String? _authRedirect(GoRouterState state) {
  final authenticated = Supabase.instance.client.auth.currentSession != null;
  final location = state.uri.path;

  if (!authenticated && location != '/login') {
    return _loginLocationFor(location);
  }

  if (authenticated && location == '/login') {
    return _safeReturnPath(state.uri.queryParameters['returnTo']) ?? '/';
  }

  return null;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRefresh = _AuthRefreshNotifier(
    Supabase.instance.client.auth.onAuthStateChange,
  );
  ref.onDispose(authRefresh.dispose);

  return GoRouter(
    initialLocation: _initialWebLocation(),
    refreshListenable: authRefresh,
    redirect: (context, state) => _authRedirect(state),
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
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
  _AuthRefreshNotifier(Stream<AuthState> authStateStream) {
    _subscription = authStateStream.listen(
      (_) => notifyListeners(),
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Supabase auth state error: $error');
      },
    );
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
