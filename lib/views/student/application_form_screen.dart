// ** Student Numbers: XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX
// ** Student Names  : Name 1, Name 2, Name 3, Name 4, Name 5
// ** Question: Application Form Screen

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key});

  @override
  State<ApplicationFormScreen> createState() =>
      _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _module1NameController = TextEditingController();
  final _module2NameController = TextEditingController();

  int? _yearOfStudy;
  String? _module1Level;
  String? _module2Level;
  bool _addSecondModule = false;
  bool _isEligible = false;
  File? _selectedDocument;
  String? _documentName;

  final List<int> _yearOptions = [1, 2, 3];
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
  void dispose() {
    _module1NameController.dispose();
    _module2NameController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedDocument = File(result.files.single.path!);
        _documentName = result.files.single.name;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isEligible) {
      _showSnackbar(
        'Please confirm your eligibility before submitting.',
        isError: true,
      );
      return;
    }

    final authViewModel = context.read<AuthViewModel>();
    final appViewModel = context.read<ApplicationViewModel>();
    final studentId = authViewModel.currentUser?.id ?? '';

    final success = await appViewModel.submitApplication(
      studentId: studentId,
      yearOfStudy: _yearOfStudy!,
      module1Level: _module1Level!,
      module1Name: _module1NameController.text.trim(),
      module2Level: _addSecondModule ? _module2Level : null,
      module2Name: _addSecondModule
          ? _module2NameController.text.trim()
          : null,
      isEligible: _isEligible,
      documentFile: _selectedDocument,
    );

    if (!mounted) return;

    if (success) {
      _showSnackbar('Application submitted successfully!');
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
          'Apply for Student Assistant',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<ApplicationViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (viewModel.state == ApplicationState.error)
                    _buildErrorBanner(
                        viewModel.errorMessage ?? 'Something went wrong'),

                  _buildSectionCard(
                    title: 'Personal Information',
                    icon: Icons.person_outline,
                    children: [_buildYearDropdown()],
                  ),
                  const SizedBox(height: 16),

                  _buildSectionCard(
                    title: 'Primary Module Application',
                    icon: Icons.book_outlined,
                    children: [
                      _buildLevelDropdown(
                        label: 'Academic Level',
                        value: _module1Level,
                        onChanged: (val) => setState(() {
                          _module1Level = val;
                          _module1NameController.clear();
                        }),
                      ),
                      const SizedBox(height: 14),
                      _buildModuleDropdown(
                        label: 'Module',
                        level: _module1Level,
                        controller: _module1NameController,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildSectionCard(
                    title: 'Second Module (Optional)',
                    icon: Icons.book_outlined,
                    children: [
                      Row(
                        children: [
                          Switch(
                            value: _addSecondModule,
                            onChanged: (val) => setState(() {
                              _addSecondModule = val;
                              if (!val) {
                                _module2Level = null;
                                _module2NameController.clear();
                              }
                            }),
                            activeColor: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _addSecondModule
                                ? 'Adding second module'
                                : 'Add a second module',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      if (_addSecondModule) ...[
                        const SizedBox(height: 14),
                        _buildLevelDropdown(
                          label: 'Academic Level',
                          value: _module2Level,
                          onChanged: (val) => setState(() {
                            _module2Level = val;
                            _module2NameController.clear();
                          }),
                        ),
                        const SizedBox(height: 14),
                        _buildModuleDropdown(
                          label: 'Module',
                          level: _module2Level,
                          controller: _module2NameController,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildSectionCard(
                    title: 'Supporting Documentation',
                    icon: Icons.upload_file_outlined,
                    children: [
                      Text(
                        'Upload your academic transcript or proof of eligibility (PDF only).',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickDocument,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedDocument != null
                                  ? Colors.blue
                                  : Colors.grey[400]!,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            color: _selectedDocument != null
                                ? Colors.blue[50]
                                : Colors.grey[50],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _selectedDocument != null
                                    ? Icons.check_circle_outline
                                    : Icons.upload_file_outlined,
                                color: _selectedDocument != null
                                    ? Colors.blue
                                    : Colors.grey[500],
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _documentName ?? 'Tap to select PDF',
                                style: TextStyle(
                                  color: _selectedDocument != null
                                      ? Colors.blue[700]
                                      : Colors.grey[600],
                                  fontWeight: _selectedDocument != null
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildSectionCard(
                    title: 'Eligibility Confirmation',
                    icon: Icons.verified_outlined,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber[200]!),
                        ),
                        child: Text(
                          'Note: Eligibility decisions are made by administrative staff. '
                          'By checking this box, you confirm that you believe '
                          'you meet the minimum requirements for this position.',
                          style: TextStyle(
                            color: Colors.amber[900],
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        value: _isEligible,
                        onChanged: (val) =>
                            setState(() => _isEligible = val ?? false),
                        title: const Text(
                          'I confirm that I meet the minimum requirements',
                          style: TextStyle(fontSize: 14),
                        ),
                        activeColor: Colors.blue,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          viewModel.isLoading ? null : _handleSubmit,
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
                              'Submit Application',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
            Row(
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
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildYearDropdown() {
    return DropdownButtonFormField<int>(
      value: _yearOfStudy,
      decoration: const InputDecoration(
        labelText: 'Current Year of Study',
        prefixIcon: Icon(Icons.school_outlined),
        border: OutlineInputBorder(),
      ),
      items: _yearOptions
          .map((year) => DropdownMenuItem(
                value: year,
                child: Text('Year $year'),
              ))
          .toList(),
      onChanged: (val) => setState(() => _yearOfStudy = val),
      validator: (val) =>
          val == null ? 'Please select your year of study' : null,
    );
  }

  Widget _buildLevelDropdown({
    required String label,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.filter_list_outlined),
        border: const OutlineInputBorder(),
      ),
      items: _levelOptions
          .map((level) => DropdownMenuItem(
                value: level,
                child: Text(level),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (val) =>
          val == null ? 'Please select an academic level' : null,
    );
  }

 Widget _buildModuleDropdown({
    required String label,
    required String? level,
    required TextEditingController controller,
  }) {
    final modules =
        level != null ? (_modulesByLevel[level] ?? <String>[]) : <String>[];

    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.menu_book_outlined),
        border: const OutlineInputBorder(),
      ),
      items: modules
          .map<DropdownMenuItem<String>>((module) => DropdownMenuItem<String>(
                value: module,
                child: Text(module),
              ))
          .toList(),
      onChanged: level == null
          ? null
          : (val) => setState(() => controller.text = val ?? ''),
      validator: (val) =>
          val == null || val.isEmpty ? 'Please select a module' : null,
      hint: level == null
          ? const Text('Select a level first')
          : const Text('Select a module'),
    );
  }
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }
