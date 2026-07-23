import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/connectivity_viewmodel.dart';
import '../viewmodels/workflow_viewmodel.dart';
import '../viewmodels/model_viewmodel.dart';

class GmailWidget extends StatefulWidget {
  const GmailWidget({super.key});

  @override
  State<GmailWidget> createState() => _GmailWidgetState();
}

class _GmailWidgetState extends State<GmailWidget> {
  bool _isConnecting = false;

  Future<void> _handleConnect(
    BuildContext context,
    ConnectivityViewModel connectivity,
    WorkflowViewModel workflow,
    ModelViewModel model,
  ) async {
    setState(() {
      _isConnecting = true;
    });

    try {
      final email = await connectivity.initiateGmailOAuthFlow();
      await connectivity.connectGmail(email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gmail account $email connected!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
      // Trigger initial sync on connection
      await workflow.syncGmail(
        gmailConnected: true,
        aiActive: model.connectedModel != null,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Connection failed: ${e.toString().replaceAll('Exception:', '').trim()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityViewModel>();
    final workflow = context.watch<WorkflowViewModel>();
    final model = context.watch<ModelViewModel>();

    final isConnected = connectivity.isGmailConnected;
    final isSyncing = workflow.isGmailSyncing;
    final emailAddress = connectivity.gmailEmail;

    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isConnected
                      ? Colors.red.shade50
                      : Colors.grey.shade100,
                  child: Icon(
                    Icons.email,
                    color: isConnected ? Colors.red : Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gmail',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        isConnected
                            ? emailAddress
                            : 'Connect your Google account',
                        style: TextStyle(
                          fontSize: 12,
                          color: isConnected
                              ? const Color(0xFF334155)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  isConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(
                    color: isConnected ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isConnected) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isSyncing
                          ? null
                          : () async {
                              try {
                                await workflow.syncGmail(
                                  gmailConnected: connectivity.isGmailConnected,
                                  aiActive: model.connectedModel != null,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Gmail synchronized successfully!',
                                      ),
                                      backgroundColor: Color(0xFF10B981),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Sync failed: ${e.toString().replaceAll('Exception:', '').trim()}',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      icon: isSyncing
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF4F46E5),
                                ),
                              ),
                            )
                          : const Icon(Icons.sync, size: 16),
                      label: Text(isSyncing ? 'Syncing...' : 'Sync Now'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isSyncing
                          ? null
                          : () async {
                              await connectivity.disconnectGmail();
                              workflow.clearGmailData();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Gmail account disconnected.',
                                    ),
                                    backgroundColor: Color(0xFF4F46E5),
                                  ),
                                );
                              }
                            },
                      icon: const Icon(Icons.link_off, size: 16),
                      label: const Text('Disconnect'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        foregroundColor: Colors.red.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isConnecting
                      ? null
                      : () => _handleConnect(context, connectivity, workflow, model),
                  icon: _isConnecting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.link, size: 18),
                  label: Text(
                    _isConnecting ? 'Connecting...' : 'Connect Gmail',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF818CF8),
                    disabledForegroundColor: Colors.white.withValues(
                      alpha: 0.8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
