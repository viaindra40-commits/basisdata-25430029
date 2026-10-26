# Normalisasi Proyek - Pertemuan 04

**Nama:** Hamid Indra Nugroho   **NIM:** 25430029   **Kelas:** B
**Tema:** Perpustakaan   **Basis data:** `perpus_029`
**Organisasi fiktif:** Perpustakaan Kampus

Dokumen ini menormalisasi dokumen sumber proyek (slip peminjaman, p02 bagian 3.1) dari UNF sampai 3NF, lalu memeriksa BCNF. Dependensi diturunkan dari aturan bisnis (AB-xx) di `p02_kebutuhan_data_25430029.md`, bukan dari contoh data. Hasilnya dibandingkan dengan ERD proyek (`erd/p03_erd_25430029`).

## 1. Dokumen sumber dan bentuk UNF

Dokumen sumber: slip peminjaman (p02 bagian 3.1). Satu slip memuat satu transaksi dengan beberapa baris eksemplar (grup berulang, dalam kurung kurawal). Nama anggota, jenis anggota, kode buku, dan judul diambil dari data lain, tetapi dimasukkan ke UNF agar dependensinya terlihat.

```
SLIP_UNF (nomor_peminjaman, tanggal_pinjam_peminjaman, tanggal_jatuh_tempo_peminjaman,
          nomor_anggota, nama_anggota, jenis_anggota, nomor_petugas,
          { no_eksemplar, kode_buku, judul_buku,
            nomor_petugas_kembali, tanggal_kembali_detail_peminjaman,
            kondisi_kembali_detail_peminjaman,
            hari_terlambat_detail_peminjaman, denda_detail_peminjaman })
```

Slip hanya menulis kode petugas, bukan namanya. Relasi `petugas` tetap dibentuk karena kode itu merujuk ke entitas petugas (data kepegawaian, p02 bagian 3), lihat FD5. Atribut lain yang tidak tampil di slip (mis. NIM anggota, ISBN buku, status peminjaman) berasal dari dokumen sumber lain di p02 bagian 3 dan 4.

## 2. Dependensi fungsional

Setiap FD diturunkan dari aturan bisnis (AB-xx) di p02.

```
FD1:  nomor_peminjaman -> tanggal_pinjam_peminjaman, tanggal_jatuh_tempo_peminjaman,
                          status_peminjaman, nomor_anggota, nomor_petugas              (AB-05, AB-08, AB-16)
FD2:  nomor_anggota    -> nama_anggota, jenis_anggota, nim_anggota, nidn_anggota,
                          prodi_unit_anggota, no_hp_anggota, alamat_anggota,
                          tanggal_daftar_anggota, status_anggota                       (AB-01, AB-02)
FD3:  nim_anggota      -> nomor_anggota                                                (AB-01, AB-02, NIM unik)
FD4:  nidn_anggota     -> nomor_anggota                                                (AB-01, AB-02, NIDN unik)
FD5:  nomor_petugas    -> nama_petugas, alamat_petugas, no_hp_petugas, peran_petugas   (AB-08, AB-11)
FD6:  kode_buku        -> isbn_buku, judul_buku, penerbit_buku, tahun_terbit_buku,
                          kategori_buku                                                (AB-07)
FD7:  isbn_buku        -> kode_buku                                                    (ISBN unik bila ada)
FD8:  no_eksemplar     -> kode_buku, kondisi_eksemplar, status_eksemplar,
                          tanggal_masuk_eksemplar, lokasi_rak_eksemplar                (AB-06, AB-07, AB-14)
FD9:  (nomor_peminjaman, no_eksemplar)
         -> nomor_petugas_kembali, tanggal_kembali_detail_peminjaman,
            kondisi_kembali_detail_peminjaman, catatan_pemeriksaan_detail_peminjaman   (AB-06, AB-08, AB-10)
FD10: id_pengarang     -> nama_pengarang                                               (kamus data p02)
FD11: tanggal_pinjam_peminjaman, jenis_anggota -> tanggal_jatuh_tempo_peminjaman       (turunan, AB-05)
FD12: tanggal_jatuh_tempo_peminjaman, tanggal_kembali_detail_peminjaman
         -> hari_terlambat_detail_peminjaman                                           (turunan, AB-09)
FD13: hari_terlambat_detail_peminjaman -> denda_detail_peminjaman                      (turunan, AB-09)
```

