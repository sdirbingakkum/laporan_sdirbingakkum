import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppShell extends StatelessWidget {
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
    ),
    _NavItem(
      path: '/gakkum',
      label: 'Gakkum',
      icon: Icons.gavel_outlined,
      selectedIcon: Icons.gavel,
    ),
    _NavItem(
      path: '/pelanggaran',
      label: 'Pelanggaran',
      icon: Icons.rule_outlined,
      selectedIcon: Icons.rule,
    ),
    _NavItem(
      path: '/sim-tni',
      label: 'SIM TNI',
      icon: Icons.badge_outlined,
      selectedIcon: Icons.badge,
    ),
    _NavItem(
      path: '/provos',
      label: 'Provos',
      icon: Icons.shield_outlined,
      selectedIcon: Icons.shield,
    ),
    _NavItem(
      path: '/laka-lalin',
      label: 'Laka Lalin',
      icon: Icons.car_crash_outlined,
      selectedIcon: Icons.car_crash,
    ),
    _NavItem(
      path: '/pomdam',
      label: 'POMDAM',
      icon: Icons.account_balance_outlined,
      selectedIcon: Icons.account_balance,
    ),
    _NavItem(
      path: '/reports',
      label: 'Laporan',
      icon: Icons.description_outlined,
      selectedIcon: Icons.description,
    ),
    _NavItem(
      path: '/data-quality',
      label: 'Data Quality',
      icon: Icons.verified_outlined,
      selectedIcon: Icons.verified,
    ),
  ];

  int get selectedIndex {
    if (location == '/') return 0;
    final index = _items.indexWhere(
      (item) => item.path != '/' && location.startsWith(item.path),
    );
    return index >= 0 ? index : 0;
  }

  String get title => _items[selectedIndex].label;

  @override
  Widget build(BuildContext context) {
    final index = selectedIndex;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Akun',
            onSelected: (value) async {
              if (value == 'sign_out') {
                await Supabase.instance.client.auth.signOut();
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
                    context.go(_items[value].path);
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final item in _items)
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
              context.go(_items[value].path);
            },
            destinations: [
              for (final item in _items)
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
}

final class _NavItem {
  const _NavItem({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
