import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../application/providers/commander_access_context_providers.dart';
import '../../domain/entities/commander_access_context_entities.dart';
import '../theme/app_theme.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    required this.location,
    required this.child,
    super.key,
  });

  final String location;
  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _active(String path) {
    if (path == '/') return widget.location == '/';
    return widget.location == path || widget.location.startsWith('$path/');
  }

  @override
  Widget build(BuildContext context) {
    final access = ref.watch(commanderAccessContextProvider).value;
    if (access == null || !access.isAuthorized) {
      return Scaffold(body: widget.child);
    }

    final desktop = MediaQuery.sizeOf(context).width >= 980;
    final primary = _primaryItems(access);
    final selected = _selectedIndex(primary);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.canvas,
      appBar: desktop
          ? null
          : AppBar(
              title: Text(
                _currentTitle(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              leading: IconButton(
                tooltip: 'Menu',
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              actions: [
                _AccountButton(access: access),
                const SizedBox(width: 4),
              ],
            ),
      drawer: desktop
          ? null
          : Drawer(
              width: MediaQuery.sizeOf(context).width < 520
                  ? MediaQuery.sizeOf(context).width * .88
                  : 310,
              child: SafeArea(
                child: _SecondaryMenu(
                  access: access,
                  onNavigate: (path) {
                    Navigator.of(context).pop();
                    context.go(path);
                  },
                ),
              ),
            ),
      body: desktop
          ? Row(
              children: [
                _DesktopRail(
                  access: access,
                  items: primary,
                  selectedIndex: selected,
                  location: widget.location,
                  onNavigate: (path) => context.go(path),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: widget.child),
              ],
            )
          : widget.child,
      bottomNavigationBar: desktop
          ? null
          : NavigationBar(
              selectedIndex: selected,
              onDestinationSelected: (index) {
                if (index < primary.length) {
                  context.go(primary[index].path);
                } else {
                  _scaffoldKey.currentState?.openDrawer();
                }
              },
              destinations: [
                for (final item in primary)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ),
                const NavigationDestination(
                  icon: Icon(Icons.more_horiz_rounded),
                  label: 'Menu',
                ),
              ],
            ),
    );
  }

  List<_NavItem> _primaryItems(CommanderAccessContext access) {
    final items = <_NavItem>[];

    if (access.canUseCommanderDashboard) {
      items.add(
        const _NavItem(
          path: '/',
          label: 'Beranda',
          icon: Icons.grid_view_outlined,
          selectedIcon: Icons.grid_view_rounded,
        ),
      );
    }

    if (access.hasCapability(CommanderCapabilities.viewDomainData)) {
      items.add(
        const _NavItem(
          path: '/laporan',
          label: 'Laporan',
          icon: Icons.insights_outlined,
          selectedIcon: Icons.insights_rounded,
        ),
      );
    }

    if (access.canUseCommanderDashboard) {
      items.add(
        const _NavItem(
          path: '/perbandingan',
          label: 'Bandingkan',
          icon: Icons.compare_arrows_outlined,
          selectedIcon: Icons.compare_arrows_rounded,
        ),
      );
    } else if (access.hasCapability(CommanderCapabilities.manageReportData)) {
      items.add(
        const _NavItem(
          path: '/input-laporan',
          label: 'Input',
          icon: Icons.add_chart_outlined,
          selectedIcon: Icons.add_chart_rounded,
        ),
      );
    }

    return items;
  }

  int _selectedIndex(List<_NavItem> items) {
    for (var index = 0; index < items.length; index++) {
      if (_active(items[index].path)) return index;
    }
    return 0;
  }

  String _currentTitle() {
    if (_active('/gakkum')) return 'Gakkum';
    if (_active('/pelanggaran')) return 'Pelanggaran';
    if (_active('/sim-tni')) return 'SIM TNI';
    if (_active('/provos')) return 'Provos';
    if (_active('/laka-lalin')) return 'Laka Lalu Lintas';
    if (_active('/tindak-pidana')) return 'Tindak Pidana';
    if (_active('/perbandingan')) return 'Bandingkan';
    if (_active('/data-quality')) return 'Kualitas data';
    if (_active('/input-laporan')) return 'Input Laporan';
    if (_active('/reports')) return 'Status Laporan';
    if (_active('/pomdam')) return 'POMDAM';
    if (_active('/laporan')) return 'Laporan';
    return 'Beranda';
  }
}

class _DesktopRail extends StatelessWidget {
  const _DesktopRail({
    required this.access,
    required this.items,
    required this.selectedIndex,
    required this.location,
    required this.onNavigate,
  });

