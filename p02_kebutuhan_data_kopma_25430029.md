# Dokumen Kebutuhan Data - Koperasi Mahasiswa Sejahtera (Kopma)

**Nama:** Hamid Indra Nugroho   **NIM:** 25430029   **Kelas:** B

## 1. Latar belakang dan aktivitas organisasi

Kopma (fiktif) menjual alat tulis, makanan ringan, dan minuman di lingkungan kampus. Pembeli dapat berupa anggota atau umum. Mahasiswa mendaftar sebagai anggota dengan NIM, nama, program studi, dan nomor HP, lalu mendapat nomor anggota berformat A-xxxx. Anggota aktif memperoleh diskon 5% untuk setiap nota.

Tiga kasir bekerja bergantian per sif untuk mencatat penjualan dan mencetak nota. Setiap sore petugas gudang memeriksa stok, dan bila stok suatu barang di bawah batas minimum ia membuat pesanan pembelian ke pemasok. Saat barang datang, stok bertambah sesuai faktur pemasok. Setiap awal bulan ketua koperasi menerima laporan omzet, barang terlaris, barang dengan stok menipis, dan anggota paling aktif.

Tiga keluhan dari wawancara:

- Ketua: harga barang sering naik, sehingga nota lama membingungkan.
- Petugas gudang: stok di buku catatan kadang minus.
- Kasir: anggota sering lupa membawa kartu, sehingga pencarian dilakukan lewat NIM.

## 2. Aktor dan proses bisnis

PB-01 sampai PB-05 berasal dari identifikasi awal. PB-06 sampai PB-08 ditambahkan setelah pemeriksaan matriks CRUD (bagian 7).

| Kode | Proses bisnis | Aktor | Pemicu |
|------|---------------|-------|--------|
| PB-01 | Mendaftarkan anggota | Kasir (atas permintaan mahasiswa) | Mahasiswa ingin menjadi anggota |
| PB-02 | Mencatat penjualan | Kasir | Pembeli membayar di kasir |
| PB-03 | Memesan barang ke pemasok | Petugas gudang | Stok di bawah batas minimum |
| PB-04 | Menerima barang dari pemasok | Petugas gudang | Barang datang bersama faktur |
| PB-05 | Menyusun laporan bulanan | Ketua koperasi | Awal bulan |
| PB-06 | Mengelola data pemasok | Petugas gudang | Ada pemasok baru atau data pemasok berubah |
| PB-07 | Mengelola data barang | Petugas gudang | Ada barang baru atau data barang berubah |
| PB-08 | Mengelola status keanggotaan | Ketua koperasi | Status aktif anggota perlu diubah |

## 3. Dokumen sumber yang dianalisis

Dokumen sumber adalah nota penjualan PJ-2609-0142. Nota ini dibedah menjadi 13 isian.

Isian yang disimpan:

| Isian | Keterangan |
|-------|------------|
| Nomor nota | Unik per nota |
| Tanggal dan jam | Waktu transaksi |
| Kasir | Petugas yang mencatat |
| Anggota | Opsional, kosong untuk pembeli umum |
| Qty | Jumlah barang per baris |
| Harga satuan | Harga saat transaksi, per baris |
| Bayar tunai | Uang yang diterima |

Isian yang diambil dari data lain: nama barang (dari data barang).

Isian yang dihitung (nilai turunan): subtotal per baris, jumlah, diskon anggota 5%, total, dan kembali. Apakah total tetap disimpan atau tidak akan diputuskan di Modul 4.

## 4. Entitas kandidat dan elemen data

| Entitas kandidat | Elemen data utama | Sumber |
|------------------|-------------------|--------|
| Anggota | nomor anggota, NIM, nama, program studi, nomor HP, status aktif | Formulir pendaftaran |
| Barang | kode, nama, kategori, harga jual, stok, batas minimum stok | Daftar barang, faktur |
| Penjualan | nomor nota, tanggal-jam, kasir, anggota (opsional), bayar | Nota penjualan |
| Detail penjualan | nomor nota, barang, qty, harga saat transaksi | Nota penjualan |
| Petugas | kode petugas, nama, peran (kasir/gudang/ketua) | Wawancara |
| Pemasok | kode, nama, telepon, alamat | Faktur pemasok |
| Pembelian dan detailnya | nomor faktur, tanggal, pemasok, barang, qty, harga beli | Faktur pemasok |

