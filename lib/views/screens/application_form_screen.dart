import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_4/viewmodels/index.dart';
import 'package:flutter_application_4/models/index.dart';

class ApplicationFormScreen extends StatefulWidget {
  final StudentApplication? existingApplication;

  const ApplicationFormScreen({
    super.key,
    this.existingApplication,
  });

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedYear;
  Module? _selectedModule1;
  Module? _selectedModule2;
  bool _meetsRequirements = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.existingApplication?.yearOfStudy ?? '1st Year';
    if (widget.existingApplication != null) {
      _selectedModule1 = widget.existingApplication!.module1;
      _selectedModule2 = widget.existingApplication!.module2;
      _meetsRequirements =
          widget.existingApplication!.meetsRequirements;
    }
    _loadModules();
  }

  void _loadModules() {
    final appViewModel = context.read<ApplicationViewModel>();
    appViewModel.fetchModulesByLevel(_selectedYear);
  }

  void _onYearChanged(String year) {
    setState(() {
      _selectedYear = year;
      _selectedModule1 = null;
      _selectedModule2 = null;
    });
    _loadModules();
  }

  void _selectModule1(Module module) {
    setState(() {
      _selectedModule1 = module;
    });
  }

  void _selectModule2(Module? module) {
    setState(() {
      _selectedModule2 = module;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedModule1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one module')),
      );
      return;
    }

    if (!_meetsRequirements) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must confirm you meet the requirements'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authViewModel = context.read<AuthViewModel>();
    final appViewModel = context.read<ApplicationViewModel>();
    final userId = authViewModel.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      setState(() => _isLoading = false);
      return;
    }

    bool success;
    if (widget.existingApplication != null) {
      success = await appViewModel.updateApplication(
        widget.existingApplication!.id,
        _selectedYear,
        _selectedModule1!,
        _selectedModule2,
        _meetsRequirements,
      );
    } else {
      success = await appViewModel.createApplication(
        userId,
        _selectedYear,
        _selectedModule1!,
        _selectedModule2,
        _meetsRequirements,
      );
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingApplication != null
              ? 'Application updated successfully'
              : 'Application submitted successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appViewModel.error ?? 'Failed to submit application'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingApplication != null
            ? 'Edit Application'
            : 'New Application'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Year of Study',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedYear,
                items: ['1st Year', '2nd Year', '3rd Year']
                    .map((year) => DropdownMenuItem(
                          value: year,
                          child: Text(year),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    _onYearChanged(value);
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Select Modules (1-2)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Consumer<ApplicationViewModel>(
                builder: (context, appViewModel, _) {
                  if (appViewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (appViewModel.modules.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No modules available for this year'),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appViewModel.modules.length,
                    itemBuilder: (context, index) {
                      final module = appViewModel.modules[index];
                      final isSelected = _selectedModule1?.id == module.id || 
                          _selectedModule2?.id == module.id;

                      return CheckboxListTile(
                        title: Text(module.name),
                        subtitle: Text(module.code),
                        value: isSelected,
                        onChanged: (_) {
                          if (isSelected) {
                            if (_selectedModule1?.id == module.id) {
                              _selectModule1(Module(id: '', name: '', code: '', level: ''));
                            } else if (_selectedModule2?.id == module.id) {
                              _selectModule2(null);
                            }
                          } else {
                            if (_selectedModule1 == null) {
                              _selectModule1(module);
                            } else if (_selectedModule2 == null) {
                              _selectModule2(module);
                            }
                          }
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              CheckboxListTile(
                title: const Text('I meet the minimum requirements'),
                subtitle: const Text(
                  'I confirm that I meet all eligibility requirements',
                ),
                value: _meetsRequirements,
                onChanged: (value) {
                  setState(() {
                    _meetsRequirements = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(widget.existingApplication != null
                          ? 'Update Application'
                          : 'Submit Application'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