- FD3, FD4, dan FD7 menunjukkan bahwa `nim_anggota`, `nidn_anggota`, dan `isbn_buku` juga penentu (kunci kandidat kedua).
- `kondisi_kembali_detail_peminjaman` sengaja tidak bergantung pada `no_eksemplar` saja (FD9): satu eksemplar dikembalikan berkali-kali dengan kondisi berbeda dan riwayatnya tidak boleh tertimpa (AB-16).
- Satu buku bisa punya lebih dari satu pengarang dan satu pengarang bisa menulis banyak buku (p02 bagian 8). Ini bukan FD melainkan hubungan banyak-ke-banyak, ditangani di tahap 1NF.

## 3. Tahapan normalisasi

| Tahap | Tindakan | Hasil (relasi dan kunci) |
|---|---|---|
| UNF → 1NF | Hilangkan grup berulang; satu baris per eksemplar per slip. Atribut multinilai `pengarang` pada `buku` (tidak di slip, tetapi ada di ERD) juga dikeluarkan ke relasi sendiri | `SLIP_1NF`, kunci `(nomor_peminjaman, no_eksemplar)`; `pengarang` dan `buku_pengarang` |
| 1NF → 2NF | FD1 dan FD2 (lewat slip) hanya bergantung pada `nomor_peminjaman`; FD6 dan FD8 (lewat eksemplar) hanya pada `no_eksemplar`; keduanya bergantung pada sebagian kunci, jadi dipisah. Yang bergantung pada seluruh kunci (FD9) tetap di detail | `peminjaman`, `eksemplar`, `detail_peminjaman` |
| 2NF → 3NF | Hapus rantai `nomor_peminjaman → nomor_anggota → nama_anggota, jenis_anggota` dan `no_eksemplar → kode_buku → judul_buku`; kode petugas dirujuk ke relasi sendiri (FD5). Nilai turunan (FD11 sampai FD13) tidak disimpan di relasi operasional (bagian 6) | `anggota`, `buku`, `petugas` dipisah |
| 3NF → BCNF | Periksa setiap penentu | Seluruh penentu adalah kunci kandidat; tidak ada perubahan |

Bentuk 1NF (satu baris per eksemplar per slip):

```
SLIP_1NF (nomor_peminjaman, no_eksemplar, tanggal_pinjam_peminjaman, tanggal_jatuh_tempo_peminjaman,
          nomor_anggota, nama_anggota, jenis_anggota, nomor_petugas, kode_buku, judul_buku,
          nomor_petugas_kembali, tanggal_kembali_detail_peminjaman, kondisi_kembali_detail_peminjaman,
          hari_terlambat_detail_peminjaman, denda_detail_peminjaman)
```

Slip PJM-2610-0007 memiliki dua eksemplar sehingga tampil dua baris, sementara data peminjam dan anggota berulang di kedua baris. Pengulangan inilah yang dihilangkan pada 2NF dan 3NF.

## 4. Skema akhir (3NF)

| Relasi | Kunci primer | Kunci tamu | Atribut lain |
|---|---|---|---|
| `peminjaman` | `nomor_peminjaman` | `nomor_anggota`, `nomor_petugas` | `tanggal_pinjam_peminjaman`, `tanggal_jatuh_tempo_peminjaman`, `status_peminjaman` |
| `detail_peminjaman` | (`nomor_peminjaman`, `no_eksemplar`) | `nomor_peminjaman`, `no_eksemplar`, `nomor_petugas_kembali` (opsional) | `tanggal_kembali_detail_peminjaman` (opsional), `kondisi_kembali_detail_peminjaman` (opsional), `catatan_pemeriksaan_detail_peminjaman` (opsional) |
| `eksemplar` | `no_eksemplar` | `kode_buku` | `kondisi_eksemplar`, `status_eksemplar`, `tanggal_masuk_eksemplar`, `lokasi_rak_eksemplar` |
| `buku` | `kode_buku` | - | `isbn_buku` (kunci kandidat kedua, unik bila ada), `judul_buku`, `penerbit_buku`, `tahun_terbit_buku`, `kategori_buku` |
| `pengarang` | `id_pengarang` | - | `nama_pengarang` |
| `buku_pengarang` | (`kode_buku`, `id_pengarang`) | `kode_buku`, `id_pengarang` | - |
| `anggota` | `nomor_anggota` | - | `nim_anggota` (unik, wajib bila mahasiswa), `nidn_anggota` (unik, wajib bila dosen), `nama_anggota`, `jenis_anggota`, `prodi_unit_anggota`, `no_hp_anggota`, `alamat_anggota`, `tanggal_daftar_anggota`, `status_anggota` |
| `petugas` | `nomor_petugas` | - | `nama_petugas`, `alamat_petugas`, `no_hp_petugas`, `peran_petugas` |

