# Dokumen Kebutuhan Data - Perpustakaan Kampus

**Nama:** Hamid Indra Nugroho  **NIM:** 25430029  **Kelas:** B

## 1. Latar belakang dan aktivitas organisasi

Perpustakaan kampus melayani mahasiswa dan dosen dalam peminjaman koleksi buku untuk mendukung pembelajaran dan penelitian. Aktivitas utamanya meliputi pendaftaran anggota, pencatatan peminjaman dan pengembalian, pemeriksaan keterlambatan atau kerusakan, penetapan dan pelunasan sanksi, penerimaan buku baru dari penerbit atau pemasok, serta pengelolaan katalog.

Saat ini pencatatan masih bertumpu pada dokumen (slip peminjaman, lembar pemeriksaan, nota penerimaan). Akibatnya data sulit dicari, rawan duplikat, dan status buku bisa tidak sinkron dengan kenyataan di rak. Dokumen ini merumuskan kebutuhan data sebagai dasar perancangan basis data yang terintegrasi.

Aktor internal: **Petugas** dan **Kepala perpustakaan**. Pihak luar: **Anggota** (mahasiswa atau dosen) dan **Pemasok/penerbit**.

## 2. Aktor dan proses bisnis

PB-01 sampai PB-09 berasal dari identifikasi awal. PB-10 dan PB-11 ditambahkan setelah pemeriksaan matriks CRUD (bagian 7), karena entitas Petugas dan Pemasok semula tidak di-create oleh proses mana pun.

| Kode | Proses bisnis | Aktor | Pemicu |
|------|---------------|-------|--------|
| PB-01 | Mendaftarkan anggota | Petugas | Mahasiswa atau dosen ingin menjadi anggota |
| PB-02 | Mencatat peminjaman | Petugas | Anggota membawa buku ke meja layanan |
| PB-03 | Mencatat pengembalian | Petugas | Anggota mengembalikan buku |
| PB-04 | Memeriksa keterlambatan atau kerusakan | Petugas | Buku kembali terlambat atau rusak |
| PB-05 | Menetapkan sanksi | Kepala perpustakaan | Petugas melaporkan hasil pemeriksaan |
| PB-06 | Menerima buku baru | Petugas (pemasok sebagai pihak luar) | Buku datang bersama nota |
| PB-07 | Mengelola katalog buku | Petugas | Ada buku baru atau data buku berubah |
| PB-08 | Mengelola status keanggotaan | Kepala perpustakaan | Status anggota perlu diubah |
| PB-09 | Mencatat pelunasan sanksi | Petugas | Anggota memenuhi sanksi |
| PB-10 | Mengelola data petugas | Kepala perpustakaan | Ada petugas baru atau data petugas berubah |
| PB-11 | Mengelola data pemasok | Petugas | Ada pemasok baru atau data pemasok berubah |

## 3. Dokumen sumber yang dianalisis

| Dokumen | Dipakai untuk | Proses terkait |
|---------|---------------|----------------|
| Formulir pendaftaran anggota | Data anggota | PB-01, PB-08 |
| Slip peminjaman | Data transaksi pinjam dan kembali | PB-02, PB-03 |
| Lembar pemeriksaan | Kondisi dan status eksemplar, keterlambatan | PB-04 |
| Berita acara pemeriksaan | Dasar penetapan sanksi | PB-05, PB-09 |
| Nota penerimaan buku | Data buku masuk | PB-06 |
| Katalog penerbit | Data bibliografi buku | PB-06, PB-07 |
| Data kepegawaian | Data petugas | PB-10 |

### 3.1 Pembedahan dokumen sumber fiktif: slip peminjaman

Dokumen berikut dirancang sendiri sebagai contoh. Satu slip memuat satu transaksi dengan beberapa baris eksemplar.

```
SLIP PEMINJAMAN - PERPUSTAKAAN KAMPUS
No. peminjaman : PJM-2610-0007        Tanggal pinjam : 06/10/2026
Anggota        : AG-0123 / Dewi Anjani   Jenis anggota : Mahasiswa
Petugas        : PT-02                Jatuh tempo    : 13/10/2026

No  No eksemplar  Judul              Tgl kembali  Kondisi kembali  Hari terlambat  Denda
1   EKS-000231    Basis Data         15/10/2026   Baik             2               Rp6.000
2   EKS-000450    Algoritma          13/10/2026   Rusak ringan     0               -
```

Isian yang disimpan, diambil dari data lain, atau dihitung:

