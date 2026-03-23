import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/products/providers/notification_provider.dart';
import '../core/providers/theme_provider.dart';

class HeaderBar extends StatelessWidget {
  final String title;
  const HeaderBar({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeModeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    final Color headerColor = themeProvider.headerFullColor
        ? (themeProvider.customPrimaryColor ?? Theme.of(context).primaryColor)
        : Theme.of(context).scaffoldBackgroundColor;

    final isMobile = MediaQuery.of(context).size.width < 500;
    return Container(
      height: isMobile ? 64 : 72,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 24, vertical: isMobile ? 4 : 0),
      decoration: BoxDecoration(
        color: headerColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        spacing: 8,
        runSpacing: 4,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? 160 : 320),
            child: Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 18 : 28,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ),
          if (!isMobile) ...[
            Container(
              width: 200,
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : const Color(0xFFF3F4F6),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    Navigator.of(context).pushNamed('/product-search', arguments: value);
                  }
                },
              ),
            ),
            Consumer<NotificationProvider>(
              builder: (context, notificationProvider, child) {
                final unreadCount = notificationProvider.notifications.where((n) => !n.isRead).length;
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        _showNotificationsDialog(context, notificationProvider);
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final userInitial = authProvider.email?.isNotEmpty == true
                  ? authProvider.email![0].toUpperCase()
                  : 'U';
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF1B5E20),
                    child: Text(userInitial, style: const TextStyle(color: Colors.white)),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 8),
                    Text(authProvider.email ?? 'Guest', style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(width: 8),
                    PopupMenuButton<int>(
                      itemBuilder: (context) => [
                        const PopupMenuItem<int>(
                          value: 0,
                          child: Row(children: [Icon(Icons.person, size: 20), SizedBox(width: 8), Text('Profile')]),
                        ),
                        const PopupMenuItem<int>(
                          value: 1,
                          child: Row(children: [Icon(Icons.settings, size: 20), SizedBox(width: 8), Text('Settings')]),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 0) {
                          // Profile
                        } else if (value == 1) {
                          Navigator.of(context).pushNamed('/settings');
                        }
                      },
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: 300,
          child: provider.notifications.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No new notifications'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = provider.notifications[index];
                    return ListTile(
                      title: Text(notification.title),
                      subtitle: Text(notification.message),
                      leading: Icon(
                        notification.isRead ? Icons.notifications_none : Icons.notifications_active,
                        color: notification.isRead ? Colors.grey : Colors.blue,
                      ),
                      onTap: () {
                        provider.markAsRead(notification.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