  final CommanderAccessContext access;
  final List<_NavItem> items;
  final int selectedIndex;
  final String location;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      child: Material(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 14),
              const _BrandMark(),
              const SizedBox(height: 22),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    for (final item in items)
                      _RailItem(
                        item: item,
                        selected: location == item.path ||
                            (item.path != '/' && location.startsWith('${item.path}/')),
                        onTap: () => onNavigate(item.path),
                      ),
                  ],
                ),
              ),
              _RailItem(
                item: const _NavItem(
                  path: '/__more',
                  label: 'Menu',
                  icon: Icons.more_horiz_rounded,
                  selectedIcon: Icons.more_horiz_rounded,
                ),
                onTap: () => _showDesktopMenu(context),
              ),
              const SizedBox(height: 4),
              _AccountButton(access: access),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _showDesktopMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: _SecondaryMenu(
          access: access,
          onNavigate: (path) {
            Navigator.of(context).pop();
            onNavigate(path);
          },
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.item,
    required this.onTap,
    this.selected = false,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  static const _pathColors = {
    '/': Color(0xFF1677FF),
    '/gakkum': Color(0xFFFF5722),
    '/pelanggaran': Color(0xFFFF9800),
    '/sim-tni': Color(0xFF2196F3),
    '/provos': Color(0xFF4CAF50),
    '/laka-lalin': Color(0xFF9C27B0),
    '/tindak-pidana': Color(0xFFE91E63),
    '/pomdam': Color(0xFF009688),
  };

  @override
  Widget build(BuildContext context) {
    final domainColor = _pathColors[item.path] ?? AppTheme.brandDark;
    final foreground = selected ? domainColor : AppTheme.muted;
    final background =
        selected ? domainColor.withValues(alpha: .09) : Colors.transparent;

    return Tooltip(
      message: item.label,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (selected)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: domainColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? item.selectedIcon : item.icon,
                        size: 22,
                        color: foreground,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight:
                                  selected ? FontWeight.w800 : FontWeight.w700,
                              color: foreground,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryMenu extends StatelessWidget {
  const _SecondaryMenu({
    required this.access,
    required this.onNavigate,
  });

  final CommanderAccessContext access;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    final items = <_NavItem>[
      if (access.hasCapability(CommanderCapabilities.viewDataQuality))
        const _NavItem(
          path: '/data-quality',
          label: 'Kualitas data',
          icon: Icons.verified_outlined,
          selectedIcon: Icons.verified_rounded,
        ),
      if (access.hasCapability(CommanderCapabilities.manageReportData))
        const _NavItem(
          path: '/reports',
          label: 'Status Laporan',
          icon: Icons.fact_check_outlined,
          selectedIcon: Icons.fact_check_rounded,
        ),
      if (access.hasCapability(CommanderCapabilities.manageReportData))
        const _NavItem(
          path: '/input-laporan',
          label: 'Input Laporan',
          icon: Icons.note_add_outlined,
          selectedIcon: Icons.note_add_rounded,
        ),
      if (access.hasCapability(CommanderCapabilities.viewPomdamDirectory))
        const _NavItem(
          path: '/pomdam',
          label: 'POMDAM',
          icon: Icons.account_balance_outlined,
          selectedIcon: Icons.account_balance_rounded,
        ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      shrinkWrap: true,
      children: [
        const _BrandHeaderCompact(),
        const SizedBox(height: 12),
        for (final item in items)
          ListTile(
            dense: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: Icon(item.icon),
            title: Text(
              item.label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            onTap: () => onNavigate(item.path),
          ),
        const Divider(height: 22),
        ListTile(
          dense: true,
          leading: const Icon(Icons.logout_rounded),
          title: const Text(
            'Keluar',
            style: TextStyle(
              color: AppTheme.danger,
              fontWeight: FontWeight.w800,
            ),
          ),
          onTap: () async {
            try {
              await Supabase.instance.client.auth.signOut(
                scope: SignOutScope.local,
              );
            } catch (_) {}
          },
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppTheme.brand,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.insights_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

class _BrandHeaderCompact extends StatelessWidget {
  const _BrandHeaderCompact();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _BrandMark(),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            'Laporan Sdirbin Gakkum',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
      ],
    );
  }
}

class _AccountButton extends StatelessWidget {
  const _AccountButton({required this.access});

  final CommanderAccessContext access;

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? 'Akun';

    return Tooltip(
      message: 'Akun',
      child: IconButton(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (context) => SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              shrinkWrap: true,
              children: [
                Text(
                  email,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                if (access.role != null)
                  Text(
                    access.role!.displayName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.muted,
                        ),
                  ),
                const SizedBox(height: 18),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    try {
                      await Supabase.instance.client.auth.signOut(
                        scope: SignOutScope.local,
                      );
                    } catch (_) {}
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Keluar'),
                ),
              ],
            ),
          ),
        ),
        icon: const Icon(Icons.account_circle_outlined),
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
