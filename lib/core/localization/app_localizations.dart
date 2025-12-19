/// Localization strings for the app
/// Supports Indonesian and English

class AppLocalizations {
  static String currentLocale = 'id';

  static Map<String, Map<String, String>> _localizedStrings = {
    'id': {
      // General
      'app_name': 'LokerKu',
      'app_tagline': 'Pelacak Lamaran Kerja Pribadi',
      'loading': 'Memuat...',
      'save': 'Simpan',
      'cancel': 'Batal',
      'delete': 'Hapus',
      'edit': 'Edit',
      'close': 'Tutup',
      'yes': 'Ya',
      'no': 'Tidak',
      'error': 'Error',
      'success': 'Berhasil',
      'required_field': 'Wajib diisi',
      'search': 'Cari',
      'search_hint': 'Cari lamaran...',
      'no_results': 'Tidak ada hasil',

      // Navigation
      'nav_home': 'Beranda',
      'nav_templates': 'Template',
      'nav_stats': 'Statistik',
      'nav_settings': 'Pengaturan',

      // Home Screen
      'home_greeting': 'Hai',
      'home_recent': 'Lamaran Terbaru',
      'home_view_all': 'Lihat Semua',
      'home_total': 'Total',
      'home_pending': 'Menunggu',
      'home_interview': 'Interview',
      'home_no_apps': 'Belum ada lamaran',
      'home_no_apps_hint': 'Tekan tombol + untuk menambah lamaran baru',
      'home_search_coming': 'Fitur pencarian',
      'home_notif_coming': 'Fitur notifikasi',

      // Add Job
      'add_job_title': 'Tambah Lamaran',
      'add_job_company': 'Nama Perusahaan',
      'add_job_company_hint': 'Contoh: PT ABC Indonesia',
      'add_job_role': 'Posisi',
      'add_job_role_hint': 'Contoh: Android Developer',
      'add_job_platform': 'Platform',
      'add_job_salary': 'Ekspektasi Gaji (Opsional)',
      'add_job_salary_hint': 'Contoh: 10000000',
      'add_job_notes': 'Catatan (Opsional)',
      'add_job_notes_hint': 'Catatan tambahan...',
      'add_job_save': 'Simpan Lamaran',
      'add_job_success': 'Lamaran berhasil disimpan!',

      // Job Status
      'status_applied': 'Applied',
      'status_interview_hr': 'Interview HR',
      'status_interview_user': 'Interview User',
      'status_technical_test': 'Technical Test',
      'status_offering': 'Offering',
      'status_accepted': 'Accepted',
      'status_rejected': 'Rejected',
      'status_withdrawn': 'Withdrawn',

      // Settings
      'settings_title': 'Pengaturan',
      'settings_account': 'Akun',
      'settings_profile': 'Profil',
      'settings_edit_profile': 'Edit Profil',
      'settings_premium': 'Langganan Premium',
      'settings_sync': 'Sinkronisasi',
      'settings_app': 'Aplikasi',
      'settings_dark_mode': 'Mode Gelap',
      'settings_notifications': 'Notifikasi',
      'settings_language': 'Bahasa',
      'settings_data': 'Data',
      'settings_export': 'Ekspor Data',
      'settings_delete_all': 'Hapus Semua Data',
      'settings_storage': 'Penyimpanan',
      'settings_about': 'Tentang',
      'settings_about_app': 'Tentang Aplikasi',
      'settings_terms': 'Syarat & Ketentuan',
      'settings_privacy': 'Kebijakan Privasi',
      'settings_rate': 'Nilai Aplikasi',
      'settings_logout': 'Keluar',
      'settings_login': 'Masuk',
      'settings_guest_mode': 'Mode Tamu',

      // Stats
      'stats_title': 'Statistik',
      'stats_total': 'Total Lamaran',
      'stats_breakdown': 'Status Breakdown',
      'stats_platform': 'Platform Terpopuler',
      'stats_conversion': 'Tingkat Konversi',
      'stats_no_data': 'Belum ada data statistik',
      'stats_no_data_hint':
          'Tambahkan lamaran pertama Anda untuk melihat statistik',

      // Profile
      'profile_title': 'Profil',
      'profile_name': 'Nama',
      'profile_email': 'Email',
      'profile_whatsapp': 'Nomor WhatsApp',
      'profile_age': 'Usia',
      'profile_gender': 'Jenis Kelamin',
      'profile_save_success': 'Profil berhasil disimpan!',
      'profile_gender_male': 'Laki-laki',
      'profile_gender_female': 'Perempuan',
      'profile_gender_other': 'Lainnya',

      // Notifications
      'notif_permission_title': 'Izinkan Notifikasi',
      'notif_permission_message':
          'LokerKu membutuhkan izin untuk mengirim notifikasi pengingat lamaran Anda.',
      'notif_permission_denied': 'Izin notifikasi ditolak',
      'notif_permission_granted': 'Izin notifikasi diberikan',

      // Dialogs
      'dialog_delete_title': 'Hapus Lamaran?',
      'dialog_delete_message': 'Apakah Anda yakin ingin menghapus lamaran ini?',
      'dialog_delete_all_title': 'Hapus Semua Data?',
      'dialog_delete_all_message':
          'Tindakan ini akan menghapus semua data lamaran secara permanen.',
      'dialog_logout_title': 'Keluar?',
      'dialog_logout_message': 'Apakah Anda yakin ingin keluar dari akun?',

      // Time
      'time_just_now': 'Baru saja',
      'time_minutes_ago': 'menit lalu',
      'time_hours_ago': 'jam lalu',
      'time_days_ago': 'hari lalu',

      // Login
      'login_title': 'Masuk',
      'login_subtitle': 'Masuk untuk menyimpan data Anda ke cloud',
      'login_google': 'Masuk dengan Google',
      'login_guest': 'Lanjutkan sebagai Tamu',
      'login_guest_note': 'Mode tamu: Data hanya tersimpan di perangkat ini',
    },
    'en': {
      // General
      'app_name': 'LokerKu',
      'app_tagline': 'Your Personal Job Application Tracker',
      'loading': 'Loading...',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'close': 'Close',
      'yes': 'Yes',
      'no': 'No',
      'error': 'Error',
      'success': 'Success',
      'required_field': 'Required',
      'search': 'Search',
      'search_hint': 'Search applications...',
      'no_results': 'No results',

      // Navigation
      'nav_home': 'Home',
      'nav_templates': 'Templates',
      'nav_stats': 'Stats',
      'nav_settings': 'Settings',

      // Home Screen
      'home_greeting': 'Hi',
      'home_recent': 'Recent Applications',
      'home_view_all': 'View All',
      'home_total': 'Total',
      'home_pending': 'Pending',
      'home_interview': 'Interview',
      'home_no_apps': 'No applications yet',
      'home_no_apps_hint': 'Tap + to add a new application',
      'home_search_coming': 'Search feature',
      'home_notif_coming': 'Notification feature',

      // Add Job
      'add_job_title': 'Add Application',
      'add_job_company': 'Company Name',
      'add_job_company_hint': 'e.g., ABC Company',
      'add_job_role': 'Position',
      'add_job_role_hint': 'e.g., Android Developer',
      'add_job_platform': 'Platform',
      'add_job_salary': 'Expected Salary (Optional)',
      'add_job_salary_hint': 'e.g., 10000000',
      'add_job_notes': 'Notes (Optional)',
      'add_job_notes_hint': 'Additional notes...',
      'add_job_save': 'Save Application',
      'add_job_success': 'Application saved successfully!',

      // Job Status
      'status_applied': 'Applied',
      'status_interview_hr': 'HR Interview',
      'status_interview_user': 'User Interview',
      'status_technical_test': 'Technical Test',
      'status_offering': 'Offering',
      'status_accepted': 'Accepted',
      'status_rejected': 'Rejected',
      'status_withdrawn': 'Withdrawn',

      // Settings
      'settings_title': 'Settings',
      'settings_account': 'Account',
      'settings_profile': 'Profile',
      'settings_edit_profile': 'Edit Profile',
      'settings_premium': 'Premium Subscription',
      'settings_sync': 'Sync',
      'settings_app': 'App',
      'settings_dark_mode': 'Dark Mode',
      'settings_notifications': 'Notifications',
      'settings_language': 'Language',
      'settings_data': 'Data',
      'settings_export': 'Export Data',
      'settings_delete_all': 'Delete All Data',
      'settings_storage': 'Storage',
      'settings_about': 'About',
      'settings_about_app': 'About App',
      'settings_terms': 'Terms & Conditions',
      'settings_privacy': 'Privacy Policy',
      'settings_rate': 'Rate App',
      'settings_logout': 'Logout',
      'settings_login': 'Login',
      'settings_guest_mode': 'Guest Mode',

      // Stats
      'stats_title': 'Statistics',
      'stats_total': 'Total Applications',
      'stats_breakdown': 'Status Breakdown',
      'stats_platform': 'Popular Platforms',
      'stats_conversion': 'Conversion Rate',
      'stats_no_data': 'No statistics yet',
      'stats_no_data_hint': 'Add your first application to see statistics',

      // Profile
      'profile_title': 'Profile',
      'profile_name': 'Name',
      'profile_email': 'Email',
      'profile_whatsapp': 'WhatsApp Number',
      'profile_age': 'Age',
      'profile_gender': 'Gender',
      'profile_save_success': 'Profile saved successfully!',
      'profile_gender_male': 'Male',
      'profile_gender_female': 'Female',
      'profile_gender_other': 'Other',

      // Notifications
      'notif_permission_title': 'Allow Notifications',
      'notif_permission_message':
          'LokerKu needs permission to send you application reminders.',
      'notif_permission_denied': 'Notification permission denied',
      'notif_permission_granted': 'Notification permission granted',

      // Dialogs
      'dialog_delete_title': 'Delete Application?',
      'dialog_delete_message':
          'Are you sure you want to delete this application?',
      'dialog_delete_all_title': 'Delete All Data?',
      'dialog_delete_all_message':
          'This will permanently delete all your application data.',
      'dialog_logout_title': 'Logout?',
      'dialog_logout_message': 'Are you sure you want to logout?',

      // Time
      'time_just_now': 'Just now',
      'time_minutes_ago': 'minutes ago',
      'time_hours_ago': 'hours ago',
      'time_days_ago': 'days ago',

      // Login
      'login_title': 'Login',
      'login_subtitle': 'Sign in to save your data to cloud',
      'login_google': 'Sign in with Google',
      'login_guest': 'Continue as Guest',
      'login_guest_note': 'Guest mode: Data only saved on this device',
    },
  };

  static String get(String key) {
    return _localizedStrings[currentLocale]?[key] ??
        _localizedStrings['en']?[key] ??
        key;
  }

  static void setLocale(String locale) {
    if (locale == 'id' || locale == 'en') {
      currentLocale = locale;
    }
  }

  static String get currentLanguageName {
    return currentLocale == 'id' ? 'Indonesia' : 'English';
  }
}
