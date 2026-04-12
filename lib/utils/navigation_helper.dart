import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routing/app_router.dart';

class NavigationHelper {
  static int getCurrentTabIndex(String location, bool isAdmin) {
    if (location.contains(AppRoutes.wallet)) return 1;
    if (location.contains(AppRoutes.profile)) return 2;
    if (isAdmin && location.contains(AppRoutes.admin)) return 3;
    return 0;
  }

  static void navigateToTab(BuildContext context, int index, bool isAdmin) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.wallet);
        break;
      case 2:
        context.go(AppRoutes.profile);
        break;
      case 3:
        if (isAdmin) context.go(AppRoutes.admin);
        break;
    }
  }
}
