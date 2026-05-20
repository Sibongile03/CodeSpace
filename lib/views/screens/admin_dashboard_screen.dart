/*223056129 Mokoena SP , 224085810 BBL NTSUTLE, 222019937 Melupe NE, 224120806 Maseko O, 223085941 TSM MATJENI*/ 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_4/viewmodels/index.dart';
import 'package:flutter_application_4/models/index.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  void _loadApplications() {
    context.read<AdminViewModel>().fetchAllApplications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Sign Out'),
                onTap: () {
                  context.read<AuthViewModel>().signOut();
                },
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadApplications();
        },
        child: Consumer<AdminViewModel>(
          builder: (context, adminViewModel, _) {
            if (adminViewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // Filter Chips
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          isSelected: adminViewModel.filterStatus == 'all',
                          onTap: () => adminViewModel.setFilter('all'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Pending',
                          isSelected: adminViewModel.filterStatus == 'pending',
                          onTap: () => adminViewModel.setFilter('pending'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Approved',
                          isSelected: adminViewModel.filterStatus == 'approved',
                          onTap: () => adminViewModel.setFilter('approved'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Rejected',
                          isSelected: adminViewModel.filterStatus == 'rejected',
                          onTap: () => adminViewModel.setFilter('rejected'),
                        ),
                      ],
                    ),
                  ),
                ),
                // Applications List
                Expanded(
                  child: adminViewModel.filteredApplications.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No applications',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: adminViewModel.filteredApplications.length,
                          itemBuilder: (context, index) {
                            final app =
                                adminViewModel.filteredApplications[index];
                            return _ApplicationAdminCard(
                              application: app,
                              adminViewModel: adminViewModel,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }
}

class _ApplicationAdminCard extends StatefulWidget {
  final StudentApplication application;
  final AdminViewModel adminViewModel;

  const _ApplicationAdminCard({
    required this.application,
    required this.adminViewModel,
  });

  @override
  State<_ApplicationAdminCard> createState() => _ApplicationAdminCardState();
}

class _ApplicationAdminCardState extends State<_ApplicationAdminCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = false;
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text(
          'Are you sure you want to delete this application?',
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
    final success = await widget.adminViewModel.deleteApplication(
      widget.application.id,
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Application deleted')));
    }
  }

  Future<void> _approveApplication() async {
    final success = await widget.adminViewModel.approveApplication(
      widget.application.id,
      'approved',
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Application approved')));
    }
  }

  Future<void> _rejectApplication() async {
    final success = await widget.adminViewModel.rejectApplication(
      widget.application.id,
      'rejected',
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Application rejected')));
    }
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        onExpansionChanged: (expanded) {
          setState(() => _isExpanded = expanded);
        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App #${widget.application.id.substring(0, 8)}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  widget.application.yearOfStudy,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(
                  widget.application.status,
                ).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.application.status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(widget.application.status),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Applied Modules',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                if (widget.application.module1 != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '• ${widget.application.module1!.name} (${widget.application.module1!.code})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                if (widget.application.module2 != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '• ${widget.application.module2!.name} (${widget.application.module2!.code})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Meets Requirements: ${widget.application.meetsRequirements ? 'Yes' : 'No'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                if (widget.application.status == 'pending')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _approveApplication,
                        icon: const Icon(Icons.check),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _rejectApplication,
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showDeleteConfirmation,
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
