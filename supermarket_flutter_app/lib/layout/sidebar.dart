import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({required this.selectedIndex, required this.onItemSelected, super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _SidebarItem(Icons.dashboard, 'Dashboard'),
      _SidebarItem(Icons.inventory, 'Products'),
      _SidebarItem(Icons.category, 'Categories'),
      _SidebarItem(Icons.shopping_cart, 'Cart'),
      _SidebarItem(Icons.people, 'Employees'),
      _SidebarItem(Icons.bar_chart, 'Reports'),
      _SidebarItem(Icons.settings, 'Settings'),
    ];

    final isMobile = MediaQuery.of(context).size.width < 500;
    if (isMobile) {
      // Use Drawer for mobile, but keep this for completeness
      return const SizedBox.shrink();
    }
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20),
        borderRadius: const BorderRadius.only(topRight: Radius.circular(32), bottomRight: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 0))],
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Logo
          Icon(Icons.store, size: 48, color: Colors.white),
          const SizedBox(height: 32),
          ...List.generate(items.length, (i) {
            final item = items[i];
            final isActive = i == selectedIndex;
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onItemSelected(i),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(item.icon, color: Colors.white),
                      const SizedBox(width: 16),
                      Text(item.label, style: TextStyle(color: Colors.white, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
                    ],
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
        ],
      ),
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  _SidebarItem(this.icon, this.label);
}