| Isian | Status | Keterangan |
|-------|--------|------------|
| Nomor peminjaman | Disimpan | Unik per slip |
| Tanggal pinjam | Disimpan | Waktu transaksi |
| Tanggal jatuh tempo | Disimpan | Dihitung saat transaksi dari lama pinjam (AB-05), tetapi disimpan agar tidak berubah bila aturan lama pinjam kelak diubah |
| Nomor anggota | Disimpan | Rujukan ke anggota |
| Nama dan jenis anggota | Diambil dari data anggota | Tidak diketik ulang di slip |
| Nomor petugas | Disimpan | Rujukan ke petugas yang melayani (AB-08) |
| Nomor eksemplar | Disimpan | Per baris, kunci gabungan dengan nomor peminjaman |
| Judul | Diambil dari data buku | Lewat eksemplar |
| Tanggal kembali | Disimpan | Per baris, kosong sebelum dikembalikan |
| Kondisi kembali | Disimpan | Per baris, hasil pemeriksaan PB-04 |
| Hari terlambat | Dihitung (nilai turunan) | Tanggal kembali dikurangi tanggal jatuh tempo, minimal 0 |
| Denda | Dihitung, lalu nominalnya disimpan di sanksi saat ditetapkan | Hari terlambat x Rp3.000. Nominal disimpan karena tarif bisa berubah (AB-09) |

## 4. Entitas kandidat dan elemen data

| Entitas kandidat | Elemen data utama | Sumber |
|------------------|-------------------|--------|
| Anggota | **nomor anggota** (identitas), nama, jenis anggota, NIM (mahasiswa), NIDN (dosen), program studi/unit, no HP, alamat, tanggal daftar, status keanggotaan | Formulir pendaftaran |
| Buku | **kode buku** (identitas), ISBN, judul, pengarang (bisa lebih dari satu), penerbit, tahun terbit, kategori | Katalog penerbit |
| Eksemplar | **no eksemplar** (identitas), kode buku, kondisi, status, tanggal masuk, lokasi rak | Lembar pemeriksaan |
| Petugas | **nomor petugas** (identitas), nama, alamat, no HP, peran (petugas/kepala) | Data kepegawaian |
| Peminjaman | **nomor peminjaman** (identitas), nomor anggota, nomor petugas, tanggal pinjam, tanggal jatuh tempo, status | Slip peminjaman |
| Detail peminjaman | nomor peminjaman, no eksemplar, tanggal kembali, kondisi kembali, catatan pemeriksaan | Slip peminjaman, lembar pemeriksaan |
| Pemasok | **kode pemasok** (identitas), nama, alamat, telepon | Nota penerimaan |
| Penerimaan buku | **nomor nota** (identitas), kode pemasok, nomor petugas penerima, tanggal terima | Nota penerimaan |
| Detail penerimaan | nomor nota, kode buku, jumlah diterima | Nota penerimaan |
| Sanksi | **nomor sanksi** (identitas), nomor peminjaman + no eksemplar, jenis sanksi, nominal, tanggal sanksi, nomor petugas penetap (kepala), status lunas, tanggal lunas | Berita acara pemeriksaan |

## 5. Aturan bisnis

Tanda \* menandai asumsi yang perlu disesuaikan dengan kebijakan perpustakaan. Tanda (P) menandai aturan yang memakai parameter P (lihat bagian 9).

| Kode | Aturan bisnis |
|------|---------------|
| AB-01 | Satu anggota hanya punya satu nomor anggota, dan satu nomor anggota hanya milik satu orang. |
| AB-02 | Mahasiswa wajib punya NIM dan dosen wajib punya NIDN; keduanya unik. |
| AB-03 | Hanya anggota berstatus **aktif** yang boleh meminjam. |
| AB-04 | Satu transaksi peminjaman memuat paling banyak 5 eksemplar (P + 2) (P). |
| AB-05 | Lama pinjam 7 hari\* untuk mahasiswa dan 30 hari\* untuk dosen; tanggal jatuh tempo dihitung dari tanggal pinjam dan disimpan per transaksi. |
| AB-06 | Yang dipinjam adalah eksemplar, bukan judul. Eksemplar berstatus *dipinjam* tidak boleh dipinjam lagi. |
| AB-07 | Satu judul buku boleh punya banyak eksemplar; setiap eksemplar milik tepat satu judul. |
| AB-08 | Setiap transaksi pinjam, kembali, dan penerimaan mencatat petugas yang menangani. |
| AB-09 | Pengembalian setelah tanggal jatuh tempo dikenai denda Rp3.000 per hari per eksemplar (P). Nominal yang ditetapkan disimpan pada sanksi dan tidak berubah meski tarif kemudian diubah. |
| AB-10 | Buku rusak atau hilang dikenai sanksi (ganti buku atau denda) sesuai hasil pemeriksaan, dicatat per eksemplar. |
| AB-11 | Sanksi hanya ditetapkan oleh kepala perpustakaan berdasarkan laporan pemeriksaan. |
| AB-12 | Anggota dengan sanksi belum lunas berstatus ditangguhkan dan tidak boleh meminjam. |
| AB-13 | Eksemplar rusak berat tidak boleh dipinjamkan sampai diperbaiki atau dikeluarkan dari koleksi. |
| AB-14 | Setiap eksemplar baru dibuat dari penerimaan buku dan tercatat tanggal masuknya. |
| AB-15 | Setiap nota penerimaan memuat minimal satu judul dengan jumlah diterima lebih dari 0. |
| AB-16 | Data transaksi tidak dihapus fisik, hanya diubah statusnya agar riwayat tetap ada. |

