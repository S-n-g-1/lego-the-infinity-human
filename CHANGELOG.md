# Changelog

Semua perubahan signifikan pada proyek ini dicatat di file ini.

Format mengikuti [Keep a Changelog](https://keepachangelog.com/id/1.1.0/), dan versi mengikuti [Semantic Versioning](https://semver.org/lang/id/).

-type untuk perubahan: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.

## [Unreleased]

### Added
- Kerangka dokumentasi: GDD (12 bab), arsitektur, panduan, dan template (M0).
- Bootstrap minimal `scenes/main/Main.tscn` + `scripts/main/Main.gd`; transisi `BOOT → PLAYING` terverifikasi di mode headless.
- `run/main_scene` terdaftar di `project.godot`.
- Plugin gdUnit4 **v6.2.3** di `addons/gdUnit4/` dan aktif di Project Settings.
- 8 unit test contoh untuk `EventBus`, `SaveManager`, dan `GameManager` (semua lulus).
- Workflow CI GitHub Actions (`.github/workflows/ci.yml`): lint `gdlint` + test gdUnit4 headless, dengan upload artefak laporan.
- Panduan CI di `docs/guides/ci.md`.

### Changed
- _Belum ada._

### Fixed
- _Belum ada._

## [0.0.1] - 2026-11-18

### Added
- Inisialisasi proyek Godot 4.6 dengan renderer **GL Compatibility** dan physics **Jolt**.
- Struktur direktori standar: `assets/`, `scenes/`, `scripts/`, `resources/`, `data/`, `tests/`, `tools/`, `exports/`.
- Autoload fondasi: `EventBus`, `GameManager`, `SaveManager`, `AudioManager`.
- `README.md`, `ROADMAP.md`, `.gitignore`, `.editorconfig`, dan `.gitattributes`.

### Changed
- _Belum ada._

### Fixed
- _Belum ada._

[Unreleased]: https://example.com/lego-the-infinity-human/compare/v0.0.1...HEAD
[0.0.1]: https://example.com/lego-the-infinity-human/releases/tag/v0.0.1

> Catatan: ganti URL `example.com` dengan URL repository setelah Gitremote disiapkan.
> Entri baru ditambahkan di bawah `## [Unreleased]` dengan format:
> `- deskripsi singkat ([#123](link) [@username](link))`
