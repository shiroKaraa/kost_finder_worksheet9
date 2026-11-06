# Kost Finder 🏠

Aplikasi mobile berbasis Android yang dibangun menggunakan **Flutter** untuk membantu mahasiswa dan masyarakat umum mencari kos, serta membantu pemilik kos memasarkan properti mereka. Aplikasi ini merupakan hasil pengerjaan **Worksheet 9 - Authentication, Authorization & Push Notifications**.

## ✨ Fitur Utama

Aplikasi ini mengimplementasikan tiga pilar utama aplikasi modern:

1.  **Authentication (Supabase Auth)**
    *   Registrasi dan Login menggunakan Email & Password.
    *   Manajemen sesi (Session Persistence) otomatis.
    *   Fitur Logout yang aman.
2.  **Authorization (Role-Based Access Control)**
    *   **Pengguna (Pencari Kos):** Hanya dapat melihat daftar dan detail kos.
    *   **Pemilik Kost:** Dapat menambah, mengubah, dan menghapus kost miliknya sendiri.
    *   **Admin:** Memiliki hak akses penuh untuk memantau dan mengelola data.
    *   **Row Level Security (RLS):** Keamanan data ditegakkan langsung di level database Supabase, memastikan pengguna tidak dapat memanipulasi data milik orang lain meskipun mencoba mengakses API secara langsung.
3.  **Push Notification (Firebase Cloud Messaging)**
    *   Menerima notifikasi saat aplikasi dalam keadaan *Foreground* (SnackBar), *Background*, dan *Terminated* (Status Bar).
    *   Menyimpan FCM Token perangkat ke database Supabase (`device_tokens`).
    *   **Bonus:** Navigasi langsung ke halaman detail kost saat notifikasi diketuk (menggunakan *Custom Data* `kos_id`).

## 🛠️ Teknologi yang Digunakan

*   **Framework:** Flutter (Dart)
*   **Backend & Database:** Supabase (PostgreSQL, Auth, RLS)
*   **Push Notification:** Firebase Cloud Messaging (FCM)
*   **State Management & UI:** Flutter Material 3, FutureBuilder
*   **Version Control:** Git & GitHub

## 📂 Struktur Folder

```text
lib/
├── app_keys.dart              # Global key untuk navigasi & snackbar
├── firebase_options.dart      # Konfigurasi Firebase (Client Key)
├── main.dart                  # Entry point aplikasi
├── pages/
│   ├── home_page.dart         # Halaman utama (daftar kost & role)
│   ├── kos_detail_page.dart   # Halaman detail kost
│   ├── login_page.dart        # Halaman login
│   └── register_page.dart     # Halaman registrasi
├── services/
│   ├── auth_service.dart      # Logika autentikasi Supabase
│   ├── kos_service.dart       # CRUD data kost
│   ├── notification_service.dart # Logika FCM & token
│   └── profile_service.dart   # Pengambilan data profil & role
└── widgets/
    └── role_guard.dart        # Widget pembatas UI berdasarkan role