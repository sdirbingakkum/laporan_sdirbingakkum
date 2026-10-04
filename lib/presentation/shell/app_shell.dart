import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../application/providers/commander_access_context_providers.dart';
import '../../domain/entities/commander_access_context_entities.dart';
import '../theme/app_theme.dart';
import '../widgets/analytics_ui.dart';

const _reportItems = <_NavEntry>[
  _NavEntry(path: '/laporan', label: 'Ringkasan'),
  _NavEntry(path: '/gakkum', label: 'Gakkum', icon: Icons.gavel_outlined),
  _NavEntry(
    path: '/pelanggaran',
    label: 'Pelanggaran',
    icon: Icons.rule_outlined,
  ),
  _NavEntry(path: '/sim-tni', label: 'SIM TNI', icon: Icons.badge_outlined),
  _NavEntry(path: '/provos', label: 'Provos', icon: Icons.shield_outlined),
  _NavEntry(
    path: '/laka-lalin',
    label: 'Laka Lalu Lintas',
    icon: Icons.car_crash_outlined,
  ),
  _NavEntry(
    path: '/tindak-pidana',
    label: 'Tindak Pidana',
    icon: Icons.policy_outlined,
  ),
];

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
  bool _reportsOpen = true;
  bool _operationsOpen = true;
  bool _adminOpen = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isActive(String path) {
    if (path == '/') return widget.location == '/';
    return widget.location == path || widget.location.startsWith('$path/');
  }

  @override
  Widget build(BuildContext context) {
    final access = ref.watch(commanderAccessContextProvider).value;
    if (access == null || !access.isAuthorized) {
      return Scaffold(body: widget.child);
    }

    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 1000;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.canvas,
      appBar: desktop
          ? null
          : AppBar(
              title: Text(
                _currentTitle(access),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              leading: Builder(
                builder: (context) => IconButton(
                  tooltip: 'Menu',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu_rounded),
                ),
              ),
              actions: [
                _AccountButton(access: access),
                const SizedBox(width: 8),
              ],
            ),
      drawer: desktop
          ? null
          : Drawer(
              width: width < 520 ? width * .88 : 340,
              child: SafeArea(
                child: _NavigationPanel(
                  access: access,
                  location: widget.location,
                  reportsOpen: _reportsOpen,
                  operationsOpen: _operationsOpen,
                  adminOpen: _adminOpen,
                  onReportsToggle: () =>
                      setState(() => _reportsOpen = !_reportsOpen),
                  onOperationsToggle: () =>
                      setState(() => _operationsOpen = !_operationsOpen),
                  onAdminToggle: () =>
                      setState(() => _adminOpen = !_adminOpen),
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
                SizedBox(
                  width: 270,
                  child: Material(
                    color: Colors.white,
                    child: SafeArea(
                      child: _NavigationPanel(
                        access: access,
                        location: widget.location,
                        reportsOpen: _reportsOpen,
                        operationsOpen: _operationsOpen,
                        adminOpen: _adminOpen,
                        onReportsToggle: () =>
                            setState(() => _reportsOpen = !_reportsOpen),
                        onOperationsToggle: () =>
                            setState(() => _operationsOpen = !_operationsOpen),
                        onAdminToggle: () =>
                            setState(() => _adminOpen = !_adminOpen),
                        onNavigate: (path) => context.go(path),
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Column(
                    children: [
                      _DesktopHeader(access: access),
                      Expanded(child: widget.child),
                    ],
                  ),
                ),
              ],
            )
          : widget.child,
      bottomNavigationBar: desktop
          ? null
          : _MobileBottomBar(
              location: widget.location,
              access: access,
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
    );
  }

  String _currentTitle(CommanderAccessContext access) {
    if (_isActive('/gakkum')) return 'Gakkum';
    if (_isActive('/pelanggaran')) return 'Pelanggaran';
    if (_isActive('/sim-tni')) return 'SIM TNI';
    if (_isActive('/provos')) return 'Provos';
    if (_isActive('/laka-lalin')) return 'Laka Lalu Lintas';
    if (_isActive('/tindak-pidana')) return 'Tindak Pidana';
    if (_isActive('/perbandingan')) return 'Perbandingan';
    if (_isActive('/data-quality')) return 'Kualitas Data';
    if (_isActive('/input-laporan')) return 'Input Laporan';
    if (_isActive('/reports')) return 'Status Laporan';
    if (_isActive('/pomdam')) return 'Data POMDAM';
    if (_isActive('/laporan')) return 'Laporan';
    if (access.canUseCommanderDashboard) return 'Beranda';
    return 'Laporan Sdirbin Gakkum';
  }
}

class _NavigationPanel extends StatelessWidget {
  const _NavigationPanel({
    required this.access,
    required this.location,
    required this.reportsOpen,
    required this.operationsOpen,
    required this.adminOpen,
    required this.onReportsToggle,
    required this.onOperationsToggle,
    required this.onAdminToggle,
    required this.onNavigate,
  });

  final CommanderAccessContext access;
  final String location;
  final bool reportsOpen;
  final bool operationsOpen;
  final bool adminOpen;
  final VoidCallback onReportsToggle;
  final VoidCallback onOperationsToggle;
  final VoidCallback onAdminToggle;
  final ValueChanged<String> onNavigate;


  bool _active(String path) {
    if (path == '/') return location == '/';
    return location == path || location.startsWith('$path/');
  }

  void _go(String path) => onNavigate(path);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      children: [
        const _BrandHeader(),
        const SizedBox(height: 18),
        if (access.canUseCommanderDashboard)
          _PrimaryNavTile(
            icon: Icons.grid_view_rounded,
            label: 'Beranda',
            selected: _active('/'),
            onTap: () => _go('/'),
          ),
        const SizedBox(height: 4),
        _GroupTile(
          icon: Icons.analytics_outlined,
          label: 'Laporan',
          selected: _active('/laporan') || _reportItems.any((e) => _active(e.path)),
          expanded: reportsOpen,
          onTap: onReportsToggle,
        ),
        if (reportsOpen)
          _ChildNavList(
            items: _reportItems,
            active: _active,
            onTap: _go,
          ),
        if (access.canUseCommanderDashboard) ...[
          const SizedBox(height: 4),
          _PrimaryNavTile(
            icon: Icons.compare_arrows_rounded,
            label: 'Perbandingan',
            selected: _active('/perbandingan'),
            onTap: () => _go('/perbandingan'),
          ),
        ],
        if (access.hasCapability(CommanderCapabilities.viewDataQuality)) ...[
          const SizedBox(height: 4),
          _PrimaryNavTile(
            icon: Icons.verified_outlined,
            label: 'Kualitas Data',
            selected: _active('/data-quality'),
            onTap: () => _go('/data-quality'),
          ),
        ],
        if (access.hasCapability(CommanderCapabilities.manageReportData)) ...[
          const SizedBox(height: 14),
          const _SectionLabel('OPERASIONAL'),
          const SizedBox(height: 4),
          _GroupTile(
            icon: Icons.input_rounded,
            label: 'Operasional',
            selected: _active('/input-laporan') || _active('/reports'),
            expanded: operationsOpen,
            onTap: onOperationsToggle,
          ),
          if (operationsOpen)
            _ChildTextNavList(
              items: const [
                _NavEntry(path: '/input-laporan', label: 'Input Laporan'),
                _NavEntry(path: '/reports', label: 'Status Laporan'),
              ],
              active: _active,
              onTap: _go,
            ),
        ],
        if (access.hasCapability(CommanderCapabilities.viewPomdamDirectory)) ...[
          const SizedBox(height: 14),
          const _SectionLabel('ADMINISTRASI'),
          const SizedBox(height: 4),
          _GroupTile(
            icon: Icons.settings_outlined,
            label: 'Administrasi',
            selected: _active('/pomdam'),
            expanded: adminOpen,
            onTap: onAdminToggle,
          ),
          if (adminOpen)
            _ChildTextNavList(
              items: const [
                _NavEntry(path: '/pomdam', label: 'Data POMDAM'),
              ],
              active: _active,
              onTap: _go,
            ),
        ],
        const SizedBox(height: 20),
        const Divider(height: 1),
        const SizedBox(height: 12),
        _UserStrip(access: access),
        const SizedBox(height: 8),
        _PrimaryNavTile(
          icon: Icons.logout_rounded,
          label: 'Keluar',
          selected: false,
          danger: true,
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

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.brand,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.insights_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Text(
            'Laporan Sdirbin Gakkum',
            maxLines: 2,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
        ),
      ],
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader({required this.access});

  final CommanderAccessContext access;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Analitik laporan bulanan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          if (access.role != null)
            AppBadge(
              icon: Icons.person_outline_rounded,
              label: access.role!.displayName,
            ),
          const SizedBox(width: 8),
          _AccountButton(access: access),
        ],
      ),
    );
  }
}

