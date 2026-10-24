# Normalisasi Kopma - Pertemuan 04

**Nama:** Hamid Indra Nugroho   **NIM:** 25430029   **Kelas:** B   **Tanggal:** 20 Oktober 2026

Dokumen ini merangkum seluruh tahap normalisasi spreadsheet lama Kopma. Penjelasan lengkap dan jawaban Titik Analisis ada di `laporan/p04_laporan_25430029.md`.

## 1. UNF

Satu nota menyimpan grup berulang barang (dalam kurung kurawal).

```
NOTA_UNF (no_nota_penjualan, tgl_penjualan, kode_petugas, nama_petugas, no_anggota, nama_anggota,
          { kode_barang, nama_barang, qty_detail_penjualan,
            harga_satuan_detail_penjualan, subtotal_detail_penjualan },
          jumlah_penjualan, diskon_penjualan, total_penjualan, bayar_penjualan, kembali_penjualan)
```

## 2. Dependensi fungsional

Diturunkan dari aturan bisnis Pertemuan 2, bukan dari isi spreadsheet.

```
FD1:  no_nota_penjualan -> tgl_penjualan, kode_petugas, no_anggota, bayar_penjualan   (AB-01)
FD2:  kode_petugas      -> nama_petugas, peran_petugas
FD3:  no_anggota        -> nim_anggota, nama_anggota, prodi_anggota, no_hp_anggota,
                           status_anggota, tgl_daftar_anggota                          (AB-05)
FD4:  kode_barang       -> nama_barang, kategori_barang, harga_jual_barang,
                           stok_barang, stok_min_barang
FD5:  (no_nota_penjualan, kode_barang)
         -> qty_detail_penjualan, harga_satuan_detail_penjualan                        (AB-04)
FD6:  qty_detail_penjualan, harga_satuan_detail_penjualan
         -> subtotal_detail_penjualan                                                  (turunan)
FD7:  nim_anggota       -> no_anggota                                                  (AB-05, NIM unik)
FD8:  seluruh subtotal_detail_penjualan satu nota -> jumlah_penjualan                  (turunan)
FD9:  jumlah_penjualan, status_anggota -> diskon_penjualan, total_penjualan            (turunan, AB-02)
FD10: bayar_penjualan, total_penjualan -> kembali_penjualan                            (turunan)
```

![Dependensi fungsional](laporan/img/g03_fd.png)

## 3. Tahapan normalisasi

| Tahap | Tindakan | Hasil |
|---|---|---|
| UNF → 1NF | Hilangkan grup berulang; satu baris per barang per nota | `NOTA_1NF`, kunci `(no_nota_penjualan, kode_barang)` |
| 1NF → 2NF | FD1, FD2/FD3 (lewat nota) dan FD4 bergantung pada sebagian kunci; pisahkan | `penjualan`, `barang`, `detail_penjualan` |
| 2NF → 3NF | Hapus rantai `nota → petugas → nama_petugas` dan `nota → anggota → nama_anggota` | `petugas`, `anggota` dipisah |
| 3NF → BCNF | Periksa setiap penentu | Seluruh penentu adalah kunci kandidat |

![Hasil 1NF](laporan/img/g02_1nf.png)

## 4. Skema akhir (3NF)

| Relasi | Kunci primer (PK) | Kunci tamu (FK) | Atribut lain |
|---|---|---|---|
| `penjualan` | `no_nota_penjualan` | `kode_petugas`, `no_anggota` (opsional) | `tgl_penjualan`, `bayar_penjualan` |
| `detail_penjualan` | (`no_nota_penjualan`, `kode_barang`) | `no_nota_penjualan`, `kode_barang` | `qty_detail_penjualan`, `harga_satuan_detail_penjualan` |
| `barang` | `kode_barang` | - | `nama_barang`, `kategori_barang`, `harga_jual_barang`, `stok_barang`, `stok_min_barang` |
| `petugas` | `kode_petugas` | - | `nama_petugas`, `peran_petugas` |
| `anggota` | `no_anggota` | - | `nim_anggota` (kunci kandidat kedua, unik), `nama_anggota`, `prodi_anggota`, `no_hp_anggota`, `status_anggota`, `tgl_daftar_anggota` |

