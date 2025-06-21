import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wlog/core/common/entities/user.dart';

class ProfileInfoCard extends StatelessWidget {
  final UserEntity user;

  const ProfileInfoCard({
    super.key,
    required this.user,
  });

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Title
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Account Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Full Name
            _buildInfoRow(
              context,
              icon: Icons.person_outline,
              label: 'Full Name',
              value: user.name,
              onTap: () => _copyToClipboard(context, user.name, 'Name'),
            ),
            const Divider(),
            
            // Email
            _buildInfoRow(
              context,
              icon: Icons.email_outlined,
              label: 'Email Address',
              value: user.email,
              onTap: () => _copyToClipboard(context, user.email, 'Email'),
            ),
            const Divider(),
            
            // User ID
            _buildInfoRow(
              context,
              icon: Icons.fingerprint,
              label: 'User ID',
              value: user.id,
              onTap: () => _copyToClipboard(context, user.id, 'User ID'),
              isMonospace: true,
            ),
            
            const SizedBox(height: 12),
            
            // Copy hint
            Row(
              children: [
                Icon(
                  Icons.touch_app,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Tap any field to copy',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    bool isMonospace = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: isMonospace ? 'monospace' : null,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.copy,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
