import 'package:isar/isar.dart';

part 'template.g.dart';

/// Template Category
enum TemplateCategory {
  whatsapp,
  email,
  tips;

  String get displayName {
    switch (this) {
      case TemplateCategory.whatsapp:
        return 'WhatsApp';
      case TemplateCategory.email:
        return 'Email';
      case TemplateCategory.tips:
        return 'Tips';
    }
  }
}

/// Chat/Email Template
@collection
class Template {
  Id id = Isar.autoIncrement;

  /// Template title
  late String title;

  /// Short description
  late String description;

  /// Template category
  @Enumerated(EnumType.name)
  late TemplateCategory category;

  /// Template content with placeholders
  /// Placeholders: {nama_hr}, {nama_perusahaan}, {posisi}, {tanggal}
  late String content;

  /// Whether this is a premium template
  late bool isPremium;

  /// Sort order
  int sortOrder = 0;
}

/// Default templates to seed in database
class DefaultTemplates {
  static List<Template> getAll() {
    return [
      // WhatsApp Templates
      Template()
        ..title = 'Follow Up HRD (Sopan)'
        ..description = 'Untuk menanyakan kabar lamaran dengan sopan'
        ..category = TemplateCategory.whatsapp
        ..content = '''Selamat pagi/siang Bapak/Ibu {nama_hr},

Perkenalkan, saya {nama_anda} yang telah melamar posisi {posisi} di {nama_perusahaan} pada tanggal {tanggal}.

Saya ingin menanyakan perkembangan proses rekrutmen untuk posisi tersebut. Apakah ada informasi lebih lanjut yang bisa saya ketahui?

Terima kasih atas perhatian dan waktunya.

Hormat saya,
{nama_anda}'''
        ..isPremium = false
        ..sortOrder = 1,
      Template()
        ..title = 'Konfirmasi Interview'
        ..description = 'Konfirmasi kehadiran jadwal interview'
        ..category = TemplateCategory.whatsapp
        ..content = '''Selamat pagi/siang Bapak/Ibu {nama_hr},

Terima kasih atas undangan interview untuk posisi {posisi} di {nama_perusahaan}.

Dengan ini saya konfirmasi kehadiran saya pada:
📅 Hari/Tanggal: {tanggal}
⏰ Waktu: {waktu}
📍 Lokasi: {lokasi}

Apakah ada dokumen atau persiapan khusus yang perlu saya bawa?

Terima kasih.

Hormat saya,
{nama_anda}'''
        ..isPremium = true
        ..sortOrder = 2,
      Template()
        ..title = 'Reschedule Interview'
        ..description = 'Minta ganti jadwal interview dengan sopan'
        ..category = TemplateCategory.whatsapp
        ..content = '''Selamat pagi/siang Bapak/Ibu {nama_hr},

Terima kasih atas undangan interview untuk posisi {posisi}.

Mohon maaf, saya mengalami kendala untuk hadir pada jadwal yang telah ditentukan ({tanggal_awal}) dikarenakan {alasan}.

Apakah memungkinkan untuk melakukan reschedule ke tanggal {tanggal_alternatif}?

Mohon maaf atas ketidaknyamanannya.

Hormat saya,
{nama_anda}'''
        ..isPremium = true
        ..sortOrder = 3,
      Template()
        ..title = 'Thank You After Interview'
        ..description = 'Ucapan terima kasih setelah interview'
        ..category = TemplateCategory.whatsapp
        ..content = '''Selamat pagi/siang Bapak/Ibu {nama_hr},

Terima kasih atas kesempatan interview yang telah diberikan untuk posisi {posisi} di {nama_perusahaan} kemarin.

Saya sangat menikmati diskusi kita dan semakin tertarik dengan peran ini. Saya yakin pengalaman dan kemampuan saya dapat berkontribusi positif untuk tim.

Saya menantikan kabar selanjutnya.

Hormat saya,
{nama_anda}'''
        ..isPremium = true
        ..sortOrder = 4,
      Template()
        ..title = 'Nego Gaji'
        ..description = 'Template negosiasi gaji yang profesional'
        ..category = TemplateCategory.whatsapp
        ..content = '''Selamat pagi/siang Bapak/Ibu {nama_hr},

Terima kasih atas tawaran posisi {posisi} di {nama_perusahaan}. Saya sangat senang dan tertarik dengan kesempatan ini.

Setelah mempertimbangkan tanggung jawab peran, pengalaman saya, dan standar industri, saya ingin mendiskusikan kompensasi yang ditawarkan.

Apakah ada ruang untuk negosiasi menuju kisaran {gaji_harapan}? Saya sangat fleksibel dan terbuka untuk diskusi lebih lanjut.

Terima kasih.

Hormat saya,
{nama_anda}'''
        ..isPremium = true
        ..sortOrder = 5,

      // Email Templates
      Template()
        ..title = 'Follow Up Formal (Email)'
        ..description = 'Email follow up lamaran yang formal'
        ..category = TemplateCategory.email
        ..content = '''Subject: Follow Up - Lamaran {posisi}

Yth. Bapak/Ibu HRD {nama_perusahaan},

Dengan hormat,

Saya {nama_anda} yang telah mengirimkan lamaran untuk posisi {posisi} pada tanggal {tanggal}.

Melalui email ini, saya ingin menanyakan perkembangan proses seleksi untuk posisi tersebut. Saya sangat antusias dengan kesempatan untuk bergabung dengan {nama_perusahaan} dan berkontribusi dengan kemampuan saya.

Saya sangat menghargai waktu dan pertimbangan Bapak/Ibu. Mohon informasikan jika ada dokumen tambahan yang diperlukan.

Terima kasih atas perhatiannya.

Hormat saya,
{nama_anda}
{nomor_hp}
{email}'''
        ..isPremium = true
        ..sortOrder = 6,
      Template()
        ..title = 'Accept Offer (Email)'
        ..description = 'Menerima tawaran kerja secara formal'
        ..category = TemplateCategory.email
        ..content = '''Subject: Acceptance - {posisi} Position

Dear {nama_hr},

I am delighted to formally accept the offer for the {posisi} position at {nama_perusahaan}.

I confirm the following terms:
- Position: {posisi}
- Start Date: {tanggal_mulai}
- Salary: {gaji}

I am excited to join the team and contribute to the company's success. Please let me know if there are any documents or formalities I need to complete before my start date.

Thank you for this opportunity.

Best regards,
{nama_anda}'''
        ..isPremium = true
        ..sortOrder = 7,
      Template()
        ..title = 'Decline Offer (Email)'
        ..description = 'Menolak tawaran dengan sopan'
        ..category = TemplateCategory.email
        ..content = '''Subject: Re: Offer for {posisi} Position

Dear {nama_hr},

Thank you so much for offering me the {posisi} position at {nama_perusahaan}. I truly appreciate the time and effort the team invested in the interview process.

After careful consideration, I have decided to decline this opportunity. This was not an easy decision, as I was impressed with the company and the team.

{alasan_singkat}

I hope our paths cross again in the future, and I wish {nama_perusahaan} continued success.

Thank you for your understanding.

Best regards,
{nama_anda}'''
        ..isPremium = true
        ..sortOrder = 8,
    ];
  }
}
