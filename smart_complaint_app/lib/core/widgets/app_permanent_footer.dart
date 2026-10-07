import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

/// Professional 4-destination bottom navigation bar for students
class AppPermanentFooter extends ConsumerWidget {
  final String currentRoute;
  final int? selectedIndex;
  final ValueChanged<int>? onItemTapped;

  const AppPermanentFooter({
    super.key,
    this.currentRoute = '/home',
    this.selectedIndex,
    this.onItemTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int activeIndex = selectedIndex ?? 0;
    if (selectedIndex == null) {
      if (currentRoute == '/my-complaints') {
        activeIndex = 1;
      } else if (currentRoute == '/submit-complaint') {
        activeIndex = 2;
      } else if (currentRoute == '/profile') {
        activeIndex = 3;
      } else {
        activeIndex = 0;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(color: context.colors.border, width: 1),
        ),
        boxShadow: AppShadows.bottomBar,
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: activeIndex.clamp(0, 3),
          onTap: (index) {
            if (onItemTapped != null) {
              onItemTapped!(index);
              return;
            }

            switch (index) {
              case 0:
                context.go('/home');
                break;
              case 1:
                context.go('/my-complaints');
                break;
              case 2:
                context.go('/submit-complaint');
                break;
              case 3:
                context.go('/profile');
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: context.colors.surface,
          selectedItemColor: context.colors.primaryAction,
          unselectedItemColor: context.colors.textSecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder_rounded),
              label: 'Complaints',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_rounded),
              activeIcon: Icon(Icons.add_circle_rounded),
              label: 'Submit',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
