-- =====================================================================
-- p05_ddl_25430029.sql
-- Milestone Proyek 5: DDL Perpustakaan Kampus
-- Nama : Hamid Indra Nugroho    NIM : 25430029    Kelas : B
-- Basis data : perpus_029       Akun kerja : dev_029
-- Jalankan   : mysql -u dev_029 -p perpus_029 < p05_ddl_25430029.sql
-- Dapat dijalankan ulang dari basis data kosong (blok DROP di awal).
--
-- Tabel tidak diberi CHARACTER SET sendiri, sehingga mewarisi
-- utf8mb4_unicode_ci dari basis data (kebijakan charset Modul 5).
-- Parameter P = 3 (NIM 25430029): batas P + 2 = 5 eksemplar (AB-04),
-- denda Rp3.000/hari (AB-09).
-- Komentar AB-xx merujuk p02_kebutuhan_data_25430029.md.
-- =====================================================================

USE perpus_029;

-- ---------------------------------------------------------------------
-- 0. Hapus tabel lama: urutan anak ke induk (kebalikan urutan buat)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS sanksi;
DROP TABLE IF EXISTS detail_penerimaan;
DROP TABLE IF EXISTS penerimaan;
DROP TABLE IF EXISTS detail_peminjaman;
DROP TABLE IF EXISTS peminjaman;
DROP TABLE IF EXISTS buku_pengarang;
DROP TABLE IF EXISTS eksemplar;
DROP TABLE IF EXISTS pengarang;
DROP TABLE IF EXISTS buku;
DROP TABLE IF EXISTS pemasok;
DROP TABLE IF EXISTS anggota;
DROP TABLE IF EXISTS petugas;

-- ---------------------------------------------------------------------
-- 1. Tabel master (tanpa kunci tamu)
-- ---------------------------------------------------------------------

-- petugas: pegawai perpustakaan (PB-10)
CREATE TABLE petugas (
  id_petugas      SMALLINT     NOT NULL AUTO_INCREMENT,
  nomor_petugas   CHAR(5)      NOT NULL,                  -- contoh PT-02
  nama_petugas    VARCHAR(100) NOT NULL,
  alamat_petugas  VARCHAR(255) NULL,                      -- data pribadi (hanya kepala)
  no_hp_petugas   VARCHAR(15)  NULL,                      -- data pribadi (hanya kepala)
  peran_petugas   ENUM('Petugas','Kepala') NOT NULL DEFAULT 'Petugas',  -- AB-11
  CONSTRAINT pk_petugas        PRIMARY KEY (id_petugas),
  CONSTRAINT uq_petugas_nomor  UNIQUE (nomor_petugas),
  CONSTRAINT ck_petugas_nomor  CHECK (nomor_petugas REGEXP '^PT-[0-9]{2}$')
) ENGINE=InnoDB;

-- anggota: mahasiswa atau dosen (PB-01, PB-08)
CREATE TABLE anggota (
  id_anggota              INT          NOT NULL AUTO_INCREMENT,
  nomor_anggota           CHAR(7)      NOT NULL,          -- contoh AG-0123
  nim_anggota             CHAR(8)      NULL,              -- wajib bila mahasiswa
  nidn_anggota            CHAR(10)     NULL,              -- wajib bila dosen
  nama_anggota            VARCHAR(100) NOT NULL,
  jenis_anggota           ENUM('Mahasiswa','Dosen') NOT NULL,
  prodi_unit_anggota      VARCHAR(100) NOT NULL,
  no_hp_anggota           VARCHAR(15)  NULL,              -- data pribadi (hanya kepala)
  alamat_anggota          VARCHAR(255) NULL,              -- data pribadi (hanya kepala)
  tanggal_daftar_anggota  DATE         NOT NULL,
  status_anggota          ENUM('Aktif','Ditangguhkan','Nonaktif') NOT NULL DEFAULT 'Aktif',  -- AB-03, AB-12
  CONSTRAINT pk_anggota          PRIMARY KEY (id_anggota),
  CONSTRAINT uq_anggota_nomor    UNIQUE (nomor_anggota),  -- AB-01
  CONSTRAINT uq_anggota_nim      UNIQUE (nim_anggota),    -- AB-02
  CONSTRAINT uq_anggota_nidn     UNIQUE (nidn_anggota),   -- AB-02
  CONSTRAINT ck_anggota_nomor    CHECK (nomor_anggota REGEXP '^AG-[0-9]{4}$'),            -- AB-01
  CONSTRAINT ck_anggota_nim      CHECK (nim_anggota  IS NULL OR nim_anggota  REGEXP '^[0-9]{8}$'),   -- kamus data: 8 digit
  CONSTRAINT ck_anggota_nidn     CHECK (nidn_anggota IS NULL OR nidn_anggota REGEXP '^[0-9]{10}$'),  -- kamus data: 10 digit
  CONSTRAINT ck_anggota_identitas CHECK (                                                 -- AB-02
        (jenis_anggota = 'Mahasiswa' AND nim_anggota  IS NOT NULL AND nidn_anggota IS NULL)
     OR (jenis_anggota = 'Dosen'     AND nidn_anggota IS NOT NULL AND nim_anggota  IS NULL))
) ENGINE=InnoDB;

