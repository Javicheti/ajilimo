import 'package:flutter/material.dart' hide Durations;

import '../branding/app_logo.dart';
import '../design/brand.dart';
import '../design/semantic_colors.dart';
import '../design/tokens.dart';
import 'nav.dart';

/// Shell de la plataforma: header (marca + país/notificaciones/usuario) +
/// sidebar vertical claro con ítem activo tipo pill + contenido.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.groups,
    required this.onNavigate,
    required this.userName,
    required this.userRoleLabel,
    required this.child,
    this.onLogout,
    this.onToggleTheme,
    this.darkMode = false,
    this.notifications = 0,
    this.brand = BrandPalette.ajiLimo,
    this.countryLabel = 'Perú',
    this.version = 'v.1.0.0',
  });

  final String title;
  final String currentRoute;
  final List<NavGroup> groups;
  final ValueChanged<String> onNavigate;
  final String userName;
  final String userRoleLabel;
  final Widget child;
  final VoidCallback? onLogout;
  final VoidCallback? onToggleTheme;
  final bool darkMode;
  final int notifications;
  final BrandPalette brand;
  final String countryLabel;
  final String version;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool expanded = width >= 1080;
        final bool rail = width >= 720 && width < 1080;
        final double sidebarWidth = expanded ? 256 : 76;

        if (expanded || rail) {
          return Scaffold(
            body: Column(
              children: <Widget>[
                _Header(
                  leftWidth: sidebarWidth,
                  brand: brand,
                  userName: userName,
                  userRoleLabel: userRoleLabel,
                  notifications: notifications,
                  countryLabel: countryLabel,
                  darkMode: darkMode,
                  onToggleTheme: onToggleTheme,
                  onLogout: onLogout,
                  showMenu: false,
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      _Sidebar(
                        expanded: expanded,
                        groups: groups,
                        currentRoute: currentRoute,
                        onNavigate: onNavigate,
                        version: version,
                        countryLabel: countryLabel,
                        brand: brand,
                      ),
                      Expanded(child: _Content(child: child)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          drawer: Drawer(
            width: 268,
            child: Column(
              children: <Widget>[
                const _DrawerHeader(),
                Expanded(
                  child: _Sidebar(
                    expanded: true,
                    groups: groups,
                    currentRoute: currentRoute,
                    onNavigate: onNavigate,
                    version: version,
                    countryLabel: countryLabel,
                    brand: brand,
                    embedded: true,
                  ),
                ),
              ],
            ),
          ),
          body: Builder(
            builder: (context) => Column(
              children: <Widget>[
                _Header(
                  leftWidth: 76,
                  brand: brand,
                  userName: userName,
                  userRoleLabel: userRoleLabel,
                  notifications: notifications,
                  countryLabel: countryLabel,
                  darkMode: darkMode,
                  onToggleTheme: onToggleTheme,
                  onLogout: onLogout,
                  showMenu: true,
                  onMenu: () => Scaffold.of(context).openDrawer(),
                ),
                Expanded(child: _Content(child: child)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.leftWidth,
    required this.brand,
    required this.userName,
    required this.userRoleLabel,
    required this.notifications,
    required this.countryLabel,
    required this.darkMode,
    this.onToggleTheme,
    this.onLogout,
    this.showMenu = false,
    this.onMenu,
  });

  final double leftWidth;
  final BrandPalette brand;
  final String userName;
  final String userRoleLabel;
  final int notifications;
  final String countryLabel;
  final bool darkMode;
  final VoidCallback? onToggleTheme;
  final VoidCallback? onLogout;
  final bool showMenu;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: leftWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: Row(
                children: <Widget>[
                  if (showMenu)
                    IconButton(icon: const Icon(Icons.menu), onPressed: onMenu)
                  else
                    AppLogo(
                      size: 34,
                      showWordmark: leftWidth > 100,
                      wordmarkColor: c.textStrong,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: Spacing.lg),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: Spacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  _CountryChip(countryLabel: countryLabel),
                  const SizedBox(width: Spacing.sm),
                  _NotificationsButton(count: notifications),
                  const SizedBox(width: Spacing.sm),
                  _UserMenu(
                    userName: userName,
                    userRoleLabel: userRoleLabel,
                    darkMode: darkMode,
                    onToggleTheme: onToggleTheme,
                    onLogout: onLogout,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryChip extends StatelessWidget {
  const _CountryChip({required this.countryLabel});
  final String countryLabel;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: <Widget>[
          const Text('🇵🇪', style: TextStyle(fontSize: 16)),
          const SizedBox(width: Spacing.xs),
          Text(countryLabel, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(width: 2),
          Icon(Icons.expand_more, size: 18, color: c.textMid),
        ],
      ),
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_outlined)),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(color: c.danger, borderRadius: BorderRadius.circular(Radii.pill)),
              child: Text(
                '$count',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }
}

class _UserMenu extends StatelessWidget {
  const _UserMenu({
    required this.userName,
    required this.userRoleLabel,
    required this.darkMode,
    this.onToggleTheme,
    this.onLogout,
  });

  final String userName;
  final String userRoleLabel;
  final bool darkMode;
  final VoidCallback? onToggleTheme;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String initial = userName.trim().isNotEmpty ? userName.trim()[0].toUpperCase() : '?';
    return PopupMenuButton<String>(
      tooltip: 'Cuenta',
      onSelected: (value) {
        if (value == 'logout') onLogout?.call();
        if (value == 'theme') onToggleTheme?.call();
      },
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(enabled: false, child: Text(userRoleLabel)),
        if (onToggleTheme != null)
          PopupMenuItem<String>(value: 'theme', child: Text(darkMode ? 'Modo claro' : 'Modo oscuro')),
        if (onLogout != null) const PopupMenuItem<String>(value: 'logout', child: Text('Cerrar sesión')),
      ],
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(userName, style: Theme.of(context).textTheme.titleSmall),
              Text('⭐ $userRoleLabel', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c.textMid)),
            ],
          ),
          const SizedBox(width: Spacing.sm),
          CircleAvatar(
            radius: 18,
            backgroundColor: c.brandPrimary,
            child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sidebar
// ---------------------------------------------------------------------------

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: AppLogo(size: 34, showWordmark: true, wordmarkColor: context.colors.textStrong),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.expanded,
    required this.groups,
    required this.currentRoute,
    required this.onNavigate,
    required this.version,
    required this.countryLabel,
    required this.brand,
    this.embedded = false,
  });

  final bool expanded;
  final List<NavGroup> groups;
  final String currentRoute;
  final ValueChanged<String> onNavigate;
  final String version;
  final String countryLabel;
  final BrandPalette brand;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      width: expanded ? 256 : 76,
      decoration: BoxDecoration(
        color: c.surface,
        border: embedded ? null : Border(right: BorderSide(color: c.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
              children: <Widget>[
                for (final NavGroup group in groups) ...<Widget>[
                  if (expanded)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, Spacing.xxs),
                      child: Text(
                        group.label.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: c.textFaint,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                      ),
                    )
                  else
                    const SizedBox(height: Spacing.sm),
                  for (final NavEntry entry in group.entries)
                    _NavTile(
                      entry: entry,
                      expanded: expanded,
                      active: currentRoute == entry.route,
                      accent: brand.primary,
                      onTap: () {
                        onNavigate(entry.route);
                        if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                ],
              ],
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
              child: Row(
                children: <Widget>[
                  const Text('🇵🇪', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: Spacing.xs),
                  const Text('🇺🇸', style: TextStyle(fontSize: 16)),
                  const Spacer(),
                  Text(version, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c.textFaint)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  const _NavTile({
    required this.entry,
    required this.expanded,
    required this.active,
    required this.accent,
    required this.onTap,
  });

  final NavEntry entry;
  final bool expanded;
  final bool active;
  final Color accent;
  final VoidCallback onTap;

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool active = widget.active;
    final Color fg = active ? Colors.white : c.textMid;
    final Color bg = active
        ? widget.accent
        : (_hover ? c.surfaceAlt : Colors.transparent);

    final Widget tile = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: Durations.fast,
        margin: EdgeInsets.symmetric(horizontal: widget.expanded ? Spacing.sm : Spacing.xs, vertical: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Radii.md),
          boxShadow: active
              ? <BoxShadow>[BoxShadow(color: widget.accent.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))]
              : null,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.md),
          onTap: widget.entry.enabled ? widget.onTap : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.expanded ? Spacing.sm : 0, vertical: Spacing.sm),
            child: Row(
              mainAxisAlignment: widget.expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: <Widget>[
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Icon(widget.entry.icon, size: 20, color: fg),
                    if (!widget.expanded && widget.entry.badge != null && widget.entry.badge! > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(color: widget.accent, shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
                if (widget.expanded) ...<Widget>[
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      widget.entry.label,
                      style: TextStyle(
                        color: fg,
                        fontSize: 14,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (widget.entry.badge != null && widget.entry.badge! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: active ? Colors.white.withValues(alpha: 0.25) : widget.accent,
                        borderRadius: BorderRadius.circular(Radii.pill),
                      ),
                      child: Text(
                        '${widget.entry.badge}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return widget.expanded ? tile : Tooltip(message: widget.entry.label, child: tile);
  }
}
