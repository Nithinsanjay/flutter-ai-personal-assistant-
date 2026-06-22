import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/model_info.dart';

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
                Expanded(
                  child: Text(
                    model.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
            if (model.localPath != null) ...[
              const SizedBox(height: 8),
              Text(
                'Saved at ${model.localPath}',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
            ],
            if (model.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                model.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
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
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: model.progress,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Downloading... ${(model.progress * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () => appState.cancelDownload(model),
                    icon: const Icon(Icons.close, color: Colors.red),
                    tooltip: 'Cancel Download',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      padding: const EdgeInsets.all(8),
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
