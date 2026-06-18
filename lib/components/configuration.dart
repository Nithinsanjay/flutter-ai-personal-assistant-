import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class ConfigurationSection extends StatelessWidget {
  const ConfigurationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        title: const Text(
          'Configuration Models',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        subtitle: const Text(
          'Select and manage on-device models',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.psychology,
            color: Color(0xFF7C3AED),
            size: 18,
          ),
        ),
        childrenPadding: const EdgeInsets.all(12),
        children: appState.models.map((model) {
          return _buildModelCard(context, appState, model);
        }).toList(),
      ),
    );
  }

  // ✅ Helper method, not overriding anything
  Widget _buildModelCard(
    BuildContext context,
    AppState appState,
    ModelInfo model,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with Connected badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  model.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (model.status == 'connected')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Connected ✅',
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.download, size: 18, color: Color(0xFF4F46E5)),
                const SizedBox(width: 6),
                Text('${model.sizeGB} GB'),
              ],
            ),
            const SizedBox(height: 8),
            Text(model.description),
            const SizedBox(height: 12),

            // State-driven UI
            if (model.status == 'download') ...[
              SizedBox(
                width: double.infinity, // full width button
                child: ElevatedButton(
                  onPressed: () => appState.startDownload(model),
                  child: const Text('Download'),
                ),
              ),
            ] else if (model.status == 'downloading') ...[
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  LinearProgressIndicator(value: model.progress),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      "${(model.progress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (model.status == 'downloaded') ...[
              Row(
                children: [
                  // Connect on left
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => appState.connectModel(model),
                      icon: const Icon(Icons.link, size: 18),
                      label: const Text('Connect'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Delete on right
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => appState.deleteModel(model),
                      icon: const Icon(Icons.delete_forever, size: 18),
                      label: const Text('Delete'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (model.status == 'connecting') ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              const Text("Connecting…"),
            ] else if (model.status == 'connected') ...[
              Row(
                children: [
                  // Disconnect on left
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => appState.disconnectModel(model),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Disconnect'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Delete on right
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => appState.deleteModel(model),
                      icon: const Icon(Icons.delete_forever, size: 18),
                      label: const Text('Delete'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