Catatan:
- `nomor_petugas_kembali` adalah kunci tamu ke `petugas.nomor_petugas`. Relasi `petugas` dirujuk dua kali dengan peran berbeda: yang melayani peminjaman dan yang menerima pengembalian (AB-08). Pada ERD ini menjadi `id_petugas` dan `id_petugas_kembali`.
- `pengarang` perlu kunci buatan (`id_pengarang`) karena nama orang tidak bisa dijadikan kunci unik.
- Denda tidak ada di `detail_peminjaman`; nominalnya disimpan di `sanksi` saat ditetapkan (AB-09, lihat bagian 6). `sanksi`, `penerimaan`, `detail_penerimaan`, dan `pemasok` berasal dari dokumen sumber lain (berita acara, nota penerimaan), bukan dari slip, sehingga tidak dinormalisasi di sini. `sanksi` merujuk `detail_peminjaman` lewat pasangan (`id_peminjaman`, `id_eksemplar`) pada ERD.

## 5. Pemeriksaan BCNF

| Relasi | Penentu | Kunci kandidat? | Lulus BCNF |
|---|---|---|---|
| peminjaman | `nomor_peminjaman` | Ya | Ya |
| detail_peminjaman | `(nomor_peminjaman, no_eksemplar)` | Ya | Ya |
| eksemplar | `no_eksemplar` | Ya | Ya |
| buku | `kode_buku` | Ya | Ya |
| buku | `isbn_buku` | Ya (kunci kandidat kedua, FD7) | Ya |
| pengarang | `id_pengarang` | Ya | Ya |
| buku_pengarang | `(kode_buku, id_pengarang)` | Ya (seluruh atribut adalah kunci) | Ya |
| anggota | `nomor_anggota` | Ya | Ya |
| anggota | `nim_anggota` | Ya (kunci kandidat kedua, FD3) | Ya |
| anggota | `nidn_anggota` | Ya (kunci kandidat ketiga, FD4) | Ya |
| petugas | `nomor_petugas` | Ya | Ya |

Tidak ada penentu yang bukan kunci kandidat, sehingga semua relasi memenuhi BCNF. FD11 sampai FD13 tidak muncul karena atribut turunannya tidak disimpan di relasi mana pun.

## 6. Keputusan nilai turunan

| Nilai turunan | Disimpan / dihitung | Alasan |
|---|---|---|
| `hari_terlambat_detail_peminjaman` | Dihitung | `tanggal_kembali − tanggal_jatuh_tempo`, minimal 0. Bila disimpan, koreksi tanggal membuatnya tidak cocok dengan tanggalnya (isu kualitas data no. 5). Pada ERD sudah ditandai atribut turunan |
| `denda_detail_peminjaman` | Dihitung di slip; nominal yang ditetapkan disimpan di `sanksi` | Hari terlambat × Rp3.000. Tarif bisa berubah, sedangkan sanksi yang sudah ditetapkan kepala perpustakaan adalah potret historis yang tidak boleh terhitung ulang (AB-09, AB-11) |
| `tanggal_jatuh_tempo_peminjaman` | Disimpan | Sebenarnya bisa dihitung dari tanggal pinjam dan lama pinjam jenis anggota (FD11), tetapi disimpan per transaksi agar tidak berubah bila lama pinjam kelak diubah (AB-05) |
| `nama_anggota`, `jenis_anggota`, `judul_buku` di slip | Tidak disimpan di `peminjaman` / `detail_peminjaman` | Diambil lewat join dari `anggota` dan `buku`, supaya tidak ada salinan ganda yang bisa berbeda |
| `status_eksemplar` | Disimpan di `eksemplar` | Nilai *Diperbaiki* dan *Hilang* tidak bisa diturunkan dari transaksi pinjam. Agar sinkron, status diubah oleh proses peminjaman dan pengembalian, bukan diketik manual (AB-06) |
| `status_peminjaman` | Disimpan di `peminjaman` | Secara prinsip bisa diturunkan dari ada tidaknya `tanggal_kembali` pada seluruh detail, tetapi AB-16 melarang hapus fisik dan mewajibkan perubahan lewat status. Risiko tidak sinkron dicegah dengan mengubahnya hanya lewat proses pengembalian (PB-03) |