-- pemasok: pemasok atau penerbit (PB-11)
CREATE TABLE pemasok (
  id_pemasok       SMALLINT     NOT NULL AUTO_INCREMENT,
  kode_pemasok     CHAR(6)      NOT NULL,                 -- contoh PS-007
  nama_pemasok     VARCHAR(100) NOT NULL,
  alamat_pemasok   VARCHAR(255) NULL,
  telepon_pemasok  VARCHAR(15)  NULL,
  CONSTRAINT pk_pemasok        PRIMARY KEY (id_pemasok),
  CONSTRAINT uq_pemasok_kode   UNIQUE (kode_pemasok),
  CONSTRAINT ck_pemasok_kode   CHECK (kode_pemasok REGEXP '^PS-[0-9]{3}$')
) ENGINE=InnoDB;

-- buku: satu judul (PB-07). Pengarang dipisah ke buku_pengarang (1NF).
CREATE TABLE buku (
  id_buku            INT          NOT NULL AUTO_INCREMENT,
  kode_buku          CHAR(7)      NOT NULL,               -- contoh BK-0045
  isbn_buku          CHAR(13)     NULL,                   -- unik bila ada
  judul_buku         VARCHAR(200) NOT NULL,
  penerbit_buku      VARCHAR(100) NOT NULL,
  tahun_terbit_buku  SMALLINT     NOT NULL,
  kategori_buku      VARCHAR(50)  NOT NULL,
  CONSTRAINT pk_buku        PRIMARY KEY (id_buku),
  CONSTRAINT uq_buku_kode   UNIQUE (kode_buku),
  CONSTRAINT uq_buku_isbn   UNIQUE (isbn_buku),           -- isu kualitas data no. 4
  CONSTRAINT ck_buku_kode   CHECK (kode_buku REGEXP '^BK-[0-9]{4}$'),
  CONSTRAINT ck_buku_isbn   CHECK (isbn_buku IS NULL OR isbn_buku REGEXP '^[0-9]{13}$'),
  CONSTRAINT ck_buku_tahun  CHECK (tahun_terbit_buku BETWEEN 1000 AND 9999)   -- kamus data: 4 digit
) ENGINE=InnoDB;

