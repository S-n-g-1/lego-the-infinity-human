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
- Remote GitHub public `S-n-g-1/lego-the-infinity-human` dibuat; commit awal di-push ke `main`.
- CI first run hijau: lint + 8 test gdUnit4 lolos.
- Branch protection `main` aktif dengan required checks lint & gdUnit4.

### M1 — Vertical Slice (mulai)
- Input map 10 aksi melalui `tools/setup_input_map.gd` (WASD, lompat, sprint, build, vision, interact, pause).
- `Player.tscn` + `Player.gd`: CharacterBody3D, kamera orbit mouse, lompat, sprint, health, respawn.
- `PlayerMovement.gd`: kalkulasi movement murni yang bisa di-test.
- `Ground.tscn` sebagai lantai uji + directional light di `Main.tscn`.
- 4 unit test movement; total 12 test lulus.

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

[Unreleased]: https://github.com/S-n-g-1/lego-the-infinity-human/compare/v0.0.1...HEAD
[0.0.1]: https://github.com/S-n-g-1/lego-the-infinity-human/releases/tag/v0.0.1

> Entri baru ditambahkan di bawah `## [Unreleased]` dengan format:
> `- deskripsi singkat ([#123](link) [@username](link))`
