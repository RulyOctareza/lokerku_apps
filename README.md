<p align="center">
  <img src="docs/preview/hero.png" alt="LokerKu — ilustrasi aplikasi pelacak lamaran kerja" width="100%">
</p>

<h1 align="center">LokerKu</h1>

<p align="center">
  <b>Pelacak lamaran kerja pribadi.</b><br>
  Satu tempat untuk semua lamaran, status, dan jadwal interview — biar nggak ada yang kelewat.
</p>

<p align="center">
  <a href="https://flutter.dev"><img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white"></a>
  <a href="https://riverpod.dev"><img alt="Riverpod" src="https://img.shields.io/badge/State-Riverpod-blueviolet"></a>
  <a href="https://isar.dev"><img alt="Isar" src="https://img.shields.io/badge/Database-Isar-6E56CF"></a>
  <a href="https://firebase.google.com"><img alt="Firebase" src="https://img.shields.io/badge/Auth-Firebase-FFCA28?logo=firebase&logoColor=black"></a>
</p>

---

## ✨ Preview

<p align="center">
  <img src="docs/preview/hero.png" alt="Mockup gelap LokerKu" width="90%">
</p>

> **Catatan:** gambar di atas adalah *ilustrasi konsep*, bukan screenshot asli.

---

## 📖 Tentang

Lamar kerja di banyak tempat itu melelahkan — dan gampang lupa follow-up. LokerKu menyimpan
setiap lamaran sebagai kartu: posisi, perusahaan, tanggal, status, dan catatan interview.
Data tersimpan lokal dengan Isar sehingga tetap cepat dan bisa dibuka offline; login Google
dan Firestore dipakai untuk identitas serta sinkronisasi.

---

## 🌟 Fitur

| Fitur | Deskripsi |
|---|---|
| ➕ **Tambah Lamaran** | Simpan posisi, perusahaan, sumber lowongan, dan catatan. |
| 🗂️ **Daftar & Detail** | Lihat semua lamaran, buka detail, dan ubah status. |
| 🔎 **Pencarian** | Cari lamaran berdasarkan posisi atau perusahaan. |
| 📊 **Statistik** | Ringkasan progres lamaran dalam satu halaman. |
| 📄 **Template** | Template yang bisa dipakai ulang saat melamar. |
| 👤 **Profil & Auth** | Login Google via Firebase Authentication. |
| 🎓 **Onboarding** | Alur perkenalan singkat untuk pengguna baru. |
| 🌐 **Lokalisasi** | Dukungan bahasa melalui `localization`. |

---

## 🛠️ Tech Stack

| Area | Pilihan |
|---|---|
| Framework | Flutter (Dart 3) |
| State management | Riverpod + code generation |
| Database lokal | Isar |
| Auth & cloud | Firebase Auth, Cloud Firestore, Google Sign-In |
| Routing | GoRouter |
| UI | Phosphor Icons, Google Fonts, cached network images |

---

## 🧱 Struktur

```text
lib/
├── app.dart
├── core/
│   ├── constants/
│   ├── localization/
│   ├── router/
│   ├── theme/
│   └── utils/
└── features/
    ├── splash/
    ├── onboarding/
    ├── auth/
    ├── home/
    ├── add_job/
    ├── job_detail/
    ├── search/
    ├── stats/
    ├── templates/
    ├── profile/
    └── settings/
```

---

## 🚀 Menjalankan

```bash
flutter pub get

# generate Isar & Riverpod
dart run build_runner build --delete-conflicting-outputs

flutter run
```

Aktifkan Authentication (Google) dan Cloud Firestore di project Firebase-mu, lalu sesuaikan
`firebase_options.dart`.

---

## 🧪 Testing

```bash
flutter analyze
flutter test
```