## 6. Kebutuhan informasi

| Kode | Kebutuhan informasi | Pengguna | Data yang diperlukan |
|------|---------------------|----------|----------------------|
| KI-01 | Daftar anggota beserta status keanggotaan | Kepala, petugas | Anggota |
| KI-02 | Jumlah eksemplar tersedia untuk suatu judul saat ini | Petugas, anggota | Buku, eksemplar |
| KI-03 | Daftar buku yang sedang dipinjam seorang anggota | Petugas | Anggota, peminjaman, detail peminjaman, eksemplar, buku |
| KI-04 | Daftar eksemplar yang melewati tanggal jatuh tempo dan belum kembali, beserta hari terlambat | Petugas | Peminjaman, detail peminjaman |
| KI-05 | Riwayat peminjaman per anggota dan per judul | Petugas, kepala | Peminjaman, detail peminjaman, eksemplar, buku |
| KI-06 | Lima judul paling sering dipinjam per bulan | Kepala | Detail peminjaman, eksemplar, buku |
| KI-07 | Daftar eksemplar berkondisi rusak atau berstatus diperbaiki | Petugas | Eksemplar, buku |
| KI-08 | Daftar sanksi belum lunas per anggota | Kepala, petugas | Sanksi, anggota |
| KI-09 | Total denda yang ditetapkan dan yang sudah dilunasi per bulan | Kepala | Sanksi |
| KI-10 | Riwayat penerimaan buku per pemasok per bulan | Kepala | Penerimaan, detail penerimaan, pemasok |
| KI-11 | Jumlah judul dan eksemplar per kategori | Kepala | Buku, eksemplar |
| KI-12 | Jumlah transaksi peminjaman dan pengembalian yang dilayani tiap petugas per bulan | Kepala | Petugas, peminjaman |

## 7. Matriks CRUD

C = create, R = read, U = update, D = delete (dalam praktik berupa penonaktifan, lihat AB-16).

| Proses | Anggota | Buku | Eksemplar | Petugas | Peminjaman | Detail pinjam | Pemasok | Penerimaan | Detail terima | Sanksi |
|--------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| PB-01 Daftar anggota | C | | | R | | | | | | |
| PB-02 Catat peminjaman | R | R | R, U | R | C | C | | | | R |
| PB-03 Catat pengembalian | R | | U | R | U | U | | | | |
| PB-04 Periksa terlambat/rusak | | | R, U | R | R | R, U | | | | |
| PB-05 Tetapkan sanksi | R | | R | R | R | R | | | | C |
| PB-06 Terima buku baru | | R | C | R | | | R | C | C | |
| PB-07 Kelola katalog | | C, R, U, D | R, U | | | | | | | |
| PB-08 Kelola status anggota | R, U | | | R | | | | | | R |
| PB-09 Catat pelunasan sanksi | R | | | R | | | | | | R, U |
| PB-10 Kelola data petugas | | | | C, R, U, D | | | | | | |
| PB-11 Kelola data pemasok | | | | R | | | C, R, U, D | | | |

Pemeriksaan: setiap kolom entitas memiliki minimal satu huruf C. Pada matriks awal (PB-01 sampai PB-09), kolom Petugas dan Pemasok tidak punya C, sehingga ditambahkan PB-10 dan PB-11. Status aktif anggota diubah oleh kepala perpustakaan melalui PB-08.

## 8. Kamus data awal

Kamus memuat elemen penting dari tiap entitas. Penanggung jawab adalah pihak yang berwenang atas kebenaran dan perubahan data tersebut.

