import 'package:flutter/material.dart';
import 'dart:ui';

class SidebarItem {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  final List<SidebarItem>? children; // ERP Style Grouping

  SidebarItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
    this.children,
  });
}

class Sidebar extends StatefulWidget {
  final List<SidebarItem> items;
  final double tintOpacity;
  final Color? accentColor;
  final String userName;
  final String userRole;
  final VoidCallback? onLogout;

  const Sidebar({
    Key? key, 
    required this.items, 
    this.tintOpacity = 0.12, 
    this.accentColor,
    this.userName = 'User',
    this.userRole = 'Admin',
    this.onLogout,
  }) : super(key: key);

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _collapsed = false;
  final ScrollController _scrollController = ScrollController();
  final Set<String> _expandedGroups = {}; // Keep track of expanded sections

  void _toggleCollapse() => setState(() => _collapsed = !_collapsed);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 700;
    // Auto-collapse on mobile
    if (isMobile && !_collapsed) {
      Future.microtask(() => setState(() => _collapsed = true));
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      width: _collapsed ? (isMobile ? 0 : 72) : (isMobile ? 220 : 300),
      margin: isMobile ? const EdgeInsets.only(left: 0, top: 0, bottom: 0) : null,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 8 : 18,
        horizontal: isMobile ? 4 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: isMobile ? const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ) : BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(6, 0),
          ),
        ],
        // Glass effect
        backgroundBlendMode: BlendMode.overlay,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: isMobile ? const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ) : BorderRadius.circular(18),
        // Glassmorphism blur
        color: Colors.transparent,
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: ClipRRect(
        borderRadius: isMobile ? const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ) : BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Column(
            children: [
              // Header
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _collapsed
                  ? IconButton(
                      key: const ValueKey('collapsed'),
                      icon: const Icon(Icons.menu, color: Colors.white70, size: 26),
                      onPressed: _toggleCollapse,
                      tooltip: 'Expand',
                    )
                  : Row(
                      key: const ValueKey('expanded'),
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.indigo.shade700,
                                Colors.cyan.shade400
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.18),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('FRESHMART', style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold, 
                                color: Colors.white, 
                                fontSize: 19, 
                                letterSpacing: 1.2,
                                overflow: TextOverflow.ellipsis
                              )),
                              Text('ERP Suite', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.menu_open, color: Colors.white70),
                          onPressed: _toggleCollapse,
                          tooltip: 'Collapse',
                        )
                      ],
                    ),
              ),
              const SizedBox(height: 18),
              // Menu Items
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: !isMobile,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      if (item.children != null && item.children!.isNotEmpty) {
                        return _SidebarGroup(
                          item: item, 
                          collapsed: _collapsed,
                          isExpanded: _expandedGroups.contains(item.label) || item.isActive,
                          onToggle: () {
                            setState(() {
                              if (_expandedGroups.contains(item.label)) {
                                _expandedGroups.remove(item.label);
                              } else {
                                _expandedGroups.add(item.label);
                              }
                            });
                          },
                        );
                      }
                      return _SidebarTile(item: item, collapsed: _collapsed);
                    },
                  ),
                ),
              ),
              // User Profile
              const Divider(color: Colors.white12, thickness: 1, height: 18),
              if (!_collapsed) ...[
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.85),
                    radius: 18,
                    child: Text(widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(widget.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text(widget.userRole, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.logout, size: 20, color: Colors.white70),
                    onPressed: widget.onLogout ?? () {},
                  ),
                ),
              ] else ...[
                IconButton(
                  icon: const Icon(Icons.logout, size: 20, color: Colors.white70),
                  onPressed: widget.onLogout ?? () {},
                  tooltip: 'Logout',
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarGroup extends StatefulWidget {
  final SidebarItem item;
  final bool collapsed;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _SidebarGroup({required this.item, required this.collapsed, required this.isExpanded, required this.onToggle});

  @override
  State<_SidebarGroup> createState() => _SidebarGroupState();
}

class _SidebarGroupState extends State<_SidebarGroup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
    if (widget.isExpanded) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(_SidebarGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.collapsed) {
      return _SidebarTile(item: widget.item, collapsed: true);
    }
    final headerActive = widget.item.children!.any((c) => c.isActive);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
      decoration: BoxDecoration(
        color: headerActive ? Colors.blue.withOpacity(0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: widget.onToggle,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(widget.item.icon, color: headerActive ? Colors.cyanAccent : Colors.white70, size: 22),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.item.label.toUpperCase(),
                      style: TextStyle(
                        color: headerActive ? Colors.cyanAccent : Colors.white60,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.2,
                        shadows: headerActive
                            ? [Shadow(color: Colors.cyanAccent.withOpacity(0.2), blurRadius: 8)]
                            : null,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: widget.isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white38,
                      size: 18,
                    ),
                  )
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _heightFactor,
            axisAlignment: -1.0,
            child: Column(
              children: widget.item.children!.map((child) {
                return _SidebarTile(item: child, collapsed: false, isChild: true);
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class _SidebarTile extends StatefulWidget {
  final SidebarItem item;
  final bool collapsed;
  final bool isChild;
  const _SidebarTile({required this.item, required this.collapsed, this.isChild = false});

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.item.isActive;
    final isMobile = MediaQuery.of(context).size.width < 700;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.item.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(
            vertical: isMobile ? 1 : 2,
            horizontal: widget.collapsed ? 4 : (widget.isChild ? 16 : 8),
          ),
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 12 : 10,
            horizontal: widget.collapsed ? 0 : (widget.isChild ? 24 : 14),
          ),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF2563EB).withOpacity(0.85)
                : (_hovering ? Colors.white.withOpacity(0.08) : Colors.transparent),
            borderRadius: BorderRadius.circular(widget.isChild ? 7 : 10),
            border: isActive
                ? Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 1.2)
                : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.13),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: widget.collapsed
              ? Center(
                  child: Icon(
                    widget.item.icon,
                    color: isActive ? Colors.cyanAccent : Colors.white70,
                    size: widget.isChild ? 20 : 24,
                  ),
                )
              : Row(
                  children: [
                    Icon(
                      widget.item.icon,
                      color: isActive
                          ? Colors.white
                          : (widget.isChild ? Colors.white54 : Colors.white70),
                      size: widget.isChild ? 20 : 24,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      widget.item.label,
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : (widget.isChild ? Colors.white60 : Colors.white70),
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                        fontSize: widget.isChild ? 13 : 15,
                        letterSpacing: 0.2,
                        shadows: isActive
                            ? [Shadow(color: Colors.cyanAccent.withOpacity(0.18), blurRadius: 8)]
                            : null,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

