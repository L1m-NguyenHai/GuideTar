import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SidebarMenuItem {
  const SidebarMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
}

class AppSidebarPanel extends StatelessWidget {
  const AppSidebarPanel({
    super.key,
    required this.onClose,
    required this.items,
  });

  final VoidCallback onClose;
  final List<SidebarMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: 272,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x992A2A29),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: onClose,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < items.length; i++) ...[
                        _SidebarItem(menuItem: items[i]),
                        if (i != items.length - 1) const SizedBox(height: 45),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.menuItem});

  final SidebarMenuItem menuItem;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: menuItem.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: menuItem.active ? 134 : null,
        padding: EdgeInsets.symmetric(
          horizontal: menuItem.active ? 8 : 0,
          vertical: menuItem.active ? 10 : 0,
        ),
        decoration: menuItem.active
            ? BoxDecoration(
                color: const Color(0xFF325063),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFEFEF)),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(menuItem.icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              menuItem.label,
              style: GoogleFonts.splineSans(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 20 / 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
