import 'package:flutter/material.dart';

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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      // Wider when expanded to accommodate hierarchy
      width: _collapsed ? 88 : 320, 
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Dark Slate Blue for ERP feel
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(4, 0))],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: _collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
            if (!_collapsed) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.indigo.shade800]),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: const Icon(Icons.business, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('FRESHMART', style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold, 
                      color: Colors.white, 
                      fontSize: 18, 
                      letterSpacing: 1.1,
                      overflow: TextOverflow.ellipsis
                    )),
                    Text('ERP Suite', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.menu_open, color: Colors.white70),
                onPressed: _toggleCollapse,
              )
            ] else ...[
              // Collapsed: Just show the toggle button (centered by Row)
               IconButton(
                 icon: const Icon(Icons.menu, color: Colors.white70, size: 24), 
                 onPressed: _toggleCollapse
               ),
            ]
          ]),

          const SizedBox(height: 24),

          // Menu Items
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  // If group (has children)
                  if (item.children != null && item.children!.isNotEmpty) {
                    return _SidebarGroup(
                      item: item, 
                      collapsed: _collapsed,
                      isExpanded: _expandedGroups.contains(item.label) || item.isActive, // Auto expand if active child
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
                  // Single item
                  return _SidebarTile(item: item, collapsed: _collapsed);
                },
              ),
            ),
          ),

          // User Profile
          const Divider(color: Colors.white12),
          if (!_collapsed) ...[
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: widget.onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                 Icon(widget.item.icon, color: headerActive ? Colors.blueAccent : Colors.white70, size: 22),
                 const SizedBox(width: 14),
                 Expanded(
                   child: Text(
                     widget.item.label.toUpperCase(),
                     style: TextStyle(
                       color: headerActive ? Colors.blueAccent : Colors.white60,
                       fontWeight: FontWeight.bold,
                       fontSize: 12,
                       letterSpacing: 1.2
                     ),
                   ),
                 ),
                 Icon(
                   widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                   color: Colors.white38,
                   size: 18,
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.item.onTap,
        child: Container(
          margin: EdgeInsets.symmetric(
             vertical: 2, 
             horizontal: widget.collapsed ? 8 : (widget.isChild ? 12 : 8)
          ),
          padding: EdgeInsets.symmetric(
            vertical: 10, 
            horizontal: widget.collapsed ? 0 : (widget.isChild ? 20 : 12)
          ),
          decoration: BoxDecoration(
            color: isActive 
               ? const Color(0xFF334155) // Active Slate
               : (_hovering ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: isActive ? Border.all(color: Colors.blueAccent.withOpacity(0.5)) : null,
          ),
          child: widget.collapsed
              ? Center(child: Icon(widget.item.icon, color: isActive ? Colors.blueAccent : Colors.white70))
              : Row(
                  children: [
                    Icon(widget.item.icon, 
                      color: isActive ? Colors.blueAccent : (widget.isChild ? Colors.white54 : Colors.white70),
                      size: widget.isChild ? 18 : 22
                    ),
                    const SizedBox(width: 14),
                    Text(
                      widget.item.label,
                      style: TextStyle(
                        color: isActive ? Colors.white : (widget.isChild ? Colors.white60 : Colors.white70),
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

