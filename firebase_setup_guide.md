# Panduan Setup Firebase & Google Cloud Firestore

Panduan ini akan membantu Anda menghubungkan proyek Flutter `my_dompet` dengan Firebase dan Google Cloud Firestore.

## 1. Persiapan di Firebase Console

1. Buka [Firebase Console](https://console.firebase.google.com/).
2. Klik **Add project** (Tambahkan proyek).
3. Masukkan nama proyek (misalnya: `my-dompet-app`) dan klik **Continue**.
4. (Opsional) Aktifkan Google Analytics untuk proyek ini, lalu klik **Create project**.
5. Tunggu hingga proyek selesai dibuat, lalu klik **Continue**.

## 2. Setup Firebase CLI & FlutterFire (Direkomendasikan)

Cara termudah untuk menghubungkan Firebase ke proyek Flutter Anda adalah menggunakan **FlutterFire CLI**.

1. Pastikan Anda sudah menginstal Node.js.
2. Buka terminal (Command Prompt/PowerShell) dan instal Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```
3. Login ke akun Google Anda melalui Firebase CLI:
   ```bash
   firebase login
   ```
4. Aktifkan Dart global untuk FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
5. Jalankan konfigurasi FlutterFire di dalam folder root proyek Anda (`d:\my_dompet`):
   ```bash
   flutterfire configure
   ```
6. Pilih proyek Firebase yang baru Anda buat dari daftar.
7. Pilih platform yang ingin Anda dukung (Android, iOS, Web).
8. Proses ini akan otomatis membuat file `lib/firebase_options.dart` dan mengonfigurasi file `google-services.json` (Android) serta `GoogleService-Info.plist` (iOS).

## 3. Setup Google Cloud Firestore

1. Di Firebase Console, pada menu sebelah kiri, pilih **Build > Firestore Database**.
2. Klik **Create database**.
3. Pilih **Start in test mode** (Pilih ini untuk tahap pengembangan awal agar mudah membaca/menulis data tanpa aturan ketat, **PENTING:** ubah aturan keamanan nanti sebelum rilis produksi).
4. Pilih lokasi Cloud Firestore (misalnya `asia-southeast2` untuk Jakarta) dan klik **Enable**.

## 4. Konfigurasi Struktur Database Firestore (Collections)

Berdasarkan model data yang ada di aplikasi Anda, berikut adalah struktur koleksi yang direkomendasikan di Firestore:

### Collection: `users`
- **Document ID:** `userId` (bisa didapatkan dari Firebase Auth UID)
- **Fields:**
  - `email` (String)
  - `name` (String)
  - `xp` (Number)
  - `level` (Number)
  - `badge` (String)
  - `achievements` (Array of Strings)
  - `totalSavings` (Number)
  - `goals` (Array of Objects - dari FinancialGoal)
  - `lastDailyClaim` (String/Timestamp)
  - `createdAt` (Timestamp)
  - `updatedAt` (Timestamp)

### Collection: `transactions`
- **Document ID:** Auto-generated atau ID unik
- **Fields:**
  - `userId` (String - referensi ke document di collection `users`)
  - `amount` (Number)
  - `category` (String)
  - `description` (String)
  - `date` (Timestamp)
  - `type` (String - "income" / "expense")
  - `receiptImageUrl` (String)
  - `ocrText` (String)

### Collection: `budgets`
- **Document ID:** Auto-generated atau ID unik
- **Fields:**
  - `userId` (String - tambahkan properti ini di model nanti)
  - `category` (String)
  - `amount` (Number)
  - `spent` (Number)
  - `month` (Timestamp)

## 5. Inisialisasi Firebase di Aplikasi

Di file `lib/main.dart`, pastikan inisialisasi menggunakan opsi yang dihasilkan oleh FlutterFire CLI:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // File ini dibuat oleh flutterfire cli

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: MyApp()));
}
```

## 6. Langkah Selanjutnya

Setelah setup Firebase selesai, Anda dapat mulai mengimplementasikan operasi CRUD (Create, Read, Update, Delete) ke Firestore menggunakan package `cloud_firestore` yang sudah ada di pubspec.yaml Anda.

Jika ada error terkait build Android, pastikan `minSdkVersion` di file `android/app/build.gradle` diset minimal ke `23` atau lebih tinggi.
