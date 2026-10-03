import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccessDeniedPage extends StatelessWidget {
  const AccessDeniedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final email =
        Supabase.instance.client.auth.currentUser?.email ?? 'Akun terautentikasi';

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 44),
                    const SizedBox(height: 16),
                    Text(
                      'Akses aplikasi belum dikonfigurasi',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Akun $email belum memiliki role aplikasi yang aktif. '
                      'Hubungi administrator untuk menetapkan role dan scope POMDAM.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut(
                          scope: SignOutScope.local,
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Keluar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
