import 'package:flutter/material.dart';
import 'package:testproject/core/utils/admin_helper.dart';

/// TEMPORARY ADMIN SETUP SCREEN
///
/// This screen is ONLY for development/testing purposes.
/// Use it to quickly make users admin without going to Firebase Console.
///
/// ⚠️ REMOVE THIS FILE IN PRODUCTION!
///
/// To use:
/// 1. Add this screen to your routes temporarily
/// 2. Navigate to it from anywhere
/// 3. Enter user email and click "Make Admin"
/// 4. Remove this file before deploying to production
class DevAdminSetupScreen extends StatefulWidget {
  const DevAdminSetupScreen({super.key});

  @override
  State<DevAdminSetupScreen> createState() => _DevAdminSetupScreenState();
}

class _DevAdminSetupScreenState extends State<DevAdminSetupScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  List<Map<String, dynamic>> _admins = [];

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadAdmins() async {
    setState(() => _isLoading = true);
    final admins = await AdminHelper.listAllAdmins();
    setState(() {
      _admins = admins;
      _isLoading = false;
    });
  }

  Future<void> _makeAdmin() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _message = '❌ Please enter an email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final success = await AdminHelper.makeUserAdmin(email);

    setState(() {
      _isLoading = false;
      _message = success
          ? '✅ User $email is now an admin!'
          : '❌ Failed to make user admin. Check if email exists.';
    });

    if (success) {
      _emailController.clear();
      _loadAdmins();
    }
  }

  Future<void> _removeAdmin(String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Admin'),
        content: Text('Remove admin role from $email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    final success = await AdminHelper.removeAdminRole(email);
    setState(() {
      _isLoading = false;
      _message = success
          ? '✅ Admin role removed from $email'
          : '❌ Failed to remove admin role';
    });

    if (success) {
      _loadAdmins();
    }
  }

  Future<void> _checkAdmin() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _message = '❌ Please enter an email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final isAdmin = await AdminHelper.checkIfUserIsAdmin(email);

    setState(() {
      _isLoading = false;
      _message = isAdmin
          ? '✅ User $email is an admin'
          : '❌ User $email is NOT an admin';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Dev Admin Setup'),
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Warning Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.warning, color: Colors.red, size: 32),
                        SizedBox(height: 8),
                        Text(
                          '⚠️ DEVELOPMENT ONLY',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Remove this screen before production!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Input Section
                  const Text(
                    'Make User Admin',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'User Email',
                      hintText: 'user@example.com',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _makeAdmin,
                          icon: const Icon(Icons.admin_panel_settings),
                          label: const Text('Make Admin'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _checkAdmin,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Check'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Message Display
                  if (_message != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _message!.startsWith('✅')
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _message!,
                        style: TextStyle(
                          color: _message!.startsWith('✅')
                              ? Colors.green.shade900
                              : Colors.red.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Current Admins List
                  const Text(
                    'Current Admins',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  if (_admins.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'No admins found. Create one above!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ...(_admins
                        .map(
                          (admin) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.admin_panel_settings),
                              ),
                              title: Text(admin['fullName'] ?? 'Unknown'),
                              subtitle: Text(admin['email'] ?? 'No email'),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeAdmin(admin['email']),
                                tooltip: 'Remove Admin Role',
                              ),
                            ),
                          ),
                        )
                        .toList()),

                  const SizedBox(height: 24),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '📋 Instructions:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('1. Sign up a new user in the app'),
                        Text('2. Enter their email above'),
                        Text('3. Click "Make Admin"'),
                        Text('4. User signs out and back in'),
                        Text('5. User now has admin access!'),
                        SizedBox(height: 12),
                        Text(
                          '⚠️ Remember to remove this screen in production!',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Refresh Button
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _loadAdmins,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Admin List'),
                  ),
                ],
              ),
            ),
    );
  }
}
