import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../repositories/job_repository.dart';

/// Export Service
/// Handles exporting job application data to JSON/CSV
class ExportService {
  /// Export all job applications to JSON file
  static Future<String?> exportToJson() async {
    try {
      final jobs = await JobRepository.getAll();

      if (jobs.isEmpty) {
        return null;
      }

      final data = {
        'exported_at': DateTime.now().toIso8601String(),
        'total_jobs': jobs.length,
        'applications': jobs
            .map(
              (job) => {
                'id': job.id,
                'company_name': job.companyName,
                'role': job.role,
                'platform': job.platform.name,
                'status': job.status.name,
                'created_at': job.createdAt.toIso8601String(),
                'salary': job.salary,
                'notes': job.logs.isNotEmpty ? job.logs.first.notes : null,
                'updated_at': job.updatedAt.toIso8601String(),
              },
            )
            .toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      // Save to downloads directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/lokerku_export_$timestamp.json');
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      debugPrint('Export to JSON error: $e');
      return null;
    }
  }

  /// Export all job applications to CSV file
  static Future<String?> exportToCsv() async {
    try {
      final jobs = await JobRepository.getAll();

      if (jobs.isEmpty) {
        return null;
      }

      final buffer = StringBuffer();

      // CSV Header
      buffer.writeln(
        'ID,Perusahaan,Posisi,Platform,Status,Tanggal Dibuat,Gaji,Catatan',
      );

      // CSV Rows
      for (final job in jobs) {
        final notes = job.logs.isNotEmpty ? job.logs.first.notes ?? '' : '';
        buffer.writeln(
          '${job.id},'
          '"${_escapeCsv(job.companyName)}",'
          '"${_escapeCsv(job.role)}",'
          '${job.platform.displayName},'
          '${job.status.displayName},'
          '${DateFormat('yyyy-MM-dd').format(job.createdAt)},'
          '${job.salary ?? ""},'
          '"${_escapeCsv(notes)}"',
        );
      }

      // Save to downloads directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/lokerku_export_$timestamp.csv');
      await file.writeAsString(buffer.toString());

      return file.path;
    } catch (e) {
      debugPrint('Export to CSV error: $e');
      return null;
    }
  }

  /// Escape special characters for CSV
  static String _escapeCsv(String value) {
    if (value.contains('"') || value.contains(',') || value.contains('\n')) {
      return value.replaceAll('"', '""');
    }
    return value;
  }

  /// Show export format selection dialog
  static Future<void> showExportDialog(BuildContext context) async {
    final format = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Pilih format export:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'json'),
            child: const Text('JSON'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'csv'),
            child: const Text('CSV'),
          ),
        ],
      ),
    );

    if (format == null || !context.mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    String? filePath;
    if (format == 'json') {
      filePath = await exportToJson();
    } else if (format == 'csv') {
      filePath = await exportToCsv();
    }

    // Hide loading
    if (context.mounted) {
      Navigator.pop(context);

      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data berhasil diexport ke:\n$filePath'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada data untuk diexport atau terjadi error'),
          ),
        );
      }
    }
  }
}