| Elemen | Arti | Contoh | Aturan | Penanggung jawab |
|--------|------|--------|--------|------------------|
| nomor_anggota | Nomor anggota perpustakaan | AG-0123 | Unik, format AG- dan 4 digit | Kepala perpustakaan |
| nama_anggota | Nama lengkap anggota | Dewi Anjani | Wajib, maksimal 100 karakter | Kepala perpustakaan |
| jenis_anggota | Mahasiswa atau dosen | Mahasiswa | Wajib; hanya dua nilai tersebut | Kepala perpustakaan |
| nim | Nomor induk mahasiswa | 25430029 | Wajib bila mahasiswa; unik; 8 digit | Kepala perpustakaan |
| nidn | Nomor induk dosen nasional | 0712038801 | Wajib bila dosen; unik; 10 digit | Kepala perpustakaan |
| no_hp_anggota | Nomor HP anggota | 0812xxxx | Data pribadi, akses terbatas (bagian 9) | Kepala perpustakaan |
| status_keanggotaan | Status anggota | Aktif | Aktif, Ditangguhkan, atau Nonaktif (AB-03, AB-12) | Kepala perpustakaan |
| tanggal_daftar | Tanggal anggota terdaftar | 02/09/2026 | Wajib; tidak boleh tanggal mendatang | Petugas |
| kode_buku | Kode judul buku | BK-0045 | Unik, format BK- dan 4 digit | Petugas |
| isbn | Nomor ISBN buku | 9786020000000 | Unik bila ada; 13 digit | Petugas |
| judul_buku | Judul buku | Basis Data | Wajib, maksimal 200 karakter | Petugas |
| pengarang | Nama pengarang | Elmasri | Wajib; bisa lebih dari satu | Petugas |
| tahun_terbit | Tahun terbit | 2016 | Angka 4 digit, tidak melebihi tahun berjalan | Petugas |
| no_eksemplar | Nomor fisik satu buku | EKS-000231 | Unik, format EKS- dan 6 digit | Petugas |
| kondisi_eksemplar | Kondisi fisik buku | Baik | Baik, Rusak ringan, atau Rusak berat (AB-13) | Petugas |
| status_eksemplar | Posisi buku | Tersedia | Tersedia, Dipinjam, Diperbaiki, atau Hilang (AB-06) | Petugas |
| tanggal_masuk | Tanggal eksemplar masuk koleksi | 01/09/2026 | Wajib, sama dengan tanggal terima (AB-14) | Petugas |
| nomor_petugas | Nomor pegawai perpustakaan | PT-02 | Unik, format PT- dan 2 digit | Kepala perpustakaan |
| peran_petugas | Peran pegawai | Petugas | Petugas atau Kepala; penetap sanksi harus Kepala (AB-11) | Kepala perpustakaan |
| nomor_peminjaman | Nomor transaksi peminjaman | PJM-2610-0007 | Unik per transaksi | Petugas |
| tanggal_pinjam | Tanggal transaksi pinjam | 06/10/2026 | Wajib | Petugas |
| tanggal_jatuh_tempo | Batas pengembalian | 13/10/2026 | Tidak boleh sebelum tanggal pinjam (AB-05) | Petugas |
| tanggal_kembali | Tanggal buku dikembalikan | 15/10/2026 | Kosong sebelum kembali; tidak sebelum tanggal pinjam | Petugas |
| kondisi_kembali | Kondisi saat dikembalikan | Rusak ringan | Sama dengan nilai kondisi_eksemplar | Petugas |
| kode_pemasok | Kode pemasok atau penerbit | PS-007 | Unik, format PS- dan 3 digit | Petugas |
| nomor_nota_terima | Nomor nota penerimaan | NT-2609-015 | Unik, sesuai nota fisik | Petugas |
| tanggal_terima | Tanggal buku diterima | 01/09/2026 | Wajib | Petugas |
| jumlah_diterima | Jumlah eksemplar per judul pada nota | 5 | Bilangan bulat lebih dari 0 (AB-15) | Petugas |
| nomor_sanksi | Nomor sanksi | SK-2610-003 | Unik | Kepala perpustakaan |
| jenis_sanksi | Jenis sanksi | Denda | Denda, Ganti buku, atau Skorsing | Kepala perpustakaan |
| nominal_sanksi | Nilai denda saat ditetapkan | 6000 | Bilangan bulat 0 atau lebih (rupiah); wajib bila jenis Denda (AB-09) | Kepala perpustakaan |
| status_lunas | Sanksi sudah dipenuhi atau belum | Belum | Ya atau Belum; menentukan AB-12 | Petugas |
| tanggal_lunas | Tanggal sanksi dipenuhi | 20/10/2026 | Kosong sebelum lunas; tidak sebelum tanggal sanksi | Petugas |

