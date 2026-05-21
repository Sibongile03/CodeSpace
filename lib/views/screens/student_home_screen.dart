/**
 * Student Numbers: ADD YOUR STUDENT NUMBERS HERE
 * Student Names  : ADD YOUR NAMES HERE
 * Question: Student Home Screen
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
}

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadApplications());
  }

  void _loadApplications() {
    final authViewModel = context.read<AuthViewModel>();
    final appViewModel = context.read<ApplicationViewModel>();
    if (authViewModel.currentUser != null) {
      appViewModel.fetchStudentApplications(authViewModel.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.white,
      appBar: AppBar(
        backgroundColor: _C.navy,
        foregroundColor: _C.white,
        elevation: 0,
        title: const Text(
          'My Applications',
          style: TextStyle(fontWeight: FontWeight.w800, color: _C.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: _C.gold),
            onPressed: _loadApplications,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: _C.white),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, color: _C.navy, size: 18),
                    SizedBox(width: 10),
                    Text('Sign Out',
                        style: TextStyle(
                            color: _C.navy, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'signout') {
                context.read<AuthViewModel>().signOut();
                context.go('/auth');
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(height: 4, color: _C.gold),
        ),
      ),
      body: Consumer<ApplicationViewModel>(
        builder: (context, appViewModel, _) {
          if (appViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _C.navy),
            );
          }
          if (appViewModel.error != null) {
            return _ErrorState(
              message: appViewModel.error!,
              onRetry: _loadApplications,
            );
          }
          final applications = appViewModel.applications;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _WelcomeBanner(applicationCount: applications.length),
              const SizedBox(height: 20),
              if (applications.isEmpty)
                _EmptyState(onApply: () => context.push('/application-form'))
              else ...[
                Row(
                  children: [
                    const Text(
                      'Your Applications',
                      style: TextStyle(
                        color: _C.navy,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${applications.length} total',
                      style: const TextStyle(color: _C.grey, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...applications.map(
                  (app) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ApplicationCard(
                      application: app,
                      onTap: () =>
                          context.push('/application-detail', extra: app),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/application-form'),
        backgroundColor: _C.navy,
        foregroundColor: _C.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Application',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  final int applicationCount;
  const _WelcomeBanner({required this.applicationCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.navy,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _C.navy.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Student Assistant',
                  style: TextStyle(
                    color: _C.gold,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Application Portal',
                  style: TextStyle(
                    color: _C.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  applicationCount == 0
                      ? 'No applications submitted yet'
                      : '$applicationCount application${applicationCount == 1 ? '' : 's'} submitted',
                  style: TextStyle(
                    color: _C.white.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _C.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.assignment_rounded,
                color: _C.gold, size: 28),
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final StudentApplication application;
  final VoidCallback onTap;

  const _ApplicationCard({required this.application, required this.onTap});

  Color _statusColor(String status) {
    switch (status) {
      case 'approved': return const Color(0xFF2E7D32);
      case 'rejected': return const Color(0xFFC62828);
      default: return const Color(0xFFF9A825);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved': return Icons.check_circle_rounded;
      case 'rejected': return Icons.cancel_rounded;
      default: return Icons.hourglass_empty_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor(application.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _C.greyBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _C.navy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'APP #${application.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                      color: _C.navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: sc.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: sc.withValues(alpha: 0.30)),
                  ),
                  child: Row(
                    children: [
                      Icon(_statusIcon(application.status),
                          color: sc, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        application.status.toUpperCase(),
                        style: TextStyle(
                          color: sc,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _DetailRow(
              icon: Icons.calendar_today_rounded,
              label: 'Year of Study',
              value: application.yearOfStudy,
            ),
            if (application.module1 != null) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.book_rounded,
                label: 'Module 1',
                value:
                    '${application.module1!.code} — ${application.module1!.name}',
              ),
            ],
            if (application.module2 != null) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.book_outlined,
                label: 'Module 2',
                value:
                    '${application.module2!.code} — ${application.module2!.name}',
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 13, color: _C.grey),
                const SizedBox(width: 4),
                Text(
                  'Applied ${application.createdAt.split('T').first}',
                  style: const TextStyle(color: _C.grey, fontSize: 12),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded,
                    color: _C.gold, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _C.navy),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: _C.grey, fontSize: 13)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: _C.navy,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onApply;
  const _EmptyState({required this.onApply});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _C.navy.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.assignment_outlined,
                  size: 40, color: _C.navy),
            ),
            const SizedBox(height: 20),
            const Text(
              'No applications yet',
              style: TextStyle(
                color: _C.navy,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the button below to apply\nfor a Student Assistant position',
              textAlign: TextAlign.center,
              style: TextStyle(color: _C.grey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Apply Now',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.gold,
                foregroundColor: _C.navy,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: _C.navy, size: 48),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _C.grey, fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.navy,
                foregroundColor: _C.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}