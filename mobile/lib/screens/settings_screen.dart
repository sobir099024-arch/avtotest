import 'package:flutter/material.dart';
import '../app_state.dart';
import '../cloud_sync.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/app_scaffold.dart';

// Keep in sync with the version in pubspec.yaml.
const _appVersion = '1.0.0';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final user = appState.user;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(appT(context, 'navSettings'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          Text(appT(context, 'account'), style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 10),
          _Card(
            child: firebaseEnabled
                ? (user == null
                    ? ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.login_rounded, color: AppColors.primary),
                        title: Text(appT(context, 'signInGoogle')),
                        subtitle: Text(appT(context, 'notSignedIn'), style: TextStyle(color: Colors.grey.shade500)),
                        onTap: appState.signIn,
                      )
                    : ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                          child: user.photoURL == null
                              ? Text((user.displayName ?? user.email ?? '?')[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white))
                              : null,
                        ),
                        title: Text(user.displayName ?? user.email ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: user.email != null ? Text(user.email!, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                        trailing: TextButton.icon(
                          onPressed: appState.signOut,
                          icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.danger),
                          label: Text(appT(context, 'signOut'), style: const TextStyle(color: AppColors.danger)),
                        ),
                      ))
                : ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.cloud_off_rounded, color: Colors.grey.shade400),
                    title: Text(appT(context, 'notSignedIn'), style: TextStyle(color: Colors.grey.shade500)),
                  ),
          ),
          const SizedBox(height: 24),
          Text(appT(context, 'language'), style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 10),
          _Card(
            child: Column(
              children: [
                for (final l in AppLocale.values)
                  RadioListTile<AppLocale>(
                    contentPadding: EdgeInsets.zero,
                    value: l,
                    groupValue: appState.locale,
                    onChanged: (v) {
                      if (v != null) appState.setLocale(v);
                    },
                    title: Text(l.label),
                    activeColor: AppColors.primary,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '${appT(context, 'appVersion')}: $_appVersion',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
}