-- pengarang: kunci buatan karena nama orang tidak unik
CREATE TABLE pengarang (
  id_pengarang    INT          NOT NULL AUTO_INCREMENT,
  nama_pengarang  VARCHAR(100) NOT NULL,
  CONSTRAINT pk_pengarang PRIMARY KEY (id_pengarang)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. Tabel dengan kunci tamu
-- ---------------------------------------------------------------------

-- eksemplar: satu fisik buku (AB-06, AB-07, AB-14)
CREATE TABLE eksemplar (
  id_eksemplar            INT          NOT NULL AUTO_INCREMENT,
  no_eksemplar            CHAR(10)     NOT NULL,          -- contoh EKS-000231
  kondisi_eksemplar       ENUM('Baik','Rusak ringan','Rusak berat') NOT NULL DEFAULT 'Baik',
  status_eksemplar        ENUM('Tersedia','Dipinjam','Diperbaiki','Hilang') NOT NULL DEFAULT 'Tersedia',  -- AB-06
  tanggal_masuk_eksemplar DATE         NOT NULL,          -- AB-14
  lokasi_rak_eksemplar    VARCHAR(20)  NULL,
  id_buku                 INT          NOT NULL,          -- AB-07: tepat satu judul
  CONSTRAINT pk_eksemplar       PRIMARY KEY (id_eksemplar),
  CONSTRAINT uq_eksemplar_no    UNIQUE (no_eksemplar),
  CONSTRAINT ck_eksemplar_no    CHECK (no_eksemplar REGEXP '^EKS-[0-9]{6}$'),
  CONSTRAINT ck_eksemplar_berat CHECK (NOT (kondisi_eksemplar = 'Rusak berat' AND status_eksemplar = 'Dipinjam')),  -- AB-13
  CONSTRAINT fk_eksemplar_buku  FOREIGN KEY (id_buku) REFERENCES buku (id_buku)
) ENGINE=InnoDB;

-- buku_pengarang: relasi banyak-ke-banyak buku dan pengarang
-- CASCADE pada id_buku: katalog boleh dihapus (PB-07 memiliki D); pengarang dilindungi.
CREATE TABLE buku_pengarang (
  id_buku       INT NOT NULL,
  id_pengarang  INT NOT NULL,
  CONSTRAINT pk_buku_pengarang           PRIMARY KEY (id_buku, id_pengarang),
  CONSTRAINT fk_buku_pengarang_buku      FOREIGN KEY (id_buku)      REFERENCES buku (id_buku) ON DELETE CASCADE,
  CONSTRAINT fk_buku_pengarang_pengarang FOREIGN KEY (id_pengarang) REFERENCES pengarang (id_pengarang)
) ENGINE=InnoDB;

-- peminjaman: kepala slip (PB-02). Tidak ada ON DELETE CASCADE (AB-16).
CREATE TABLE peminjaman (
  id_peminjaman                  INT      NOT NULL AUTO_INCREMENT,
  nomor_peminjaman               CHAR(13) NOT NULL,       -- contoh PJM-2610-0007
  tanggal_pinjam_peminjaman      DATE     NOT NULL,
  tanggal_jatuh_tempo_peminjaman DATE     NOT NULL,       -- disimpan per transaksi (AB-05)
  status_peminjaman              ENUM('Berjalan','Selesai','Dibatalkan') NOT NULL DEFAULT 'Berjalan',  -- AB-16 (nilai: asumsi)
  id_anggota                     INT      NOT NULL,
  id_petugas                     SMALLINT NOT NULL,       -- AB-08
  CONSTRAINT pk_peminjaman          PRIMARY KEY (id_peminjaman),
  CONSTRAINT uq_peminjaman_nomor    UNIQUE (nomor_peminjaman),
  CONSTRAINT ck_peminjaman_nomor    CHECK (nomor_peminjaman REGEXP '^PJM-[0-9]{4}-[0-9]{4}$'),
  CONSTRAINT ck_peminjaman_tempo    CHECK (tanggal_jatuh_tempo_peminjaman >= tanggal_pinjam_peminjaman),  -- AB-05
  CONSTRAINT fk_peminjaman_anggota  FOREIGN KEY (id_anggota) REFERENCES anggota (id_anggota),
  CONSTRAINT fk_peminjaman_petugas  FOREIGN KEY (id_petugas) REFERENCES petugas (id_petugas)
) ENGINE=InnoDB;

-- detail_peminjaman: satu eksemplar dalam satu slip (PB-02, PB-03, PB-04)
-- hari_terlambat tidak disimpan (nilai turunan, keputusan Modul 4).
CREATE TABLE detail_peminjaman (
  id_peminjaman                       INT          NOT NULL,
  id_eksemplar                        INT          NOT NULL,   -- AB-06: yang dipinjam adalah eksemplar
  tanggal_kembali_detail_peminjaman   DATE         NULL,       -- kosong sebelum kembali
  kondisi_kembali_detail_peminjaman   ENUM('Baik','Rusak ringan','Rusak berat') NULL,
  catatan_pemeriksaan_detail_peminjaman VARCHAR(255) NULL,
  id_petugas_kembali                  SMALLINT     NULL,       -- AB-08: petugas penerima pengembalian
  CONSTRAINT pk_detail_peminjaman           PRIMARY KEY (id_peminjaman, id_eksemplar),
  CONSTRAINT ck_detail_peminjaman_kembali   CHECK (                                  -- isu kualitas data no. 6
        (tanggal_kembali_detail_peminjaman IS NULL     AND kondisi_kembali_detail_peminjaman IS NULL     AND id_petugas_kembali IS NULL)
     OR (tanggal_kembali_detail_peminjaman IS NOT NULL AND kondisi_kembali_detail_peminjaman IS NOT NULL AND id_petugas_kembali IS NOT NULL)),
  CONSTRAINT fk_detail_peminjaman_peminjaman FOREIGN KEY (id_peminjaman) REFERENCES peminjaman (id_peminjaman),
  CONSTRAINT fk_detail_peminjaman_eksemplar  FOREIGN KEY (id_eksemplar)  REFERENCES eksemplar (id_eksemplar),
  CONSTRAINT fk_detail_peminjaman_petugas    FOREIGN KEY (id_petugas_kembali) REFERENCES petugas (id_petugas)
) ENGINE=InnoDB;

-- sanksi: potret historis nominal (AB-09, AB-10, AB-11)
CREATE TABLE sanksi (
  id_sanksi             INT           NOT NULL AUTO_INCREMENT,
  nomor_sanksi          CHAR(11)      NOT NULL,            -- contoh SK-2610-003
  jenis_sanksi          ENUM('Denda','Ganti buku','Skorsing') NOT NULL,
  nominal_sanksi        DECIMAL(12,2) NULL,                -- wajib bila jenis Denda
  tanggal_sanksi        DATE          NOT NULL,
  status_lunas_sanksi   ENUM('Ya','Belum') NOT NULL DEFAULT 'Belum',   -- AB-12
  tanggal_lunas_sanksi  DATE          NULL,
  id_peminjaman         INT           NOT NULL,
  id_eksemplar          INT           NOT NULL,
  id_petugas            SMALLINT      NOT NULL,            -- penetap (harus Kepala, AB-11: lihat Modul 14)
  CONSTRAINT pk_sanksi           PRIMARY KEY (id_sanksi),
  CONSTRAINT uq_sanksi_nomor     UNIQUE (nomor_sanksi),
  CONSTRAINT ck_sanksi_nomor     CHECK (nomor_sanksi REGEXP '^SK-[0-9]{4}-[0-9]{3}$'),
  CONSTRAINT ck_sanksi_nominal   CHECK (nominal_sanksi IS NULL OR nominal_sanksi >= 0),         -- kamus data
  CONSTRAINT ck_sanksi_denda     CHECK (jenis_sanksi <> 'Denda' OR nominal_sanksi IS NOT NULL), -- AB-09
  CONSTRAINT ck_sanksi_lunas     CHECK (                                                        -- AB-12
        (status_lunas_sanksi = 'Ya'    AND tanggal_lunas_sanksi IS NOT NULL)
     OR (status_lunas_sanksi = 'Belum' AND tanggal_lunas_sanksi IS NULL)),
  CONSTRAINT ck_sanksi_tgl_lunas CHECK (tanggal_lunas_sanksi IS NULL OR tanggal_lunas_sanksi >= tanggal_sanksi),
  CONSTRAINT fk_sanksi_detail    FOREIGN KEY (id_peminjaman, id_eksemplar)
                                   REFERENCES detail_peminjaman (id_peminjaman, id_eksemplar),  -- isu kualitas data no. 7
  CONSTRAINT fk_sanksi_petugas   FOREIGN KEY (id_petugas) REFERENCES petugas (id_petugas)
) ENGINE=InnoDB;

-- penerimaan: kepala nota penerimaan buku (PB-06)
CREATE TABLE penerimaan (
  id_penerimaan              INT      NOT NULL AUTO_INCREMENT,
  nomor_nota_penerimaan      CHAR(11) NOT NULL,            -- contoh NT-2609-015
  tanggal_terima_penerimaan  DATE     NOT NULL,
  id_pemasok                 SMALLINT NOT NULL,
  id_petugas                 SMALLINT NOT NULL,            -- AB-08
  CONSTRAINT pk_penerimaan         PRIMARY KEY (id_penerimaan),
  CONSTRAINT uq_penerimaan_nota    UNIQUE (nomor_nota_penerimaan),
  CONSTRAINT ck_penerimaan_nota    CHECK (nomor_nota_penerimaan REGEXP '^NT-[0-9]{4}-[0-9]{3}$'),
  CONSTRAINT fk_penerimaan_pemasok FOREIGN KEY (id_pemasok) REFERENCES pemasok (id_pemasok),
  CONSTRAINT fk_penerimaan_petugas FOREIGN KEY (id_petugas) REFERENCES petugas (id_petugas)
) ENGINE=InnoDB;

-- detail_penerimaan: satu judul dalam satu nota (AB-15)
CREATE TABLE detail_penerimaan (
  id_penerimaan                      INT      NOT NULL,
  id_buku                            INT      NOT NULL,
  jumlah_diterima_detail_penerimaan  SMALLINT NOT NULL,
  CONSTRAINT pk_detail_penerimaan          PRIMARY KEY (id_penerimaan, id_buku),
  CONSTRAINT ck_detail_penerimaan_jumlah   CHECK (jumlah_diterima_detail_penerimaan > 0),   -- AB-15
  CONSTRAINT fk_detail_penerimaan_penerimaan FOREIGN KEY (id_penerimaan) REFERENCES penerimaan (id_penerimaan),
  CONSTRAINT fk_detail_penerimaan_buku       FOREIGN KEY (id_buku)       REFERENCES buku (id_buku)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. Aturan bisnis yang TIDAK dapat dijaga constraint (ditandai Modul 14)
-- ---------------------------------------------------------------------
-- AB-03 : anggota harus Aktif saat meminjam      -> melibatkan dua tabel
-- AB-04 : maksimal 5 eksemplar per transaksi (P+2) -> menghitung banyak baris
-- AB-06 : eksemplar Dipinjam tidak boleh dipinjam lagi -> lintas tabel
-- AB-11 : penetap sanksi harus berperan Kepala   -> lintas tabel
-- AB-12 : anggota dengan sanksi belum lunas ditangguhkan -> lintas tabel
-- AB-15 : nota minimal satu baris detail         -> menghitung banyak baris
-- Tanggal kembali >= tanggal pinjam, tanggal daftar tidak di masa depan,
-- dan tahun terbit <= tahun berjalan juga ditandai untuk Modul 14.
