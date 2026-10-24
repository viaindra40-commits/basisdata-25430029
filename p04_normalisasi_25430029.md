# Normalisasi Proyek - Pertemuan 04

**Nama:** Hamid Indra Nugroho   **NIM:** 25430029   **Kelas:** B
**Tema:** Klinik (NIM berakhiran 29, rentang 25–49)   **Basis data:** `klinik_029`
**Organisasi fiktif:** [ISI nama organisasi dari p02]

> Kerangka milestone 4. Isi setiap bagian dari dokumen kebutuhan data (`p02_kebutuhan_data_25430029.md`) dan ERD proyek (`erd/p03_erd_25430029`) milikmu sendiri. Hapus catatan ini dan semua tanda [ISI] setelah selesai.

## 1. Dokumen sumber dan bentuk UNF

Dokumen sumber: [ISI, mis. formulir pendaftaran pasien / lembar kunjungan dari p02].

```
[ISI UNF: satu dokumen sumber, grup berulang ditulis dalam { }]
```

## 2. Dependensi fungsional

Setiap FD diturunkan dari aturan bisnis (AB-xx) di p02, bukan dari contoh data.

```
FD1: [ISI] -> [ISI]    (AB-xx)
FD2: [ISI]
```

## 3. Tahapan normalisasi

| Tahap | Tindakan | Hasil (relasi dan kunci) |
|---|---|---|
| UNF → 1NF | [ISI] | [ISI] |
| 1NF → 2NF | [ISI] | [ISI] |
| 2NF → 3NF | [ISI] | [ISI] |
| 3NF → BCNF | [ISI] | [ISI] |

## 4. Skema akhir (3NF)

| Relasi | Kunci primer | Kunci tamu | Atribut lain |
|---|---|---|---|
| [ISI] | [ISI] | [ISI] | [ISI] |

## 5. Pemeriksaan BCNF

| Relasi | Penentu | Kunci kandidat? | Lulus BCNF |
|---|---|---|---|
| [ISI] | [ISI] | [ISI] | [ISI] |

## 6. Keputusan nilai turunan

| Nilai turunan | Disimpan / dihitung | Alasan |
|---|---|---|
| [ISI] | [ISI] | [ISI] |

## 7. Perubahan pada ERD proyek

[ISI: ERD berubah atau tidak? Bila berubah, tulis apa yang berubah dan alasannya. Jangan hapus versi lama diam-diam; catat di pesan commit.]

## 8. Penamaan

Pastikan nama tabel dan kolom mengikuti standar buku: tabel huruf kecil snake_case tunggal, kolom berakhiran nama tabel (mis. `nama_pasien`), kunci primer `id_<tabel>`.