class _AccountButton extends StatelessWidget {
  const _AccountButton({required this.access});

  final CommanderAccessContext access;

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? 'Akun';
    return PopupMenuButton<String>(
      tooltip: 'Akun',
      icon: const Icon(Icons.account_circle_outlined),
      onSelected: (value) async {
        if (value != 'sign_out') return;
        try {
          await Supabase.instance.client.auth.signOut(
            scope: SignOutScope.local,
          );
        } catch (error) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error is AuthException
                    ? error.message
                    : 'Gagal keluar. Periksa koneksi lalu coba lagi.',
              ),
            ),
          );
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Text(email),
        ),
        if (access.role != null)
          PopupMenuItem<String>(
            enabled: false,
            child: Text(
              access.role!.displayName,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'sign_out',
          child: Text('Keluar'),
        ),
      ],
    );
  }
}

class _UserStrip extends StatelessWidget {
  const _UserStrip({required this.access});

  final CommanderAccessContext access;

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? 'Akun aktif';
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppTheme.canvas,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 17,
            backgroundColor: AppTheme.brand,
            child: Icon(Icons.person_rounded, color: Colors.white, size: 17),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  access.role?.displayName ?? 'Pengguna',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.muted,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryNavTile extends StatelessWidget {
  const _PrimaryNavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final foreground = danger
        ? AppTheme.danger
        : selected
            ? AppTheme.brandDark
            : AppTheme.ink;
    final background = danger
        ? Colors.transparent
        : selected
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .6)
            : Colors.transparent;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: foreground,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .45)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppTheme.brandDark : AppTheme.ink,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w650,
                  ),
                ),
              ),
              Icon(
                expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                size: 19,
                color: AppTheme.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildNavList extends StatelessWidget {
  const _ChildNavList({
    required this.items,
    required this.active,
    required this.onTap,
  });

  final List<_NavEntry> items;
  final bool Function(String) active;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 21, top: 3, bottom: 3),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: AppTheme.border, width: 1.5),
          ),
        ),
        child: Column(
          children: [
            for (final item in items)
              _ChildNavTile(
                label: item.label,
                selected: active(item.path),
                onTap: () => onTap(item.path),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChildTextNavList extends StatelessWidget {
  const _ChildTextNavList({
    required this.items,
    required this.active,
    required this.onTap,
  });

  final List<_NavEntry> items;
  final bool Function(String) active;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 21, top: 3, bottom: 3),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: AppTheme.border, width: 1.5),
          ),
        ),
        child: Column(
          children: [
            for (final item in items)
              _ChildNavTile(
                label: item.label,
                selected: active(item.path),
                onTap: () => onTap(item.path),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChildNavTile extends StatelessWidget {
  const _ChildNavTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .4)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(13, 8, 8, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? AppTheme.brandDark : AppTheme.muted,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 11),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.muted,
              fontWeight: FontWeight.w800,
              letterSpacing: .8,
            ),
      ),
    );
  }
}

