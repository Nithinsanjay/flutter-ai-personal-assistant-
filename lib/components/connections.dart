import 'package:flutter/material.dart';
import 'gmail.dart';
import 'microsoft.dart';

class ConnectionsSection extends StatelessWidget {
  const ConnectionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: false,
        title: const Text(
          'Connections',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Gmail · Microsoft 365'),
        leading: const Icon(Icons.link),
        childrenPadding: const EdgeInsets.all(12),
        children: const [
          GmailWidget(),
          SizedBox(height: 12),
          MicrosoftWidget(),
        ],
      ),
    );
  }
}
