import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../application/providers/commander_access_context_providers.dart';
import '../../domain/entities/commander_access_context_entities.dart';

class AppShell extends ConsumerWidget {
  const AppShell({
    required this.location,
    required this.child,
    super.key,
  });

  final String location;
  final Widget child;

  static const _items = <_NavItem>[
    _NavItem(
      path: '/',
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      capability: CommanderCapabilities.viewCommanderCop,
    ),
    _NavItem(
      path: '/gakkum',
      label: 'Gakkum',
      icon: Icons.gavel_outlined,
      selectedIcon: Icons.gavel,
      capability: CommanderCapabilities.viewDomainData,
    ),
    _NavItem(
      path: '/pelanggaran',
      label: 'Pelanggaran',
      icon: Icons.rule_outlined,
      selectedIcon: Icons.rule,
      capability: CommanderCapabilities.viewDomainData,
    ),
    _NavItem(
      path: '/sim-tni',
      label: 'SIM TNI',
      icon: Icons.badge_outlined,
      selectedIcon: Icons.badge,
      capability: CommanderCapabilities.viewDomainData,
    ),
    _NavItem(
      path: '/provos',
      label: 'Provos',
      icon: Icons.shield_outlined,
      selectedIcon: Icons.shield,
      capability: CommanderCapabilities.viewDomainData,
    ),
    _NavItem(
      path: '/laka-lalin',
      label: 'Laka Lalin',
      icon: Icons.car_crash_outlined,
      selectedIcon: Icons.car_crash,
      capability: CommanderCapabilities.viewDomainData,
    ),
    _NavItem(
      path: '/tindak-pidana',
      label: 'Tindak Pidana',
      icon: Icons.policy_outlined,
      selectedIcon: Icons.policy,
      capability: CommanderCapabilities.viewDomainData,
    ),
    _NavItem(
      path: '/pomdam',
      label: 'POMDAM',
      icon: Icons.account_balance_outlined,
      selectedIcon: Icons.account_balance,
      capability: CommanderCapabilities.viewPomdamDirectory,
    ),
    _NavItem(
      path: '/reports',
      label: 'Laporan',
      icon: Icons.description_outlined,
      selectedIcon: Icons.description,
      capability: CommanderCapabilities.viewReports,
    ),
    _NavItem(
      path: '/input-laporan',
      label: 'Input Laporan',
      icon: Icons.edit_note_outlined,
      selectedIcon: Icons.edit_note,
      capability: CommanderCapabilities.manageReportData,
    ),
    _NavItem(
      path: '/data-quality',
      label: 'Data Quality',
      icon: Icons.verified_outlined,
      selectedIcon: Icons.verified,
      capability: CommanderCapabilities.viewDataQuality,
    ),
  ];

  List<_NavItem> _visibleItems(CommanderAccessContext? access) {
    if (access == null || !access.isAuthorized) return const [];
    return [
      for (final item in _items)
        if (access.hasCapability(item.capability)) item,
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(commanderAccessContextProvider).value;
    final items = _visibleItems(access);

    if (items.isEmpty) {
      return Scaffold(body: child);
    }

    final index = _selectedIndex(items);
    final title = items[index].label;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (access?.role != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Chip(
                  avatar: const Icon(Icons.badge_outlined, size: 18),
                  label: Text(access!.role!.displayName),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          PopupMenuButton<String>(
            tooltip: 'Akun',
            onSelected: (value) async {
              if (value != 'sign_out') return;

              final client = Supabase.instance.client;
              try {
                await client.auth.signOut(scope: SignOutScope.local);
              } catch (error) {
                if (client.auth.currentSession != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        error is AuthException
                            ? error.message
                            : 'Gagal keluar. Periksa koneksi lalu coba lagi.',
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  Supabase.instance.client.auth.currentUser?.email ??
                      'Akun terautentikasi',
                ),
              ),
              if (access?.role != null)
                PopupMenuItem<String>(
                  enabled: false,
                  child: Text(
                    access!.role!.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'sign_out',
                child: Text('Keluar'),
              ),
            ],
            icon: const Icon(Icons.account_circle_outlined),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Chip(
              avatar: Icon(Icons.cloud_done_outlined, size: 18),
              label: Text('Supabase'),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 1000;

          if (desktop) {
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: index,
                  onDestinationSelected: (value) {
                    context.go(items[value].path);
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final item in items)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            );
          }

          return child;
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 1000) {
            return const SizedBox.shrink();
          }

          return NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (value) {
              context.go(items[value].path);
            },
            destinations: [
              for (final item in items)
                NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                ),
            ],
          );
        },
      ),
    );
  }

  int _selectedIndex(List<_NavItem> items) {
    if (location == '/') {
      final index = items.indexWhere((item) => item.path == '/');
      return index >= 0 ? index : 0;
    }

    final index = items.indexWhere(
      (item) => item.path != '/' && location.startsWith(item.path),
    );
    return index >= 0 ? index : 0;
  }
}

final class _NavItem {
  const _NavItem({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.capability,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String capability;
}
