/**
 * Student Numbers: ADD YOUR STUDENT NUMBERS HERE
 * Student Names  : ADD YOUR NAMES HERE
 * Question: Application Form Screen
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_4/viewmodels/index.dart';
import 'package:flutter_application_4/models/index.dart';

class _C {
  static const navy = Color(0xFF1A237E);
  static const gold = Color(0xFFF9A825);
  static const white = Colors.white;
  static const grey = Color(0xFF757575);
  static const greyLight = Color(0xFFF5F5F5);
  static const greyBorder = Color(0xFFE0E0E0);
  static const green = Color(0xFF2E7D32);
}

class ApplicationFormScreen extends StatefulWidget {
  final StudentApplication? existingApplication;

  const ApplicationFormScreen({super.key, this.existingApplication});

  @override
  State<ApplicationFormScreen> createState() =>
      _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedYear;
  Module? _selectedModule1;
  Module? _selectedModule2;
  bool _meetsRequirements = false;
  bool _isLoading = false;

  final List<String> _years = ['1st Year', '2nd Year', '3rd Year'];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.existingApplication?.yearOfStudy ?? '1st Year';
    if (widget.existingApplication != null) {
      _selectedModule1 = widget.existingApplication!.module1;
      _selectedModule2 = widget.existingApplication!.module2;
      _meetsRequirements = widget.existingApplication!.meetsRequirements;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadModules());
  }

  void _loadModules() {
    context.read<ApplicationViewModel>().fetchModulesByLevel(_selectedYear);
  }

  void _onYearChanged(String year) {
    setState(() {
      _selectedYear = year;
      _selectedModule1 = null;
      _selectedModule2 = null;
    });
    context.read<ApplicationViewModel>().fetchModulesByLevel(year);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedModule1 == null) {
      _showSnack('Please select at least one module', isError: true);
      return;
    }
    if (!_meetsRequirements) {
      _showSnack('You must confirm you meet the requirements', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final authViewModel = context.read<AuthViewModel>();
    final appViewModel = context.read<ApplicationViewModel>();
    final userId = authViewModel.currentUser?.id;

    if (userId == null) {
      _showSnack('User not authenticated', isError: true);
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
      _showSnack(
        widget.existingApplication != null
            ? 'Application updated successfully'
            : 'Application submitted successfully',
        isError: false,
      );
      context.pop(true);
    } else {
      _showSnack(
          appViewModel.error ?? 'Failed to submit application', isError: true);
    }
  }

  void _showSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: _C.white)),
        backgroundColor: isError ? const Color(0xFFC62828) : _C.navy,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingApplication != null;
    return Scaffold(
      backgroundColor: _C.white,
      appBar: AppBar(
        backgroundColor: _C.navy,
        foregroundColor: _C.white,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Application' : 'New Application',
          style: const TextStyle(fontWeight: FontWeight.w800, color: _C.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(height: 4, color: _C.gold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionHeader(
                icon: Icons.calendar_today_rounded, title: 'Year of Study'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: _C.greyLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.greyBorder),
              ),
              child: Column(
                children: _years.map((year) {
                  final selected = _selectedYear == year;
                  return RadioListTile<String>(
                    value: year,
                    groupValue: _selectedYear,
                    onChanged: (v) { if (v != null) _onYearChanged(v); },
                    title: Text(
                      year,
                      style: TextStyle(
                        color: selected ? _C.navy : _C.grey,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                    activeColor: _C.navy,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),
            _SectionHeader(
              icon: Icons.book_rounded,
              title: 'Select Modules',
              subtitle: 'Choose 1 or 2 modules to assist with',
            ),
            const SizedBox(height: 12),
            if (_selectedModule1 != null)
              _SelectedModulePill(
                label: 'Module 1',
                module: _selectedModule1!,
                onRemove: () => setState(() => _selectedModule1 = null),
              ),
            if (_selectedModule2 != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _SelectedModulePill(
                  label: 'Module 2',
                  module: _selectedModule2!,
                  onRemove: () => setState(() => _selectedModule2 = null),
                ),
              ),
            if (_selectedModule1 != null || _selectedModule2 != null)
              const SizedBox(height: 14),
            Consumer<ApplicationViewModel>(
              builder: (context, appViewModel, _) {
                if (appViewModel.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                        child: CircularProgressIndicator(color: _C.navy)),
                  );
                }
                if (appViewModel.modules.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _C.greyLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _C.greyBorder),
                    ),
                    child: const Text('No modules available for this year.',
                        style: TextStyle(color: _C.grey)),
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                    color: _C.greyLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _C.greyBorder),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appViewModel.modules.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: _C.greyBorder, height: 1),
                    itemBuilder: (context, index) {
                      final module = appViewModel.modules[index];
                      final isModule1 = _selectedModule1?.id == module.id;
                      final isModule2 = _selectedModule2?.id == module.id;
                      final isSelected = isModule1 || isModule2;
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (_) {
                          setState(() {
                            if (isSelected) {
                              if (isModule1) _selectedModule1 = null;
                              if (isModule2) _selectedModule2 = null;
                            } else {
                              if (_selectedModule1 == null) {
                                _selectedModule1 = module;
                              } else if (_selectedModule2 == null &&
                                  _selectedModule1?.id != module.id) {
                                _selectedModule2 = module;
                              }
                            }
                          });
                        },
                        title: Text(
                          module.name,
                          style: TextStyle(
                            color: isSelected ? _C.navy : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${module.code} · ${module.level}',
                          style: const TextStyle(
                              color: _C.grey, fontSize: 12),
                        ),
                        activeColor: _C.navy,
                        checkColor: _C.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            _SectionHeader(
                icon: Icons.verified_rounded,
                title: 'Eligibility Confirmation'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: _meetsRequirements
                    ? _C.navy.withValues(alpha: 0.05)
                    : _C.greyLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _meetsRequirements
                      ? _C.navy.withValues(alpha: 0.30)
                      : _C.greyBorder,
                ),
              ),
              child: CheckboxListTile(
                value: _meetsRequirements,
                onChanged: (v) =>
                    setState(() => _meetsRequirements = v ?? false),
                title: const Text(
                  'I meet the minimum requirements',
                  style: TextStyle(
                      color: _C.navy,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'I confirm that I meet all eligibility criteria for this position.',
                    style:
                        TextStyle(color: _C.grey, fontSize: 12, height: 1.4),
                  ),
                ),
                activeColor: _C.navy,
                checkColor: _C.white,
                controlAffinity: ListTileControlAffinity.leading,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.navy,
                  foregroundColor: _C.white,
                  disabledBackgroundColor: _C.navy.withValues(alpha: 0.40),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: _C.white),
                      )
                    : Text(isEditing
                        ? 'Update Application'
                        : 'Submit Application'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _SectionHeader(
      {required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _C.navy.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _C.navy, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: _C.navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 15)),
              if (subtitle != null)
                Text(subtitle!,
                    style: const TextStyle(color: _C.grey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectedModulePill extends StatelessWidget {
  final String label;
  final Module module;
  final VoidCallback onRemove;

  const _SelectedModulePill(
      {required this.label, required this.module, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _C.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.gold.withValues(alpha: 0.40)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _C.gold,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(label,
                style: const TextStyle(
                    color: _C.navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 11)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${module.code} — ${module.name}',
              style: const TextStyle(
                  color: _C.navy, fontWeight: FontWeight.w700, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child:
                const Icon(Icons.close_rounded, color: _C.grey, size: 18),
          ),
        ],
      ),
    );
  }
}