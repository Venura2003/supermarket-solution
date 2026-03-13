import 'package:flutter/material.dart';


class CustomHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String appName;
  final String userName;
  final String userRole;
  final VoidCallback onLogout;
  final bool fullColor;
  final Function(String)? onSearch;
  final VoidCallback? onSync;
  final VoidCallback? onNew;

  const CustomHeaderBar({
    super.key,
    required this.appName,
    required this.userName,
    required this.userRole,
    required this.onLogout,
    this.fullColor = false,
    this.onSearch,
    this.onSync,
    this.onNew,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = fullColor ? theme.colorScheme.primary : theme.colorScheme.surface;
    final contentColor = fullColor ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(fullColor ? 0.06 : 0.04),
            blurRadius: fullColor ? 10 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // App logo + name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: contentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.storefront, color: contentColor, size: 26),
              ),
              const SizedBox(width: 12),
              Text(appName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: contentColor)),
            ],
          ),

          const SizedBox(width: 18),

          // Search box
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: theme.colorScheme.surface),
                  child: Row(children: [
                    Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.75)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration.collapsed(hintText: 'Search products, orders, customers...'),
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        onSubmitted: onSearch,
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                    IconButton(icon: Icon(Icons.mic, color: theme.colorScheme.onSurface.withOpacity(0.8)), onPressed: () {}),
                  ]),
                ),
              ),
            ),
          ),

          const SizedBox(width: 18),

          // Quick actions
          Row(children: [
            TextButton.icon(
              onPressed: onSync,
              icon: Icon(Icons.sync, color: contentColor),
              label: Text('Sync', style: TextStyle(color: contentColor)),
              style: TextButton.styleFrom(foregroundColor: contentColor),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onNew,
              icon: Icon(Icons.add, color: contentColor),
              label: Text('New', style: TextStyle(color: contentColor)),
              style: ElevatedButton.styleFrom(backgroundColor: contentColor.withOpacity(0.12), foregroundColor: contentColor, elevation: 0),
            ),
          ]),

          const Spacer(),

          // Notifications icon with badge
          _NotificationIcon(color: contentColor),
          const SizedBox(width: 20),
          // User profile dropdown
          _ProfileDropdown(
            userName: userName,
            userRole: userRole,
            onLogout: onLogout,
            contentColor: contentColor,
          ),
        ],
      ),
    );
  }


}

class _NotificationIcon extends StatelessWidget {
  final Color? color;
  const _NotificationIcon({this.color});

  @override
  Widget build(BuildContext context) {
    // For demo, hardcode unread count. Replace with real value if available.
    final int unreadCount = 3;
    final iconColor = color ?? Theme.of(context).iconTheme.color ?? Colors.black;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_none_rounded, size: 28, color: iconColor),
          tooltip: 'Notifications',
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) => const _NotificationsPanel(),
            );
          },
        ),
        if (unreadCount > 0)
          Positioned(
            right: 6,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _NotificationsPanel extends StatelessWidget {
  const _NotificationsPanel();

  @override
  Widget build(BuildContext context) {
    // Demo notifications. Replace with real data.
    final notifications = [
      {'title': 'Low Stock Alert', 'subtitle': 'Milk is running low!', 'icon': Icons.warning, 'color': Colors.orange},
      {'title': 'New Sale', 'subtitle': 'Order #1234 completed.', 'icon': Icons.shopping_cart, 'color': Colors.green},
      {'title': 'System Message', 'subtitle': 'Backup completed successfully.', 'icon': Icons.info, 'color': Colors.blue},
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...notifications.map((n) => ListTile(
                  leading: Icon(n['icon'] as IconData, color: n['color'] as Color),
                  title: Text(n['title'] as String),
                  subtitle: Text(n['subtitle'] as String),
                )),
            if (notifications.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No notifications', style: TextStyle(color: Colors.grey))),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDropdown extends StatelessWidget {
  final String userName;
  final String userRole;
  final VoidCallback onLogout;
  final Color? contentColor;
  const _ProfileDropdown({
    required this.userName,
    required this.userRole,
    required this.onLogout,
    this.contentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = contentColor ?? theme.colorScheme.primary;
    return PopupMenuButton<int>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tooltip: 'User menu',
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Row(
            children: [
              const Icon(Icons.person, size: 20),
              const SizedBox(width: 8),
              Text(userName),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              const Icon(Icons.verified_user, size: 20),
              const SizedBox(width: 8),
              Text(userRole),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              const Icon(Icons.logout, size: 20, color: Colors.red),
              const SizedBox(width: 8),
              Text('Logout', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 2) onLogout();
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: c.withOpacity(0.15),
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: theme.textTheme.titleMedium?.copyWith(
                color: c,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName, style: theme.textTheme.titleSmall?.copyWith(color: c)),
              Text(userRole, style: theme.textTheme.labelMedium?.copyWith(color: c.withOpacity(0.85))),
            ],
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, color: c.withOpacity(0.9)),
        ],
      ),
    );
  }
}