## 5. Aturan bisnis

| Kode | Aturan bisnis |
|------|---------------|
| AB-01 | Setiap nota memiliki nomor unik dan minimal satu baris barang. |
| AB-02 | Penjualan boleh tanpa anggota (pembeli umum). Jika ada anggota, anggota harus berstatus aktif untuk memperoleh diskon 5%. |
| AB-03 | Stok barang tidak boleh negatif. Penjualan ditolak bila qty melebihi stok tersedia. |
| AB-04 | Harga jual yang dipakai pada nota disimpan per baris dan tidak berubah meski harga barang kemudian naik. |
| AB-05 | NIM anggota unik. Pencarian anggota dapat dilakukan lewat nomor anggota atau NIM. |
| AB-06 | Pesanan pembelian dibuat bila stok kurang dari batas minimum barang tersebut. |

## 6. Kebutuhan informasi

| Kode | Kebutuhan informasi | Data yang diperlukan |
|------|---------------------|----------------------|
| KI-01 | Omzet dan jumlah nota per hari dan per bulan | Penjualan, detail penjualan |
| KI-02 | Lima barang terlaris per bulan berdasarkan qty | Detail penjualan, barang |
| KI-03 | Barang dengan stok di bawah batas minimum | Barang |
| KI-04 | Sepuluh anggota dengan belanja terbesar per bulan | Penjualan, detail penjualan, anggota |

## 7. Matriks CRUD

Matriks di bawah sudah mencakup PB-06 sampai PB-08. Pada matriks awal, kolom Pemasok dan Barang tidak punya huruf C, dan kolom Anggota tidak punya huruf U. Ketiga proses tambahan itu menutup celah tersebut.

| Proses | Anggota | Barang | Penjualan | Detail | Pemasok | Pembelian |
|--------|---------|--------|-----------|--------|---------|-----------|
| PB-01 Daftar anggota | C | | | | | |
| PB-02 Catat penjualan | R | R, U | C | C | | |
| PB-03 Pesan ke pemasok | | R | | | R | C |
| PB-04 Terima barang | | U | | | R | U |
| PB-05 Laporan bulanan | R | R | R | R | | R |
| PB-06 Kelola pemasok | | | | | C, U | |
| PB-07 Kelola barang | | C, U | | | | |
| PB-08 Kelola status anggota | U | | | | | |

## 8. Kamus data awal

| Elemen | Arti | Contoh | Aturan | Penanggung jawab |
|--------|------|--------|--------|------------------|
| no_anggota | Nomor anggota koperasi | A-0457 | Unik, format A-4 digit | Ketua |
| nim_anggota | NIM anggota | 2301010123 | Unik, 10 digit | Ketua |
| no_hp_anggota | Nomor HP anggota | 0812xxxx | Data pribadi, akses terbatas | Ketua |
| no_nota_penjualan | Nomor nota penjualan | PJ-2609-0142 | Unik per nota | Kasir |
| harga_satuan_detail_penjualan | Harga jual saat transaksi | 4000 | Bilangan bulat ≥ 0 (rupiah) | Kasir |
| stok_barang | Jumlah barang tersedia | 35 | Bilangan bulat ≥ 0 (AB-03) | Petugas gudang |

## 9. Kebutuhan non-fungsional data

- **Volume:** perkiraan ±150 nota per hari.
- **Retensi:** data transaksi disimpan minimal lima tahun.
- **Privasi:** nomor HP anggota hanya boleh dilihat oleh ketua koperasi.

## 10. Isu kualitas data yang diantisipasi

- **Harga berubah:** harga barang bisa naik, sehingga nota lama berisiko menampilkan harga baru. Diantisipasi dengan menyimpan harga saat transaksi per baris (AB-04).
- **Stok negatif:** stok di buku sering minus. Diantisipasi dengan menolak penjualan yang melebihi stok (AB-03).
- **Anggota sulit dicari:** anggota sering lupa kartu. NIM harus unik dan bisa dipakai untuk mencari (AB-05).
- **Nilai turunan tidak konsisten:** bila total disimpan, total dan baris-barisnya bisa saling bertentangan setelah ada perbaikan. Keputusan penyimpanan total dibahas di Modul 4.
- **Proses data terlewat:** data pemasok, data barang, dan status anggota tadinya tidak punya proses pemeliharaan. Diantisipasi dengan PB-06, PB-07, dan PB-08.