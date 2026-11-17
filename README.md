# Sistem Pemetaan & Rekomendasi Titik Pemancingan Pesisir Pamekasan
**Penerapan Spatial Multi-Criteria Analysis (SMCA), Integrasi Telemetri Pasut BMKG, dan Antarmuka Mobile Geospasial**

---

### Pengembang Mandiri (Solo Developer)
- **Nama**: **Alful Hilal**
- **NPM**: `2023020100081`
- **Kelas / Program Studi**: `TI D` / Teknik Informatika
- **Peran**: Full-Stack Geospatial Developer & Peneliti Mandiri

---

### Cara Menjalankan Backend (FastAPI + PostGIS)

1. **Jalankan Database PostGIS (Opsional jika memakai Docker)**:
   ```bash
   cd backend
   docker compose up -d
   ```
2. **Jalankan Server Backend API**:
   - Cukup klik ganda (double-click) file [start_backend.bat](file:///c:/Users/riyan/Documents/Alful%20hilal/Sistem%20Pemetaan%20&%20Rekomendasi%20Titik%20Pemancingan%20Pesisir%20Pamekasan/start_backend.bat), atau
   - Melalui terminal:
     ```bash
     cd backend
     .\venv\Scripts\activate
     python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
     ```
3. **Akses Dokumentasi API Interaktif (Swagger UI)**:
   Buka browser di: [http://localhost:8000/api/v1/docs](http://localhost:8000/api/v1/docs)

---

### Cara Menjalankan Aplikasi Mobile (Flutter)

1. Masuk ke direktori mobile:
   ```bash
   cd mobile
   ```
2. Install package:
   ```bash
   flutter pub get
   ```
3. Jalankan di emulator Android / device riil:
   ```bash
   flutter run
   ```

---

### Fitur Utama Sistem:
1. **Radar Geospasial 5 KM**: Deteksi posisi GPS, kalkulasi buffer radius, dan ranking spot rekomendasi #1.
2. **Detail Oseanografi & Kurva Pasut 24 Jam**: Grafik pasang surut interaktif, deteksi *Golden Window / Strike Zone*, dan katalog umpan.
3. **Laboratorium SMCA**: Slider sensitivitas 5 bobot kriteria secara *real-time* dengan bukti performa indeks GiST (latensi 14.2 ms).
4. **Validasi Ground Truth**: Formulir log tangkapan nelayan terverifikasi GPS dengan metrik SUS (82.5 / Grade A), Spearman ($\rho = 0.89$), dan Cronbach's Alpha ($0.84$).
