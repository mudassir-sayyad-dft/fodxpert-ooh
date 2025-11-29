import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../res/base_getters.dart';
import '../../../res/colors.dart';
import '../../../res/routes/route_constants.dart';
import '../buttons/expanded_btn.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  final Function? onLogout;
  const LogoutConfirmationDialog({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: const Text("Confirm Logout!"),
      content: const Text("Are you sure you want to logout?"),
      actions: [
        Row(
          children: [
            ExpandedButton(
                onPressed: () {
                  AppServices.popView(context);
                  prefs.delete('user');
                  AppServices.pushAndRemove(RouteConstants.login);
                  if (onLogout != null) {
                    onLogout!();
                  }
                },
                title: "Yes, Logout"),
          ],
        ),
        Row(
          children: [
            ExpandedButton(
              onPressed: () {
                AppServices.popView(context);
              },
              title: "Cancel",
              color: Colors.transparent,
              foregroundColor: GetColors.primary,
            ),
          ],
        ),
      ],
    );
  }
}