Prinsipnya sama dengan Kopma: nilai yang bisa dihitung ulang dari fakta yang masih berubah tidak disimpan, kecuali ia adalah potret historis (jatuh tempo dan nominal sanksi).

## 7. Perubahan pada ERD proyek

ERD **berubah** pada dua hal. Struktur utama (peminjaman, detail_peminjaman, eksemplar, anggota, petugas, sanksi, penerimaan, detail_penerimaan, pemasok) tetap, dan atribut `status_peminjaman`, `catatan_pemeriksaan`, serta `id_petugas_kembali` pada ERD sudah sesuai hasil normalisasi.

**1. Atribut multinilai `pengarang` pada `buku` dipisah.** Kolom `pengarang` di ERD hanya satu kolom, padahal p02 bagian 8 menyatakan pengarang bisa lebih dari satu. Menulis beberapa nama dalam satu kolom melanggar 1NF dan memperparah isu kualitas data no. 3 (penulisan pengarang tidak seragam). Perubahan:
- tabel baru `pengarang` (`id_pengarang` PK, `nama_pengarang`);
- tabel baru `buku_pengarang` (`id_buku`, `id_pengarang`, keduanya PK sekaligus FK), hubungan `buku` 1 → 1..N `buku_pengarang` dan `pengarang` 1 → 0..N `buku_pengarang`;
- kolom `pengarang` dihapus dari `buku`.

**2. Penyesuaian nama kolom ke standar penamaan** (kolom berakhiran nama tabel):

| Tabel | Nama di ERD | Nama baru |
|---|---|---|
| anggota | `nim`, `nidn` | `nim_anggota`, `nidn_anggota` |
| anggota | `tanggal_daftar`, `status_keanggotaan` | `tanggal_daftar_anggota`, `status_anggota` |
| peminjaman | `tanggal_pinjam`, `tanggal_jatuh_tempo` | `tanggal_pinjam_peminjaman`, `tanggal_jatuh_tempo_peminjaman` |
| detail_peminjaman | `tanggal_kembali`, `kondisi_kembali`, `catatan_pemeriksaan`, `hari_terlambat` | tambahkan akhiran `_detail_peminjaman` |
| eksemplar | `tanggal_masuk` | `tanggal_masuk_eksemplar` |
| buku | `isbn`, `tahun_terbit` | `isbn_buku`, `tahun_terbit_buku` |
| sanksi | `status_lunas`, `tanggal_lunas` | `status_lunas_sanksi`, `tanggal_lunas_sanksi` |
| penerimaan | `nomor_nota_terima`, `tanggal_terima` | `nomor_nota_penerimaan`, `tanggal_terima_penerimaan` |
| detail_penerimaan | `jumlah_diterima` | `jumlah_diterima_detail_penerimaan` |

Seperti pada Kopma, normalisasi memakai kode alami sebagai kunci agar ketergantungannya mudah dibaca, sedangkan ERD sudah memakai kunci pengganti `id_<tabel>` dengan kode alami sebagai kunci alternatif (AK). Keduanya setara dan tidak ada perubahan struktur karenanya.

Versi ERD lama tidak dihapus; perubahan dicatat di pesan commit: `p04: normalisasi proyek perpustakaan; pisah pengarang, selaraskan nama kolom`.

## 8. Penamaan

Pemeriksaan terhadap standar buku:

- Nama tabel huruf kecil, snake_case, tunggal: `peminjaman`, `detail_peminjaman`, `eksemplar`, `buku`, `pengarang`, `buku_pengarang`, `anggota`, `petugas`. Semua memenuhi.
- Kolom berakhiran nama tabel: sebagian kolom pada ERD lama belum memenuhi (`nim`, `isbn`, `tanggal_pinjam`, dan seterusnya); daftar perbaikannya ada di bagian 7.
- Kunci primer `id_<tabel>`: ERD sudah memenuhi (`id_peminjaman`, `id_eksemplar`, dst.). Kode alami (`nomor_peminjaman`, `no_eksemplar`, `kode_buku`, `nomor_anggota`, `nomor_petugas`) menjadi kunci alternatif yang unik.
- Kunci tamu mengikuti nama kunci yang dirujuk; untuk peran kedua dipakai akhiran peran (`id_petugas_kembali`).