## 9. Kebutuhan non-fungsional data

### 9.1 Perhitungan parameter P

NIM 25430029, dua digit terakhir 29.

- P = (29 mod 9) + 1 = 2 + 1 = **3** (karena 29 = 3 x 9 + 2).
- Batas maksimal item per transaksi = P + 2 = **5** eksemplar (dipakai di AB-04).
- Denda harian = P ribu rupiah = **Rp3.000** per hari per eksemplar (dipakai di AB-09).
- Perkiraan volume transaksi harian = 40 + 5 x P = 40 + 15 = **55** transaksi per hari.

### 9.2 Kebutuhan lain

- **Volume**: sekitar 55 transaksi peminjaman per hari, dengan rata-rata beberapa eksemplar per transaksi. Pengembalian dicatat pada transaksi yang sama.
- **Retensi**: data transaksi dan sanksi disimpan minimal lima tahun\* dan tidak dihapus fisik (AB-16).
- **Data pribadi dan hak akses**:

| Data pribadi | Siapa yang boleh melihat |
|--------------|--------------------------|
| Nomor HP dan alamat anggota | Hanya kepala perpustakaan |
| Nama, nomor anggota, NIM, NIDN, status keanggotaan | Kepala dan petugas (diperlukan di meja layanan) |
| Alamat dan nomor HP petugas | Hanya kepala perpustakaan |
| Data sanksi per anggota | Kepala dan petugas; anggota hanya melihat miliknya sendiri |

  Pembatasan ini sejalan dengan kewajiban pengendali data dalam Undang-Undang Pelindungan Data Pribadi (UU No. 27 Tahun 2022). Penetapan sanksi dan perubahan status keanggotaan hanya dapat dilakukan kepala perpustakaan.
- **Integritas**: setiap kode identitas unik; tidak ada peminjaman tanpa anggota dan tidak ada sanksi tanpa detail peminjaman.
- **Jejak audit**: setiap perubahan transaksi, status, dan sanksi mencatat siapa dan kapan.
- **Kinerja**: pencarian buku berdasarkan judul atau kode pada meja layanan menampilkan hasil dalam 2 detik\*.
- **Cadangan**: backup harian; data dapat diakses selama jam layanan.

## 10. Isu kualitas data yang diantisipasi

| No | Isu | Dampak | Pencegahan | Penanggung jawab |
|----|-----|--------|------------|------------------|
| 1 | Anggota terdaftar ganda (NIM/NIDN sama, nomor berbeda) | Riwayat dan sanksi terpecah | NIM/NIDN unik, dicek saat pendaftaran (AB-02) | Kepala |
| 2 | Status eksemplar tidak sinkron dengan transaksi | Buku dipinjamkan dua kali | Status diubah dari transaksi, bukan diketik manual (AB-06) | Petugas |
| 3 | Penulisan pengarang dan penerbit tidak seragam ("Gramedia" dan "PT Gramedia") | Pencarian dan laporan tidak akurat | Aturan penulisan baku dan master pemasok | Petugas |
| 4 | ISBN salah atau ganda | Katalog duplikat | Validasi 13 digit dan ISBN unik | Petugas |
| 5 | Tanggal tidak logis (kembali sebelum pinjam) | Denda salah hitung | Validasi tanggal saat input | Petugas |
| 6 | Hasil pemeriksaan tidak dicatat saat pengembalian | Sanksi tidak dapat ditetapkan | Kondisi kembali wajib diisi pada PB-03 dan PB-04 | Petugas |
| 7 | Sanksi tidak terhubung ke peminjaman dan eksemplar | Sanksi tidak dapat ditelusuri | Sanksi wajib merujuk detail peminjaman | Kepala |
| 8 | Tarif denda atau lama pinjam berubah | Transaksi lama terhitung ulang dengan aturan baru | Simpan nominal pada sanksi dan jatuh tempo pada peminjaman (AB-05, AB-09) | Kepala |
| 9 | Jumlah pada nota tidak sama dengan eksemplar yang didaftarkan | Stok tidak akurat | Rekonsiliasi saat penerimaan (AB-14, AB-15) | Petugas |
| 10 | Riwayat tertimpa saat status diperbarui | Riwayat hilang | Tanpa hapus fisik dan jejak audit (AB-16) | Kepala |
