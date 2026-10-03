-- p01_lingkungan_25430029.sql
-- Password sengaja diganti penanda. JANGAN commit password asli.
CREATE DATABASE IF NOT EXISTS kopma_029
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'mhs_029'@'localhost' IDENTIFIED BY '<password_kerja>';
GRANT ALL PRIVILEGES ON kopma_029.* TO 'mhs_029'@'localhost';