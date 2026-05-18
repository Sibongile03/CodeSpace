import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_4/viewmodels/index.dart';
import 'package:flutter_application_4/models/index.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadApplications();
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
      appBar: AppBar(
        title: const Text('Student Assistant Applications'),
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
      body: Consumer<ApplicationViewModel>(
        builder: (context, appViewModel, _) {
          if (appViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (appViewModel.error != null) {
            return Center(
              child: Text('Error: ${appViewModel.error}'),
            );
          }

          final applications = appViewModel.applications;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (applications.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.assignment,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No applications yet',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create an application to get started',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...applications.map((app) {
                  return _ApplicationCard(application: app);
                }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/application-form');
        },
        tooltip: 'New Application',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final StudentApplication application;

  const _ApplicationCard({required this.application});

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
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/application-detail',
          arguments: application,
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Application #${application.id.substring(0, 8)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(application.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      application.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Year: ${application.yearOfStudy}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              if (application.module1 != null)
                Text(
                  'Module 1: ${application.module1!.code} - ${application.module1!.name}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              if (application.module2 != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Module 2: ${application.module2!.code} - ${application.module2!.name}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Applied: ${application.createdAt.split('T').first}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
