import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_4/viewmodels/index.dart';
import 'package:flutter_application_4/models/index.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final StudentApplication application;

  const ApplicationDetailScreen({
    super.key,
    required this.application,
  });

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  late StudentApplication _application;

  @override
  void initState() {
    super.initState();
    _application = widget.application;
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text(
          'Are you sure you want to delete this application? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteApplication();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteApplication() async {
    final appViewModel = context.read<ApplicationViewModel>();
    final success =
        await appViewModel.deleteApplication(_application.id);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appViewModel.error ?? 'Failed to delete application'),
        ),
      );
    }
  }

  void _editApplication() {
    Navigator.of(context)
        .pushNamed(
          '/application-form',
          arguments: _application,
        )
        .then((result) {
          if (result == true) {
            // Refresh application list
            Navigator.of(context).pop();
          }
        });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        actions: [
          if (_application.status == 'pending')
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: _editApplication,
                  child: const Text('Edit'),
                ),
                PopupMenuItem(
                  onTap: _showDeleteConfirmation,
                  child: const Text('Delete'),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(_application.status)
                    .withOpacity(0.1),
                border: Border.all(
                  color: _getStatusColor(_application.status),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _application.status == 'approved'
                        ? Icons.check_circle
                        : _application.status == 'rejected'
                            ? Icons.cancel
                            : Icons.hourglass_empty,
                    color: _getStatusColor(_application.status),
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Application Status',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        _application.status.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: _getStatusColor(_application.status),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Application Info Section
            Text(
              'Application Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'Application ID',
              value: _application.id,
            ),
            _InfoRow(
              label: 'Year of Study',
              value: _application.yearOfStudy,
            ),
            _InfoRow(
              label: 'Meets Requirements',
              value: _application.meetsRequirements ? 'Yes' : 'No',
            ),
            _InfoRow(
              label: 'Submitted',
              value: _application.createdAt.split('T').first,
            ),
            _InfoRow(
              label: 'Last Updated',
              value: _application.updatedAt.split('T').first,
            ),
            const SizedBox(height: 24),

            // Applied Modules Section
            Text(
              'Applied Modules',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (_application.module1 == null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No modules selected',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              )
            else
              Column(
                children: [
                  _buildModuleCard(context, _application.module1!, 'Primary Module'),
                  if (_application.module2 != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _buildModuleCard(context, _application.module2!, 'Secondary Module'),
                    ),
                ],
              ),
            if (_application.adminNotes != null && _application.adminNotes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Admin Notes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _application.adminNotes!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, Module module, String label) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              module.name,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${module.code} - ${module.level}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
