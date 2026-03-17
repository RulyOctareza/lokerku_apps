import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/job_application.dart';
import '../../data/repositories/job_repository.dart';

/// Search Screen
/// Search and filter job applications
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<JobApplication> _allJobs = [];
  List<JobApplication> _filteredJobs = [];
  bool _isLoading = true;
  final Set<ApplicationStatus> _selectedStatuses = {
    ApplicationStatus.applied,
    ApplicationStatus.interviewHR,
    ApplicationStatus.interviewUser,
    ApplicationStatus.technicalTest,
    ApplicationStatus.offering,
    ApplicationStatus.accepted,
    ApplicationStatus.rejected,
    ApplicationStatus.withdrawn,
  };
  JobPlatform? _selectedPlatform;
  DateTime? _updatedAfter;
  final List<String> _recentQueries = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final jobs = await JobRepository.getAll();
      setState(() {
        _allJobs = jobs;
        _filteredJobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleStatus(ApplicationStatus status, bool selected) {
    setState(() {
      if (selected) {
        _selectedStatuses.add(status);
      } else {
        _selectedStatuses.remove(status);
      }
    });
    _filterJobs(_searchController.text);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _updatedAfter ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _updatedAfter = picked);
      _filterJobs(_searchController.text);
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStatuses
        ..clear()
        ..addAll(ApplicationStatus.values);
      _selectedPlatform = null;
      _updatedAfter = null;
    });
    _filterJobs(_searchController.text);
  }

  void _rememberQuery(String query) {
    final clean = query.trim();
    if (clean.isEmpty) return;

    setState(() {
      _recentQueries.remove(clean);
      _recentQueries.insert(0, clean);
      if (_recentQueries.length > 3) {
        _recentQueries.removeLast();
      }
    });
  }

  void _filterJobs(String query) {
    setState(() {
      final normalizedQuery = query.toLowerCase();
      _filteredJobs = _allJobs.where((job) {
        final matchesQuery =
            normalizedQuery.isEmpty ||
            job.companyName.toLowerCase().contains(normalizedQuery) ||
            job.role.toLowerCase().contains(normalizedQuery);

        final matchesStatus =
            _selectedStatuses.isEmpty || _selectedStatuses.contains(job.status);

        final matchesPlatform =
            _selectedPlatform == null || job.platform == _selectedPlatform;

        final matchesDate =
            _updatedAfter == null || job.updatedAt.isAfter(_updatedAfter!);

        return matchesQuery && matchesStatus && matchesPlatform && matchesDate;
      }).toList();
    });
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return AppColors.textSecondary;
      case ApplicationStatus.interviewHR:
      case ApplicationStatus.interviewUser:
      case ApplicationStatus.technicalTest:
        return AppColors.secondary;
      case ApplicationStatus.offering:
        return AppColors.primary;
      case ApplicationStatus.accepted:
        return AppColors.success;
      case ApplicationStatus.rejected:
        return AppColors.error;
      case ApplicationStatus.withdrawn:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Cari lamaran...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
          onChanged: _filterJobs,
          onSubmitted: (value) {
            _rememberQuery(value);
            _filterJobs(value);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (_searchController.text.isEmpty) {
                Navigator.pop(context);
              } else {
                _searchController.clear();
                _filterJobs('');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
            child: Wrap(
              spacing: AppSizes.spacing8,
              runSpacing: AppSizes.spacing4,
              children: ApplicationStatus.values.map((status) {
                return FilterChip(
                  label: Text(status.displayName),
                  selected: _selectedStatuses.contains(status),
                  onSelected: (selected) => _toggleStatus(status, selected),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSizes.spacing12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<JobPlatform?>(
                    initialValue: _selectedPlatform,
                    decoration: const InputDecoration(labelText: 'Platform'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Semua platform'),
                      ),
                      ...JobPlatform.values.map(
                        (platform) => DropdownMenuItem(
                          value: platform,
                          child: Text(platform.displayName),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedPlatform = value);
                      _filterJobs(_searchController.text);
                    },
                  ),
                ),
                const SizedBox(width: AppSizes.spacing8),
                OutlinedButton(
                  onPressed: _pickDate,
                  child: Text(
                    _updatedAfter != null
                        ? DateFormatter.toReadableDate(_updatedAfter!)
                        : 'Semua tanggal',
                  ),
                ),
                const SizedBox(width: AppSizes.spacing8),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spacing12),
          if (_recentQueries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing16,
              ),
              child: Wrap(
                spacing: AppSizes.spacing8,
                children: _recentQueries
                    .map(
                      (query) => ActionChip(
                        label: Text(query),
                        onPressed: () {
                          _searchController.text = query;
                          _filterJobs(query);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredJobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppSizes.spacing16),
                        Text(
                          'Tidak ada hasil',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSizes.spacing8),
                        Text(
                          'Coba kata kunci atau filter lain',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.spacing16),
                    itemCount: _filteredJobs.length,
                    itemBuilder: (context, index) {
                      final job = _filteredJobs[index];
                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: AppSizes.spacing12,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(
                            AppSizes.spacing16,
                          ),
                          title: Text(
                            job.companyName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(job.role),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                 decoration: BoxDecoration(
                                  color: _getStatusColor(job.status)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  job.status.displayName,
                                  style: TextStyle(
                                    color: _getStatusColor(job.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/job/${job.id}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
