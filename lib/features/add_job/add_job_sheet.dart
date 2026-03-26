import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/job_application.dart';
import '../../data/repositories/job_repository.dart';

/// Add Job Bottom Sheet
/// Form for adding a new job application
class AddJobSheet extends StatefulWidget {
  const AddJobSheet({super.key});

  @override
  State<AddJobSheet> createState() => _AddJobSheetState();
}

class _AddJobSheetState extends State<AddJobSheet> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _salaryController = TextEditingController();
  final _notesController = TextEditingController();

  JobPlatform _selectedPlatform = JobPlatform.linkedin;
  bool _isLoading = false;

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _salaryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveApplication() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Parse salary if provided
        double? salary;
        if (_salaryController.text.isNotEmpty) {
          salary = double.tryParse(
            _salaryController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          );
        }

        // Save to Isar database
        await JobRepository.create(
          companyName: _companyController.text.trim(),
          role: _roleController.text.trim(),
          platform: _selectedPlatform,
          salary: salary,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lamaran berhasil disimpan!'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSizes.bottomSheetRadius),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacing24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: AppSizes.bottomSheetHandleWidth,
                      height: AppSizes.bottomSheetHandleHeight,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing16),

                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          AppStrings.addApplicationTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacing24),

                  // Company Name
                  Text(
                    '${AppStrings.companyNameLabel} *',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSizes.spacing8),
                  TextFormField(
                    controller: _companyController,
                    decoration: InputDecoration(
                      hintText: AppStrings.companyNameHint,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.errorRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.spacing16),

                  // Role
                  Text(
                    '${AppStrings.roleLabel} *',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSizes.spacing8),
                  TextFormField(
                    controller: _roleController,
                    decoration: InputDecoration(hintText: AppStrings.roleHint),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.errorRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.spacing16),

                  // Platform
                  Text(
                    '${AppStrings.platformLabel} *',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSizes.spacing8),
                  DropdownButtonFormField<JobPlatform>(
                    initialValue: _selectedPlatform,
                    decoration: const InputDecoration(),
                    items: JobPlatform.values.map((platform) {
                      return DropdownMenuItem(
                        value: platform,
                        child: Text(platform.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPlatform = value!;
                      });
                    },
                  ),
                  const SizedBox(height: AppSizes.spacing16),

                  // Salary (Optional)
                  Text(
                    AppStrings.salaryLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSizes.spacing8),
                  TextFormField(
                    controller: _salaryController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: AppStrings.salaryHint,
                      prefixText: 'Rp ',
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing16),

                  // Notes (Optional)
                  Text(
                    AppStrings.notesLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSizes.spacing8),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(hintText: AppStrings.notesHint),
                  ),
                  const SizedBox(height: AppSizes.spacing24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveApplication,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(AppStrings.saveApplication),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
