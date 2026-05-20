import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_4/models/index.dart';
import 'package:flutter_application_4/viewmodels/index.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introController;
  int _selectedNavIndex = 0;

  final List<_NavEntry> _navigation = const [
    _NavEntry('Dashboard', Icons.space_dashboard_rounded),
    _NavEntry('Courses', Icons.menu_book_rounded),
    _NavEntry('Calendars', Icons.calendar_month_rounded),
    _NavEntry('Events', Icons.auto_awesome_rounded),
    _NavEntry('Settings', Icons.settings_rounded),
    _NavEntry('Finance', Icons.account_balance_wallet_rounded),
  ];

  final List<_ScheduleItemData> _schedule = const [
    _ScheduleItemData(
      time: '08:30',
      title: 'Admissions stand-up',
      subtitle: 'Review application pipeline',
      accent: Color(0xFF7CFF6B),
    ),
    _ScheduleItemData(
      time: '10:00',
      title: 'Course content audit',
      subtitle: 'Validate active modules and credit load',
      accent: Color(0xFFFFE95A),
    ),
    _ScheduleItemData(
      time: '13:15',
      title: 'Faculty sync',
      subtitle: 'Discuss calendars and live events',
      accent: Color(0xFFFF4FD8),
    ),
    _ScheduleItemData(
      time: '16:00',
      title: 'Finance review',
      subtitle: 'Verify outstanding billing items',
      accent: Color(0xFF6DD3FF),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _introController.forward();
      }
    });
    _loadApplications();
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  void _loadApplications() {
    context.read<AdminViewModel>().fetchAllApplications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF050816), Color(0xFF08111E), Color(0xFF0B1526)],
          ),
        ),
        child: SafeArea(
          child: Consumer<AdminViewModel>(
            builder: (context, adminViewModel, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 1100) {
                    return _buildCompactLayout(context, adminViewModel);
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Sidebar(
                        navigation: _navigation,
                        selectedIndex: _selectedNavIndex,
                        onSelected: (index) {
                          setState(() {
                            _selectedNavIndex = index;
                          });
                        },
                      ),
                      Expanded(
                        child: _buildCenterColumn(context, adminViewModel),
                      ),
                      SizedBox(
                        width: 336,
                        child: _buildRightColumn(context, adminViewModel),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLayout(
    BuildContext context,
    AdminViewModel adminViewModel,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EntranceReveal(
                  animation: _introController,
                  begin: 0.00,
                  end: 0.32,
                  offsetY: 18,
                  child: _TopBar(
                    title: 'Academy Command Center',
                    subtitle: 'Online educational platform overview',
                    onRefresh: _loadApplications,
                    onSignOut: () => context.read<AuthViewModel>().signOut(),
                  ),
                ),
                const SizedBox(height: 16),
                _MobileSidebar(
                  navigation: _navigation,
                  selectedIndex: _selectedNavIndex,
                  onSelected: (index) {
                    setState(() {
                      _selectedNavIndex = index;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _EntranceReveal(
                  animation: _introController,
                  begin: 0.08,
                  end: 0.42,
                  offsetY: 18,
                  child: _OverviewHero(
                    adminViewModel: adminViewModel,
                    onRefresh: _loadApplications,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMetrics(context, adminViewModel),
                const SizedBox(height: 16),
                _buildCourseGrid(context),
                const SizedBox(height: 16),
                _buildAdmissionsPanel(context, adminViewModel),
                const SizedBox(height: 16),
                _buildRightColumn(context, adminViewModel),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCenterColumn(
    BuildContext context,
    AdminViewModel adminViewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      child: Column(
        children: [
          _TopBar(
            title: 'Academy Command Center',
            subtitle: 'Online educational platform overview',
            onRefresh: _loadApplications,
            onSignOut: () => context.read<AuthViewModel>().signOut(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OverviewHero(
                      adminViewModel: adminViewModel,
                      onRefresh: _loadApplications,
                    ),
                    const SizedBox(height: 16),
                    _EntranceReveal(
                      animation: _introController,
                      begin: 0.16,
                      end: 0.52,
                      offsetY: 16,
                      child: _buildMetrics(context, adminViewModel),
                    ),
                    const SizedBox(height: 16),
                    _EntranceReveal(
                      animation: _introController,
                      begin: 0.24,
                      end: 0.60,
                      offsetY: 16,
                      child: _buildCourseGrid(context),
                    ),
                    const SizedBox(height: 16),
                    _EntranceReveal(
                      animation: _introController,
                      begin: 0.32,
                      end: 0.72,
                      offsetY: 16,
                      child: _buildAdmissionsPanel(context, adminViewModel),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightColumn(
    BuildContext context,
    AdminViewModel adminViewModel,
  ) {
    final activeFilters = <String, int>{
      'All': adminViewModel.allApplications.length,
      'Pending': adminViewModel.allApplications
          .where((app) => app.status == 'pending')
          .length,
      'Approved': adminViewModel.allApplications
          .where((app) => app.status == 'approved')
          .length,
      'Rejected': adminViewModel.allApplications
          .where((app) => app.status == 'rejected')
          .length,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
      child: Column(
        children: [
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _EntranceReveal(
                      animation: _introController,
                      begin: 0.10,
                      end: 0.46,
                      offsetY: 14,
                      child: _glassCard(
                        context,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF7CFF6B),
                                        Color(0xFFFF4FD8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ntsut Admin',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Operations Lead',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: const Color(0xFF9FB0C7),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _InfoRow(
                              label: 'Campus',
                              value: 'Cape Town / Remote',
                            ),
                            const SizedBox(height: 10),
                            _InfoRow(
                              label: 'Role',
                              value: 'Platform Administrator',
                            ),
                            const SizedBox(height: 10),
                            _InfoRow(
                              label: 'Shift',
                              value: '08:00 - 17:00 SAST',
                            ),
                            const SizedBox(height: 10),
                            _InfoRow(
                              label: 'Focus',
                              value: 'Admissions & Learning Ops',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _glassCard(
                      context,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Today\'s Schedule',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF7CFF6B,
                                  ).withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Color(0xFF7CFF6B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ..._schedule.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ScheduleItem(item: item),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _glassCard(
                      context,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live Snapshot',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 14),
                          _MiniGauge(
                            label: 'Active Filters',
                            value: adminViewModel.filterStatus.toUpperCase(),
                            accent: const Color(0xFFFFE95A),
                          ),
                          const SizedBox(height: 12),
                          _MiniGauge(
                            label: 'Queued Reviews',
                            value: '${activeFilters['Pending'] ?? 0}',
                            accent: const Color(0xFFFF4FD8),
                          ),
                          const SizedBox(height: 12),
                          _MiniGauge(
                            label: 'Published Courses',
                            value: '18',
                            accent: const Color(0xFF6DD3FF),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics(BuildContext context, AdminViewModel adminViewModel) {
    final total = adminViewModel.allApplications.length;
    final pending = adminViewModel.allApplications
        .where((app) => app.status == 'pending')
        .length;
    final approved = adminViewModel.allApplications
        .where((app) => app.status == 'approved')
        .length;
    final rejected = adminViewModel.allApplications
        .where((app) => app.status == 'rejected')
        .length;
    final approvalRate = total == 0 ? 0 : ((approved / total) * 100).round();

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 920 ? 4 : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 2.35,
          children: [
            _MetricCard(
              label: 'Total Applications',
              value: total.toString().padLeft(2, '0'),
              accent: const Color(0xFF7CFF6B),
              icon: Icons.school_rounded,
              delta: '+12.4% this week',
            ),
            _MetricCard(
              label: 'Pending Review',
              value: pending.toString().padLeft(2, '0'),
              accent: const Color(0xFFFFE95A),
              icon: Icons.pending_actions_rounded,
              delta: 'Needs attention',
            ),
            _MetricCard(
              label: 'Approval Rate',
              value: '$approvalRate%',
              accent: const Color(0xFFFF4FD8),
              icon: Icons.auto_graph_rounded,
              delta: '$approved approved / $rejected rejected',
            ),
            _MetricCard(
              label: 'Courses Live',
              value: '24',
              accent: const Color(0xFF6DD3FF),
              icon: Icons.menu_book_rounded,
              delta: '3 updates scheduled',
            ),
          ],
        );
      },
    );
  }

  Widget _buildCourseGrid(BuildContext context) {
    const courses = [
      _CourseData(
        code: 'CS101',
        title: 'Foundations of Computer Science',
        subtitle:
            'Introductory track with live labs and weekly progress checkpoints.',
        accent: Color(0xFF7CFF6B),
        progress: 0.78,
        students: 184,
      ),
      _CourseData(
        code: 'UX204',
        title: 'Product Design Studio',
        subtitle: 'Design sprints, critique sessions, and portfolio reviews.',
        accent: Color(0xFFFFE95A),
        progress: 0.63,
        students: 96,
      ),
      _CourseData(
        code: 'DB311',
        title: 'Database Systems',
        subtitle:
            'Query optimization, relational design, and project analytics.',
        accent: Color(0xFFFF4FD8),
        progress: 0.47,
        students: 128,
      ),
      _CourseData(
        code: 'AI220',
        title: 'Applied AI for Learning',
        subtitle:
            'Practical machine learning and ethics for education workflows.',
        accent: Color(0xFF6DD3FF),
        progress: 0.91,
        students: 63,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Academic Programs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton.icon(
              onPressed: _loadApplications,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Sync data'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7CFF6B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 840 ? 2 : 1;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 2.2,
              children: courses
                  .map((course) => _CourseCard(course: course))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdmissionsPanel(
    BuildContext context,
    AdminViewModel adminViewModel,
  ) {
    final applications = adminViewModel.filteredApplications;

    return _glassCard(
      context,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Admissions Queue',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  _StatusFilterPill(
                    label: 'All',
                    selected: adminViewModel.filterStatus == 'all',
                    accent: const Color(0xFF7CFF6B),
                    onTap: () => adminViewModel.setFilter('all'),
                  ),
                  _StatusFilterPill(
                    label: 'Pending',
                    selected: adminViewModel.filterStatus == 'pending',
                    accent: const Color(0xFFFFE95A),
                    onTap: () => adminViewModel.setFilter('pending'),
                  ),
                  _StatusFilterPill(
                    label: 'Approved',
                    selected: adminViewModel.filterStatus == 'approved',
                    accent: const Color(0xFF7CFF6B),
                    onTap: () => adminViewModel.setFilter('approved'),
                  ),
                  _StatusFilterPill(
                    label: 'Rejected',
                    selected: adminViewModel.filterStatus == 'rejected',
                    accent: const Color(0xFFFF4FD8),
                    onTap: () => adminViewModel.setFilter('rejected'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (adminViewModel.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF7CFF6B)),
              ),
            )
          else if (adminViewModel.error != null)
            _emptyState(
              context,
              icon: Icons.error_outline_rounded,
              title: 'Could not load the queue',
              subtitle: adminViewModel.error!,
            )
          else if (applications.isEmpty)
            _emptyState(
              context,
              icon: Icons.assignment_outlined,
              title: 'No applications to review',
              subtitle: 'The current filter returned no records.',
            )
          else
            ListView.separated(
              itemCount: applications.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final application = applications[index];
                return _AdmissionCard(application: application);
              },
            ),
        ],
      ),
    );
  }

  Widget _emptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        color: Colors.white.withValues(alpha: 0.03),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF7CFF6B), size: 38),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFFA7B7CB)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _glassCard(
    BuildContext context, {
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.03),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7CFF6B).withValues(alpha: 0.06),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _EntranceReveal extends StatelessWidget {
  final Animation<double> animation;
  final double begin;
  final double end;
  final double offsetY;
  final Widget child;

  const _EntranceReveal({
    required this.animation,
    required this.begin,
    required this.end,
    required this.offsetY,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: curved,
      child: child,
      builder: (context, child) {
        final value = curved.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, offsetY * (1 - value)),
            child: Transform.scale(
              scale: 0.985 + (value * 0.015),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _Sidebar extends StatelessWidget {
  final List<_NavEntry> navigation;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _Sidebar({
    required this.navigation,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 282,
      margin: const EdgeInsets.fromLTRB(16, 16, 0, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: const Color(0xFF09111D).withValues(alpha: 0.92),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0xAA000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF16233A), Color(0xFF0B1627)],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7CFF6B), Color(0xFF6DD3FF)],
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EduCore',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Admin panel',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF93A5BE),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Navigation',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF8EA2BC),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: navigation.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final entry = navigation[index];
                final selected = selectedIndex == index;
                return InkWell(
                  onTap: () => onSelected(index),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: selected
                          ? const LinearGradient(
                              colors: [Color(0xFF1B3A28), Color(0xFF102A22)],
                            )
                          : null,
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF7CFF6B).withValues(alpha: 0.40)
                            : Colors.white.withValues(alpha: 0.06),
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF7CFF6B,
                                ).withValues(alpha: 0.15),
                                blurRadius: 20,
                                spreadRadius: 1,
                              ),
                            ]
                          : const [],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          entry.icon,
                          color: selected
                              ? const Color(0xFF7CFF6B)
                              : const Color(0xFF93A5BE),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.label,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFFD1D9E6),
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Color(0xFF7CFF6B),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          _glassHint(
            context,
            title: 'University Year',
            subtitle: '2026 intake',
            accent: const Color(0xFFFFE95A),
          ),
        ],
      ),
    );
  }

  Widget _glassHint(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color accent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: accent,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.30),
                  blurRadius: 18,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9FB0C7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileSidebar extends StatelessWidget {
  final List<_NavEntry> navigation;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _MobileSidebar({
    required this.navigation,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _glassMobileCard(
      context,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(navigation.length, (index) {
          final entry = navigation[index];
          final selected = selectedIndex == index;
          return ChoiceChip(
            label: Text(entry.label),
            selected: selected,
            onSelected: (_) => onSelected(index),
            avatar: Icon(
              entry.icon,
              size: 18,
              color: selected
                  ? const Color(0xFF050816)
                  : const Color(0xFF9FB0C7),
            ),
            selectedColor: const Color(0xFF7CFF6B),
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            labelStyle: TextStyle(
              color: selected ? const Color(0xFF050816) : Colors.white,
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          );
        }),
      ),
    );
  }

  Widget _glassMobileCard(BuildContext context, {required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onRefresh;
  final VoidCallback onSignOut;

  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onRefresh,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withValues(alpha: 0.04),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF99AAC0),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Refresh data',
                onPressed: onRefresh,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF7CFF6B),
                ),
              ),
              const SizedBox(width: 8),
              _GlowActionButton(
                label: 'Sign out',
                icon: Icons.logout_rounded,
                onPressed: onSignOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewHero extends StatelessWidget {
  final AdminViewModel adminViewModel;
  final VoidCallback onRefresh;

  const _OverviewHero({required this.adminViewModel, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final pending = adminViewModel.allApplications
        .where((app) => app.status == 'pending')
        .length;
    final approved = adminViewModel.allApplications
        .where((app) => app.status == 'approved')
        .length;
    final rejected = adminViewModel.allApplications
        .where((app) => app.status == 'rejected')
        .length;

    return _glassBlock(
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GlowTag(
                  label: 'Realtime campus ops',
                  accent: const Color(0xFF7CFF6B),
                ),
                const SizedBox(height: 14),
                Text(
                  'Monitor admissions, courses, events, and finance in one high-contrast workspace.',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'This layout combines a glowing navigation rail, a metrics-first operations view, and a dense activity column for fast administration.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF9FB0C7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _HeroPill(
                      label: 'Pending $pending',
                      accent: const Color(0xFFFFE95A),
                    ),
                    _HeroPill(
                      label: 'Approved $approved',
                      accent: const Color(0xFF7CFF6B),
                    ),
                    _HeroPill(
                      label: 'Rejected $rejected',
                      accent: const Color(0xFFFF4FD8),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _GlowActionButton(
                      label: 'Sync now',
                      icon: Icons.sync_rounded,
                      onPressed: onRefresh,
                    ),
                    const SizedBox(width: 12),
                    _OutlineActionButton(
                      label: 'View calendar',
                      icon: Icons.calendar_month_rounded,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: _glassMiniMetric(
              context,
              title: 'Platform Pulse',
              primary: '98.4%',
              subtitle: 'uptime for the learning environment',
              accent: const Color(0xFF6DD3FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassBlock({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.10),
                Colors.white.withValues(alpha: 0.04),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _glassMiniMetric(
    BuildContext context, {
    required String title,
    required String primary,
    required String subtitle,
    required Color accent,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                primary,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFA7B7CB),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final IconData icon;
  final String delta;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
    required this.delta,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(color: accent.withValues(alpha: 0.08), blurRadius: 20),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.95),
                      accent.withValues(alpha: 0.55),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.25),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF96A8C2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      delta,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final _CourseData course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: course.accent.withValues(alpha: 0.16),
                      border: Border.all(
                        color: course.accent.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      course.code,
                      style: TextStyle(
                        color: course.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_outward_rounded, color: course.accent),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                course.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  course.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFA7B7CB),
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: course.progress,
                        minHeight: 9,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        color: course.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(course.progress * 100).round()}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${course.students} enrolled learners',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF8FA3BF)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdmissionCard extends StatelessWidget {
  final StudentApplication application;

  const _AdmissionCard({required this.application});

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF7CFF6B);
      case 'rejected':
        return const Color(0xFFFF4FD8);
      default:
        return const Color(0xFFFFE95A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(application.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Application ${application.id.substring(0, 8).toUpperCase()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      application.yearOfStudy,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF98A8C2),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: statusColor.withValues(alpha: 0.14),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  application.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetaPill(
                label: 'Module A',
                value: application.module1?.code ?? 'N/A',
              ),
              _MetaPill(
                label: 'Module B',
                value: application.module2?.code ?? 'N/A',
              ),
              _MetaPill(
                label: 'Requirements',
                value: application.meetsRequirements ? 'Met' : 'Pending',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final _ScheduleItemData item;

  const _ScheduleItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.accent,
                boxShadow: [
                  BoxShadow(
                    color: item.accent.withValues(alpha: 0.35),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            Container(
              width: 2,
              height: 58,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: item.accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: item.accent,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9FB0C7),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusFilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _StatusFilterPill({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      label: Text(label),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF050816) : Colors.white,
        fontWeight: FontWeight.w800,
      ),
      backgroundColor: selected ? accent : Colors.white.withValues(alpha: 0.04),
      side: BorderSide(
        color: selected ? accent : Colors.white.withValues(alpha: 0.08),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}

class _GlowTag extends StatelessWidget {
  final String label;
  final Color accent;

  const _GlowTag({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: accent.withValues(alpha: 0.12),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.10), blurRadius: 18),
        ],
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: accent,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final String label;
  final Color accent;

  const _HeroPill({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: accent.withValues(alpha: 0.12),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(color: accent, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _GlowActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _GlowActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7CFF6B),
        foregroundColor: const Color(0xFF050816),
        elevation: 18,
        shadowColor: const Color(0xFF7CFF6B).withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _OutlineActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF8EA2BC)),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniGauge extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _MiniGauge({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9EB1C8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String label;
  final String value;

  const _MetaPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: const Color(0xFF9EB1C8)),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavEntry {
  final String label;
  final IconData icon;

  const _NavEntry(this.label, this.icon);
}

class _CourseData {
  final String code;
  final String title;
  final String subtitle;
  final Color accent;
  final double progress;
  final int students;

  const _CourseData({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.progress,
    required this.students,
  });
}

class _ScheduleItemData {
  final String time;
  final String title;
  final String subtitle;
  final Color accent;

  const _ScheduleItemData({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.accent,
  });
}
