# LEGO — The Infinity Human

[![CI](https://github.com/S-n-g-1/lego-the-infinity-human/actions/workflows/ci.yml/badge.svg)](https://github.com/S-n-g-1/lego-the-infinity-human/actions/workflows/ci.yml)

> Open-world adventure berbasis balok (LEGO-style) untuk PC (Windows/Linux), dibangun dengan **Godot 4.6** (GDScript, Jolt Physics, GL Compatibility).

Pemain berperan sebagai *Infinity Human* — minifigure yang terbangun di **Infinity Expanse**, alam semesta balok yang pecah menjadi fragmen dunia. Eksplorasi bioma, memecah objek menjadi balok, merakit ulang jembatan/kendaraan/gadget, dan memulihkan lima *World Fragment* untuk menyatukan kembali alam semesta.

## Status

| Item | Nilai |
| --- | --- |
| Fase | **M0 — Foundation** (lihat [ROADMAP](ROADMAP.md)) |
| Versi | `0.0.1` (scaffolding) |
| Engine | Godot 4.6, GDScript |
| Renderer | GL Compatibility |
| Physics | Jolt Physics |
| Target | PC — Windows & Linux, 1080p / 60 FPS |

## Mulai cepat

1. Buka proyek dengan **Godot 4.6** (`Project > Open` → pilih folder ini).
2. Tekan **F5** untuk menjalankan — bootstrap minimal `scenes/main/Main.tscn` aktif dan memindahkan state `BOOT → PLAYING`.
3. Struktur dasar sudah aktif: 4 autoload terdaftar di `project.godot`.

Autoload yang tersedia:

| Nama | File | Fungsi |
| --- | --- | --- |
| `EventBus` | `scripts/autoloads/EventBus.gd` | Sinyal global antar-sistem |
| `GameManager` | `scripts/autoloads/GameManager.gd` | State machine game |
| `SaveManager` | `scripts/autoloads/SaveManager.gd` | Save/load JSON di `user://saves` |
| `AudioManager` | `scripts/autoloads/AudioManager.gd` | Music/SFX & bus audio |

## Peta direktori

```text
.
├── addons/            # Plugin pihak ketiga (gdUnit4, dialogic, dll.)
├── assets/            # Aset mentah: art, audio, font, animasi, material
├── scenes/            # .tscn: main, world, characters, enemies, gameplay, ui, cutscenes
├── scripts/           # .gd: autoloads, systems, world, characters, enemies, ui, utils
├── resources/         # .tres: item, quest, character, upgrade, settings
├── data/              # JSON/CSV sebagai source of truth data table
├── docs/              # GDD, arsitektur, panduan, template  → docs/README.md
├── tests/             # Unit & integration test (gdUnit4)
├── tools/             # Editor script & generator konten
├── exports/           # Hasil export (di-gitignore)
├── CHANGELOG.md       # Log-update (Keep a Changelog + SemVer)
└── ROADMAP.md         # Milestone & kriteria kelulusan
```

Aturan penempatan detail ada di [`docs/architecture/overview.md`](docs/architecture/overview.md).

## Dokumentasi

- **Indeks dokumen:** [`docs/README.md`](docs/README.md)
- **GDD:** [`docs/gdd/00-overview.md`](docs/gdd/00-overview.md)
- **Panduan setup:** [`docs/guides/setup.md`](docs/guides/setup.md)
- **Standar kode:** [`docs/guides/coding-standards.md`](docs/guides/coding-standards.md)
- **Konvensi commit:** [`docs/guides/git-workflow.md`](docs/guides/git-workflow.md)

## CI

GitHub Actions menjalankan **lint GDScript** (`gdlint`) dan **tes gdUnit4** (Godot 4.6.3 headless) pada setiap push/PR ke `main`/`develop`. Detail & perintah lokal: [`docs/guides/ci.md`](docs/guides/ci.md).

## Konvensi singkat

- Commit: **Conventional Commits** (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`) — dipakai untuk mengisi CHANGELOG otomatis.
- Nama file: `snake_case.gd` / `PascalCase.tscn` untuk scene, `snake_case.tres` untuk resource.
- Bahasa dokumen: Indonesia; identifier kode: Inggris.

## Lisensi

Belum ditentukan. Tambahkan file `LICENSE` sebelum rilis publik (lihat checklist M6 di ROADMAP).
