import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/data/providers/auth_provider.dart';
import '../../../../core/constants/api_constants.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/edit-profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user?.profilePicture != null
                  ? NetworkImage('${ApiConstants.serverUrl}${user!.profilePicture}')
                  : const NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1780&auto=format&fit=crop') as ImageProvider,
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'Guest User',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? 'Sign in to view profile',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: const Text('My Orders'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/orders'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Addresses'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/address'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.payment_outlined),
              title: const Text('Payment Methods'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/payment-methods'),
            ),
            const Divider(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