class _MobileBottomBar extends StatelessWidget {
  const _MobileBottomBar({
    required this.location,
    required this.access,
    required this.onMenu,
  });

  final String location;
  final CommanderAccessContext access;
  final VoidCallback onMenu;

  int get selectedIndex {
    if (location == '/') return 0;
    if (location == '/laporan' ||
        location.startsWith('/gakkum') ||
        location.startsWith('/pelanggaran') ||
        location.startsWith('/sim-tni') ||
        location.startsWith('/provos') ||
        location.startsWith('/laka-lalin') ||
        location.startsWith('/tindak-pidana')) {
      return 1;
    }
    if (location == '/perbandingan') return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final thirdLabel = access.canUseCommanderDashboard ? 'Bandingkan' : 'Kualitas';
    final thirdPath = access.canUseCommanderDashboard
        ? '/perbandingan'
        : '/data-quality';

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/');
          case 1:
            context.go('/laporan');
          case 2:
            context.go(thirdPath);
          case 3:
            onMenu();
        }
      },
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: 'Beranda',
        ),
        const NavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics_rounded),
          label: 'Laporan',
        ),
        NavigationDestination(
          icon: Icon(access.canUseCommanderDashboard
              ? Icons.compare_arrows_outlined
              : Icons.verified_outlined),
          selectedIcon: Icon(access.canUseCommanderDashboard
              ? Icons.compare_arrows_rounded
              : Icons.verified_rounded),
          label: thirdLabel,
        ),
        const NavigationDestination(
          icon: Icon(Icons.menu_rounded),
          label: 'Menu',
        ),
      ],
    );
  }
}

final class _NavEntry {
  const _NavEntry({
    required this.path,
    required this.label,
    this.icon,
  });

  final String path;
  final String label;
  final IconData? icon;
}
