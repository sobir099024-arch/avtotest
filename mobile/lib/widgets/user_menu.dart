import 'package:flutter/material.dart';
import '../app_state.dart';
import '../cloud_sync.dart';
import '../theme.dart';
import 'app_scaffold.dart';

class UserMenu extends StatelessWidget {
  final Color? foreground;
  const UserMenu({super.key, this.foreground});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    if (!firebaseEnabled || appState.authLoading) return const SizedBox.shrink();

    final fg = foreground ?? AppColors.primary;
    final user = appState.user;

    if (user == null) {
      return TextButton.icon(
        onPressed: () => appState.signIn(),
        style: TextButton.styleFrom(
          foregroundColor: fg,
          backgroundColor: fg == Colors.white ? Colors.white.withValues(alpha: 0.16) : AppColors.primary.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        icon: const Icon(Icons.login_rounded, size: 16),
        label: Text(appT(context, 'signInGoogle'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      );
    }

    return PopupMenuButton<String>(
      tooltip: '',
      onSelected: (v) {
        if (v == 'signOut') appState.signOut();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Text(user.displayName ?? user.email ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        PopupMenuItem(
          value: 'signOut',
          child: Row(
            children: [
              const Icon(Icons.logout_rounded, size: 18, color: AppColors.danger),
              const SizedBox(width: 8),
              Text(appT(context, 'signOut'), style: const TextStyle(color: AppColors.danger)),
            ],
          ),
        ),
      ],
      child: CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.primary,
        backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
        child: user.photoURL == null
            ? Text(
                (user.displayName ?? user.email ?? '?')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              )
            : null,
      ),
    );
  }
}
