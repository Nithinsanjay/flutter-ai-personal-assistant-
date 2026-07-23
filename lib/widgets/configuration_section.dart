import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/model_viewmodel.dart';
import '../models/model_info.dart';

class ConfigurationSection extends StatelessWidget {
  const ConfigurationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final modelViewModel = Provider.of<ModelViewModel>(context);

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
        children: modelViewModel.models.map((model) {
          return _buildModelCard(context, modelViewModel, model);
        }).toList(),
      ),
    );
  }

  Widget _buildModelCard(
    BuildContext context,
    ModelViewModel modelViewModel,
    ModelInfo model,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: model.status == 'connected'
              ? Colors.teal.shade200
              : const Color(0xFFE2E8F0),
          width: model.status == 'connected' ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section (Icon & Label & Size)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: model.status == 'connected'
                        ? Colors.teal.shade50
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: model.status == 'connected'
                        ? Colors.teal.shade700
                        : const Color(0xFF475569),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            model.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (model.status == 'connected')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.teal.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        model.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${model.sizeGB.toStringAsFixed(1)} GB",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // State-driven UI
            if (model.status == 'download') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => modelViewModel.startDownload(model),
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
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF4F46E5),
                            ),
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
                    onPressed: () => modelViewModel.cancelDownload(model),
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
                      onPressed: () => modelViewModel.connectModel(model),
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
                      onPressed: () =>
                          _showDeleteConfirmation(context, modelViewModel, model),
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Initializing ${model.name}...",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Loading model files into local system memory",
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (model.status == 'connected') ...[
              Row(
                children: [
                  // Disconnect on left
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => modelViewModel.disconnectModel(model),
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
                      onPressed: () =>
                          _showDeleteConfirmation(context, modelViewModel, model),
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

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    ModelViewModel modelViewModel,
    ModelInfo model,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Model'),
        content: Text(
          'Are you sure you want to permanently delete "${model.name}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      modelViewModel.deleteModel(model);
    }
  }
}
