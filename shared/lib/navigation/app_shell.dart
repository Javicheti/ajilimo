import 'package:flutter/material.dart';

import '../design/brand.dart';
import '../design/semantic_colors.dart';
import '../design/tokens.dart';
import 'nav.dart';

/// Shell de la plataforma: barra de navegación vertical + topbar + contenido.
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool expanded = width >= 1080;
        final bool rail = width >= 720 && width < 1080;

        if (expanded || rail) {
          return Scaffold(
            body: Row(
              children: <Widget>[
                _Sidebar(
                  expanded: expanded,
                  groups: groups,
                  currentRoute: currentRoute,
                  onNavigate: onNavigate,
                  userName: userName,
                  userRoleLabel: userRoleLabel,
                  onLogout: onLogout,
                  onToggleTheme: onToggleTheme,
                  darkMode: darkMode,
                  brand: brand,
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      _TopBar(
                        title: title,
                        notifications: notifications,
                        userName: userName,
                        onToggleTheme: onToggleTheme,
                        darkMode: darkMode,
                        onLogout: onLogout,
                        showMenu: false,
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
            child: _Sidebar(
              expanded: true,
              groups: groups,
              currentRoute: currentRoute,
              onNavigate: onNavigate,
              userName: userName,
              userRoleLabel: userRoleLabel,
              onLogout: onLogout,
              onToggleTheme: onToggleTheme,
              darkMode: darkMode,
              brand: brand,
            ),
          ),
          body: Builder(
            builder: (context) => Column(
              children: <Widget>[
                _TopBar(
                  title: title,
                  notifications: notifications,
                  userName: userName,
                  onToggleTheme: onToggleTheme,
                  darkMode: darkMode,
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
// Sidebar
// ---------------------------------------------------------------------------

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.expanded,
    required this.groups,
    required this.currentRoute,
    required this.onNavigate,
    required this.userName,
    required this.userRoleLabel,
    required this.brand,
    this.onLogout,
    this.onToggleTheme,
    this.darkMode = false,
  });

  final bool expanded;
  final List<NavGroup> groups;
  final String currentRoute;
  final ValueChanged<String> onNavigate;
  final String userName;
  final String userRoleLabel;
  final BrandPalette brand;
  final VoidCallback? onLogout;
  final VoidCallback? onToggleTheme;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    const Color sidebarBg = Color(0xFF141418);
    const Color itemIdle = Color(0xFFB4B4BE);
    const Color sectionLabel = Color(0xFF6B6B78);

    return Container(
      width: expanded ? 248 : 76,
      color: sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Brand(expanded: expanded, brand: brand),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
              children: <Widget>[
                for (final NavGroup group in groups) ...<Widget>[
                  if (expanded)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.lg, Spacing.xxs),
                      child: Text(
                        group.label.toUpperCase(),
                        style: const TextStyle(
                          color: sectionLabel,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
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
                      idleColor: itemIdle,
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
          const Divider(height: 1, color: Color(0xFF26262E)),
          _UserCard(
            expanded: expanded,
            userName: userName,
            userRoleLabel: userRoleLabel,
            accent: brand.primary,
            darkMode: darkMode,
            onToggleTheme: onToggleTheme,
            onLogout: onLogout,
          ),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.expanded, required this.brand});
  final bool expanded;
  final BrandPalette brand;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(expanded ? Spacing.lg : Spacing.md, Spacing.lg, Spacing.md, Spacing.sm),
      child: Row(
        mainAxisAlignment: expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: brand.primary, borderRadius: BorderRadius.circular(Radii.md)),
            alignment: Alignment.center,
            child: const Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
          ),
          if (expanded) ...<Widget>[
            const SizedBox(width: Spacing.sm),
            const Text(
              'AjíLimo',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: -0.3),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.entry,
    required this.expanded,
    required this.active,
    required this.idleColor,
    required this.accent,
    required this.onTap,
  });

  final NavEntry entry;
  final bool expanded;
  final bool active;
  final Color idleColor;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg = active ? Colors.white : idleColor;
    final Widget tile = Container(
      margin: EdgeInsets.symmetric(horizontal: expanded ? Spacing.md : Spacing.xs, vertical: 2),
      decoration: BoxDecoration(
        color: active ? accent.withValues(alpha: 0.16) : Colors.transparent,
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.md),
        onTap: entry.enabled ? onTap : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: expanded ? Spacing.sm : 0, vertical: Spacing.sm),
          child: Row(
            mainAxisAlignment: expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Icon(entry.icon, size: 20, color: fg),
                  if (entry.badge != null && entry.badge! > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(Radii.pill)),
                        constraints: const BoxConstraints(minWidth: 14),
                        child: Text(
                          '${entry.badge}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
              if (expanded) ...<Widget>[
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    entry.label,
                    style: TextStyle(color: fg, fontSize: 14, fontWeight: active ? FontWeight.w700 : FontWeight.w500),
                  ),
                ),
                if (entry.badge != null && entry.badge! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(Radii.pill)),
                    child: Text(
                      '${entry.badge}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );

    return expanded ? tile : Tooltip(message: entry.label, child: tile);
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.expanded,
    required this.userName,
    required this.userRoleLabel,
    required this.accent,
    required this.darkMode,
    this.onToggleTheme,
    this.onLogout,
  });

  final bool expanded;
  final String userName;
  final String userRoleLabel;
  final Color accent;
  final bool darkMode;
  final VoidCallback? onToggleTheme;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final String initial = userName.trim().isNotEmpty ? userName.trim()[0].toUpperCase() : '?';
    return Padding(
      padding: const EdgeInsets.all(Spacing.sm),
      child: PopupMenuButton<String>(
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
          mainAxisAlignment: expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 16,
              backgroundColor: accent,
              child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
            if (expanded) ...<Widget>[
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(userRoleLabel, style: const TextStyle(color: Color(0xFF9A9AA0), fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.unfold_more, color: Color(0xFF9A9AA0), size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Topbar
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.notifications,
    required this.userName,
    required this.showMenu,
    required this.darkMode,
    this.onMenu,
    this.onToggleTheme,
    this.onLogout,
  });

  final String title;
  final int notifications;
  final String userName;
  final bool showMenu;
  final bool darkMode;
  final VoidCallback? onMenu;
  final VoidCallback? onToggleTheme;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Row(
        children: <Widget>[
          if (showMenu)
            IconButton(icon: const Icon(Icons.menu), onPressed: onMenu)
          else
            const SizedBox(width: Spacing.xxs),
          const SizedBox(width: Spacing.xs),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          IconButton(
            tooltip: 'Notificaciones',
            onPressed: () {},
            icon: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                const Icon(Icons.notifications_none_outlined),
                if (notifications > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(color: c.danger, shape: BoxShape.circle),
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
