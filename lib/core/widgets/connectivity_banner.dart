import 'package:flutter/material.dart';

/// Reusable connectivity banner
/// Shows when device is offline
class ConnectivityBanner extends StatelessWidget {
  final bool isOffline;
  final String message;

  const ConnectivityBanner({
    super.key,
    required this.isOffline,
    this.message = 'Offline mode - Showing saved data',
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.orange.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.orange.shade900),
            ),
          ),
        ],
      ),
    );
  }
}
