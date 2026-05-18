// ** Student Numbers: XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX
// ** Student Names  : Name 1, Name 2, Name 3, Name 4, Name 5
// ** Question: Application Detail Screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../models/application_model.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final String applicationId;

  const ApplicationDetailScreen({
    super.key,
    required this.applicationId,
  });

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState
    extends State<ApplicationDetailScreen> {
  ApplicationModel? _application;
  final _module1NameController = TextEditingController();
  final _module2NameController = TextEditingController();
  String? _editModule1Level;
  String? _editModule2Level;
  bool _isEditing = false;

  final List<String> _levelOptions = [
    'First Year',
    'Second Year',
    'Third Year',
  ];

  final Map<String, List<String>> _modulesByLevel = {
    'First Year': [
      'Introduction to Programming',
      'Computer Literacy',
      'Mathematics I',
      'Information Systems I',
    ],
    'Second Year': [
      'Data Structures',
      'Object Oriented Programming',
      'Database Management',
      'Systems Analysis',
    ],
    'Third Year': [
      'Software Engineering',
      'Mobile Development',
      'Network Administration',
      'Project Management',
    ],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadApplication();
    });
  }

  void _loadApplication() {
    final viewModel = context.read<ApplicationViewModel>();
    final application = viewModel.applications.firstWhere(
      (a) => a.id == widget.applicationId,
      orElse: () => viewModel.applications.first,
    );
    setState(() {
      _application = application;
      _editModule1Level = application.module1Level;
      _editModule2Level = application.module2Level;
      _module1NameController.text = application.module1Name;
      _module2NameController.text = application.module2Name ?? '';
    });
  }

  @override
  void dispose() {
    _module1NameController.dispose();
    _module2NameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_application == null) return;

    final viewModel = context.read<ApplicationViewModel>();

    final updates = {
      'module_1_level': _editModule1Level,
      'module_1_name': _module1NameController.text.trim(),
      'module_2_level': _editModule2Level,
      'module_2_name': _module2NameController.text.trim().isEmpty
          ? null
          : _module2NameController.text.trim(),
    };

    final success =
        await viewModel.updateApplication(_application!.id, updates);

    if (!mounted) return;

    if (success) {
      setState(() => _isEditing = false);
      _loadApplication();
      _showSnackbar('Application updated successfully!');
    }
  }

  Future<void> _handleDelete() async {
    if (_application == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Application'),
        content: const Text(
          'Are you sure you want to delete this application? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final viewModel = context.read<ApplicationViewModel>();
    final success = await viewModel.deleteApplication(_application!.id);

    if (!mounted) return;

    if (success) {
      _showSnackbar('Application deleted.');
      context.go('/home');
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text(
          'Application Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_application != null && _application!.isPending) ...[
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => setState(() => _isEditing = true),
                tooltip: 'Edit',
              ),
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() => _isEditing = false);
                  _loadApplication();
                },
                tooltip: 'Cancel',
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _handleDelete,
              tooltip: 'Delete',
            ),
          ],
        ],
      ),
      body: Consumer<ApplicationViewModel>(
        builder: (context, viewModel, child) {
          if (_application == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBanner(_application!.status),
                const SizedBox(height: 16),

                if (_isEditing) _buildEditNoticeBanner(),
                if (_isEditing) const SizedBox(height: 16),

                _buildDetailsCard(viewModel),
                const SizedBox(height: 16),

                _buildDocumentCard(),
                const SizedBox(height: 16),

                if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          viewModel.isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: viewModel.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                if (!_isEditing && _application!.isPending)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed:
                          viewModel.isLoading ? null : _handleDelete,
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red),
                      label: const Text(
                        'Delete Application',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBanner(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String message;

    switch (status) {
      case 'approved':
        bgColor = Colors.green[50]!;
        textColor = Colors.green[800]!;
        icon = Icons.check_circle_outline;
        message = 'Your application has been approved!';
        break;
      case 'rejected':
        bgColor = Colors.red[50]!;
        textColor = Colors.red[800]!;
        icon = Icons.cancel_outlined;
        message = 'Your application was not successful.';
        break;
      default:
        bgColor = Colors.orange[50]!;
        textColor = Colors.orange[800]!;
        icon = Icons.hourglass_empty;
        message = 'Your application is under review.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(color: textColor, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditNoticeBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You are editing your application. '
              'Changes are only saved when you tap Save Changes.',
              style: TextStyle(color: Colors.blue[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(ApplicationViewModel viewModel) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(Icons.book_outlined, 'Application Details'),
            const Divider(height: 20),

            _buildReadOnlyRow(
              label: 'Year of Study',
              value: 'Year ${_application!.yearOfStudy}',
            ),
            const SizedBox(height: 16),

            const Text(
              'Primary Module',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            if (_isEditing) ...[
              _buildEditLevelDropdown(
                label: 'Academic Level',
                value: _editModule1Level,
                onChanged: (val) => setState(() {
                  _editModule1Level = val;
                  _module1NameController.clear();
                }),
              ),
              const SizedBox(height: 10),
              _buildEditModuleDropdown(
                label: 'Module',
                level: _editModule1Level,
                controller: _module1NameController,
              ),
            ] else ...[
              _buildReadOnlyRow(
                  label: 'Level', value: _application!.module1Level),
              const SizedBox(height: 8),
              _buildReadOnlyRow(
                  label: 'Module', value: _application!.module1Name),
            ],

            if (_application!.module2Name != null ||
                _application!.module2Level != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Second Module',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              if (_isEditing) ...[
                _buildEditLevelDropdown(
                  label: 'Academic Level',
                  value: _editModule2Level,
                  onChanged: (val) => setState(() {
                    _editModule2Level = val;
                    _module2NameController.clear();
                  }),
                ),
                const SizedBox(height: 10),
                _buildEditModuleDropdown(
                  label: 'Module',
                  level: _editModule2Level,
                  controller: _module2NameController,
                ),
              ] else ...[
                _buildReadOnlyRow(
                    label: 'Level',
                    value: _application!.module2Level ?? '-'),
                const SizedBox(height: 8),
                _buildReadOnlyRow(
                    label: 'Module',
                    value: _application!.module2Name ?? '-'),
              ],
            ],

            const SizedBox(height: 16),
            _buildReadOnlyRow(
              label: 'Submitted',
              value: _formatDate(_application!.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(
                Icons.upload_file_outlined, 'Supporting Document'),
            const Divider(height: 20),
            if (_application!.documentUrl != null)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.picture_as_pdf,
                        color: Colors.blue[700]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Document uploaded',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Tap to view',
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.open_in_new,
                      color: Colors.blue[600], size: 18),
                ],
              )
            else
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[500]),
                  const SizedBox(width: 10),
                  Text(
                    'No document uploaded',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyRow({
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditLevelDropdown({
    required String label,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: _levelOptions
          .map((level) => DropdownMenuItem(
                value: level,
                child: Text(level,
                    style: const TextStyle(fontSize: 13)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildEditModuleDropdown({
    required String label,
    required String? level,
    required TextEditingController controller,
  }) {
    final modules =
        level != null ? (_modulesByLevel[level] ?? []) : [];

    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    items: modules
    .map<DropdownMenuItem<String>>((module) => DropdownMenuItem<String>(
          value: module,
          child: Text(module,
              style: const TextStyle(fontSize: 13)),
        ))
    .toList(),
      onChanged: level == null
          ? null
          : (val) => setState(() => controller.text = val ?? ''),
      hint: level == null
          ? const Text('Select a level first',
              style: TextStyle(fontSize: 13))
          : const Text('Select a module',
              style: TextStyle(fontSize: 13)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}