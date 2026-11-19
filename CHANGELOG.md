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

### M2 — Core Systems (quest graph & Blueprint Tree)
- `QuestDef` baru: `quest_type`, `prerequisites`, `next_quest`, `fail_on_player_death`.
- `QuestManager` jadi state machine `LOCKED → AVAILABLE → ACTIVE → COMPLETED/FAILED` dengan retry, rantai quest otomatis, objective `defeat`/`explore`/`talk`, dan serialisasi `states`/`failed`.
- Quest berantai: `bc_001 → sq_001 ("Bersihkan Nexus") → bc_002 ("Katapel Perdana")`; reward `fragment` masuk Inventory sebagai `blueprint_fragment`.
- `BlueprintNodeDef` + `BlueprintTree` autoload (ADR-006): 3 cabang (traversal/combat/utility), 8 node `.tres`, gate **Creator Level = slot** dan **Fragment = node**, unlock memberi blueprint/suit.
- UI Blueprint Tree dibuka dengan `T` (`BlueprintTreeUI.gd`), menampilkan alasan node terkunci; HUD kini menampilkan jumlah Fragment.
- `SaveGame` menyimpan & memulihkan `blueprint_tree`; urutan load `Inventory` → `BlueprintTree` menjaga reward node tetap terbuka.
- Isolasi state quest di test lama (snapshot `QuestManager.to_dict()` per test) agar chain tidak bocor antar suite.
- 9 unit test baru; total **50 test lulus**, lint & boot headless hijau.

### M2 — Core Systems (combat)
- `CombatMath.gd`: kalkulasi combo 3 hit, heavy hit ke-3 (break power 2), Mega Swing 3× (cooldown 4 dtk), resolved damage saat break power kurang, dan `can_hit()` berbasis arah + jarak.
- `EnemyDef.gd` & `DropTableDef.gd` + `.tres`: `enemy_brick_grunt.tres` (30 HP, 2.5 m/s, detect 12 m) dan `drop_table_grunt.tres` (6–10 balok, 5–8 Studs).
- `EnemyBase.gd`: state machine Patrol → Detect → Chase → Attack → Retreat → Pop; flash saat terkena, drop balok fisik, Studs, XP, dan sinyal `enemy_damaged`/`enemy_defeated`.
- `BrickProjectile.tscn/.gd`: Brick Blaster 8 damage, 1.2 dtk cooldown, klik kanan; otomatis nonaktif saat Build Mode.
- `Player.gd`: combo melee, charge Mega Swing, gadget, dan serangan yang kena group `breakable` **dan** `enemy`.
- `BrickGrunt.tscn`: 2 musuh ditambahkan ke `Main.tscn` sebagai uji combat.
- Input baru: `gadget` = klik kanan (17 aksi saat combat; sekarang 18 dengan `blueprint_tree`).
- 12 unit test baru; total **41 test lulus**.

### M2 — Core Systems (save & progression)
- `Progression` autoload (ADR-005): Creator Level & XP mengikuti tabel GDD 05, mendengar `EventBus.xp_gained`.
- Quest `bc_001` sekarang memberi 40 XP sebagai reward.
- `SaveManager` dimodernisasi: atomic write (`.tmp` → rename), backup `.bak`, migrasi v0→v1, metadata slot, `delete_slot()`, slot auto terpisah, dan `save_dir` yang bisa diubah untuk test.
- `Inventory.to_dict()/from_dict()`, `QuestManager.to_dict()/from_dict()`, `Player.to_dict()/from_dict()` untuk round-trip state.
- `SaveGame.gd`: orkestrasi snapshot player/progression/inventory/quest/world (prop pecah & struktur terpasang).
- `Checkpoint.tscn` memicu auto-save; auto-save juga tiap 5 menit dan saat quest besar selesai.
- Menu **Save/Load** (F6): 3 slot manual + 1 auto, menampilkan level & timestamp.
- HUD menampilkan Creator Level & XP.
- 10 unit test baru (SaveManager M2, Progression, serialisasi); total 29 test lulus.

### M1 — Vertical Slice (selesai)
- Input map 15 aksi melalui `tools/setup_input_map.gd` (WASD, lompat, sprint, attack, build, rotate, blueprint 1-3, vision, interact, pause; klik kiri untuk attack/pasang).
- `Player.tscn` + `Player.gd`: CharacterBody3D, kamera orbit mouse, lompat, sprint, health, respawn, serangan ke objek dalam jangkauan.
- `PlayerMovement.gd`: kalkulasi movement murni yang bisa di-test.
- `Ground.tscn` sebagai lantai uji + directional light di `Main.tscn`.
- `Inventory` & `QuestManager` autoload (+ ADR-004), resource `BlueprintDef` & `QuestDef`.
- `BreakableBrick.tscn` → `BrickPickup.tscn`: pecah, melayang, lalu magnet ke player; stud langsung masuk inventory.
- `BuildMode.gd`: ghost transparan, snap grid 0.5 m, rotasi 45°, cek biaya & tumpang tindih, pasang 3 struktur (jembatan, tangga, katapel).
- `NpcVera.tscn`: menyeberang otomatis setelah jembatan terpasang.
- Quest **`bc_001` — Perbaiki Jembatan Nexus** dengan 3 objective dan reward 30 stud + blueprint katapel.
- `HUD.tscn`: health, balok/stud, objective tracker, hint Build Mode, notifikasi.
- 18 unit test aktif: movement, inventory, quest, resource, dan simulasi alur M1 penuh — semuanya lulus.

### Changed
- _Belum ada._

### Fixed
- `HUD`: koneksi `EventBus.currency_changed` memakai handler berargumen `_on_currency_changed`; sebelumnya error "Method expected 0 arguments" muncul setiap kali stud bertambah saat memecah balok.
- Regresi test `tests/test_hud.gd` menambah cakupan sinyal inventory/currency.

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