![Skema 3NF](laporan/img/g04_skema_3nf.png)

## 5. Pemeriksaan BCNF

| Relasi | Penentu | Kunci kandidat? | Lulus BCNF |
|---|---|---|---|
| penjualan | `no_nota_penjualan` | Ya | Ya |
| detail_penjualan | `(no_nota_penjualan, kode_barang)` | Ya | Ya |
| barang | `kode_barang` | Ya | Ya |
| petugas | `kode_petugas` | Ya | Ya |
| anggota | `no_anggota` | Ya | Ya |
| anggota | `nim_anggota` | Ya (kunci kandidat kedua, FD7) | Ya |

![Pemeriksaan BCNF](laporan/img/g06_bcnf.png)

## 6. Keputusan nilai turunan

| Nilai turunan | Keputusan | Alasan |
|---|---|---|
| `subtotal_detail_penjualan` | Tidak disimpan | Dihitung dari `qty × harga_satuan` pada detail |
| `jumlah_penjualan` | Tidak disimpan | Dijumlahkan dari seluruh subtotal detail satu nota |
| `diskon_penjualan` | Tidak disimpan | 5% dari jumlah bila anggota berstatus aktif, selain itu 0 (AB-02) |
| `total_penjualan` | Tidak disimpan | `jumlah - diskon` |
| `kembali_penjualan` | Tidak disimpan | `bayar_penjualan - total`; `bayar_penjualan` tetap disimpan karena uang yang diterima adalah fakta transaksi |

Menyimpan nilai turunan di tabel operasional berisiko tidak konsisten bila qty, harga, atau status anggota berubah. Keputusan ini akan ditinjau ulang pada tabel arsip penjualan (Buku 2 Modul 2), karena arsip adalah potret historis yang tidak boleh berubah.

## 7. Perbandingan dengan skema kanonik Kopma (Tabel 4.2)

| Aspek | Hasil saya | Skema kanonik |
|---|---|---|
| Kunci primer | Kunci alami | Kunci pengganti `id_*` |
| Kunci unik | `nim_anggota` (kunci kandidat kedua di `anggota`) | Kode alami (`no_nota_penjualan`, `kode_barang`, `kode_petugas`, `no_anggota`, `nim_anggota`) |
| Kunci tamu | `kode_petugas`, `no_anggota`, dst. | `id_petugas`, `id_anggota`, dst. |
| Tabel | 5 | 8 (+ `pemasok`, `pembelian`, `detail_pembelian`) |

Struktur ketergantungan sama; perbedaan utama hanya pada pemilihan kunci primer dan cakupan tabel.

ERD Kopma di Pertemuan 3 sudah memakai kunci pengganti `id_*` dan memuat 8 tabel, karena ERD dirancang dari dokumen kebutuhan data (P2) yang mencakup pembelian dan pemasok. Normalisasi di dokumen ini hanya menurunkan bagian penjualan dari spreadsheet lama, sehingga hasilnya 5 tabel dengan kunci alami. Tidak ada perubahan struktur terhadap ERD P3. Pada DDL (Pertemuan 5) kode alami tetap dijaga unik dan kunci primer memakai `id_*`.

## 8. Uji penggabungan kembali

Tabel hasil 3NF dibuat di SQLite (hanya sebagai alat bantu uji) lalu digabung kembali dengan kunci. Hasilnya identik dengan spreadsheet lama (4 baris), sehingga pemisahan tidak menghilangkan data dan tidak berlebihan.

![Uji penggabungan kembali](laporan/img/g05_gabung_kembali.png)

## 9. Catatan

- Contoh data memakai tahun 2026 dan `diskon_penjualan = 0` (pembeli umum) sebagai asumsi.
- Kolom `pemasok_brg` pada spreadsheet lama tidak masuk ke relasi penjualan; informasinya dijawab lewat `pembelian` dan `detail_pembelian` (Titik Analisis 3 di laporan).
- Milestone Proyek 04 (proyek mandiri, tema Klinik) ada di `p04_normalisasi_25430029.md`; ringkasannya di laporan bagian 6.
