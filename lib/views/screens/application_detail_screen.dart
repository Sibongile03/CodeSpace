/**
 * Student Numbers: ADD YOUR STUDENT NUMBERS HERE
 * Student Names  : ADD YOUR NAMES HERE
 * Question: Application Detail Screen
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
  static const red = Color(0xFFC62828);
}

class ApplicationDetailScreen extends StatefulWidget {
  final StudentApplication application;

  const ApplicationDetailScreen({super.key, required this.application});

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

  Color _statusColor(String status) {
    switch (status) {
      case 'approved': return _C.green;
      case 'rejected': return _C.red;
      default: return _C.gold;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved': return Icons.check_circle_rounded;
      case 'rejected': return Icons.cancel_rounded;
      default: return Icons.hourglass_empty_rounded;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Application',
            style: TextStyle(color: _C.navy, fontWeight: FontWeight.w800)),
        content: const Text(
          'Are you sure you want to delete this application? This cannot be undone.',
          style: TextStyle(color: _C.grey, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: _C.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteApplication();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.red,
              foregroundColor: _C.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteApplication() async {
    final appViewModel = context.read<ApplicationViewModel>();
    final success = await appViewModel.deleteApplication(_application.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Application deleted',
              style: TextStyle(color: _C.white)),
          backgroundColor: _C.navy,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      context.pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appViewModel.error ?? 'Failed to delete',
              style: const TextStyle(color: _C.white)),
          backgroundColor: _C.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _editApplication() {
    context.push('/application-form', extra: _application).then((result) {
      if (result == true) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor(_application.status);
    final isPending = _application.status == 'pending';

    return Scaffold(
      backgroundColor: _C.white,
      appBar: AppBar(
        backgroundColor: _C.navy,
        foregroundColor: _C.white,
        elevation: 0,
        title: const Text('Application Details',
            style: TextStyle(fontWeight: FontWeight.w800, color: _C.white)),
        actions: [
          if (isPending) ...[
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_rounded, color: _C.gold),
              onPressed: _editApplication,
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline_rounded, color: _C.white),
              onPressed: _showDeleteConfirmation,
            ),
          ],
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(height: 4, color: _C.gold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: sc.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: sc.withValues(alpha: 0.25), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: sc.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(_statusIcon(_application.status),
                        color: sc, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Application Status',
                          style: TextStyle(
                              color: _C.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        _application.status.toUpperCase(),
                        style: TextStyle(
                            color: sc,
                            fontWeight: FontWeight.w900,
                            fontSize: 22),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Application Information'),
            const SizedBox(height: 12),
            _InfoCard(children: [
              _InfoRow(
                  icon: Icons.tag_rounded,
                  label: 'Application ID',
                  value: _application.id.substring(0, 8).toUpperCase()),
              _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Year of Study',
                  value: _application.yearOfStudy),
              _InfoRow(
                  icon: Icons.verified_rounded,
                  label: 'Meets Requirements',
                  value: _application.meetsRequirements ? 'Yes' : 'No',
                  valueColor:
                      _application.meetsRequirements ? _C.green : _C.red),
              _InfoRow(
                  icon: Icons.upload_rounded,
                  label: 'Submitted',
                  value: _application.createdAt.split('T').first),
              _InfoRow(
                  icon: Icons.update_rounded,
                  label: 'Last Updated',
                  value: _application.updatedAt.split('T').first,
                  isLast: true),
            ]),
            const SizedBox(height: 24),
            _sectionTitle('Applied Modules'),
            const SizedBox(height: 12),
            if (_application.module1 == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _C.greyLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _C.greyBorder),
                ),
                child: const Text('No modules selected.',
                    style: TextStyle(color: _C.grey)),
              )
            else
              Column(children: [
                _ModuleCard(
                    label: 'Primary Module', module: _application.module1!),
                if (_application.module2 != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _ModuleCard(
                        label: 'Secondary Module',
                        module: _application.module2!),
                  ),
              ]),
            if (_application.adminNotes != null &&
                _application.adminNotes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _sectionTitle('Admin Notes'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _C.navy.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: _C.navy.withValues(alpha: 0.15)),
                ),
                child: Text(_application.adminNotes!,
                    style: const TextStyle(
                        color: _C.navy, fontSize: 14, height: 1.5)),
              ),
            ],
            if (isPending) ...[
              const SizedBox(height: 32),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showDeleteConfirmation,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Delete',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _C.red,
                      side: const BorderSide(color: _C.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _editApplication,
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Edit',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _C.navy,
                      foregroundColor: _C.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ]),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
              color: _C.gold, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                color: _C.navy, fontWeight: FontWeight.w800, fontSize: 16)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.greyBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: _C.navy, size: 18),
              const SizedBox(width: 12),
              Text(label,
                  style: const TextStyle(color: _C.grey, fontSize: 13)),
              const Spacer(),
              Text(value,
                  style: TextStyle(
                      color: valueColor ?? _C.navy,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ],
          ),
        ),
        if (!isLast)
          Divider(
              height: 1,
              color: _C.greyBorder,
              indent: 16,
              endIndent: 16),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String label;
  final Module module;

  const _ModuleCard({required this.label, required this.module});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.greyBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _C.navy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.book_rounded, color: _C.navy, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _C.gold.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(label,
                      style: const TextStyle(
                          color: _C.navy,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.5)),
                ),
                const SizedBox(height: 6),
                Text(module.name,
                    style: const TextStyle(
                        color: _C.navy,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text('${module.code} · ${module.level}',
                    style:
                        const TextStyle(color: _C.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}