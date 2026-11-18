# Roadmap Pengembangan

Milestone berbasis **vertical slice dulu, konten kemudian**. Status mengikuti nilai di `docs/gdd/11-technical.md`.

| Milestone | Versi | Fokus | Status | Exit Criteria |
| --- | --- | --- | --- | --- |
| **M0 — Foundation** | `0.0.x` | Repo, struktur folder, GDD, autoload, CI | 🟡 Berjalan | Dokumen inti selesai; proyek jalan di editor; convention commit disepakati |
| **M1 — Vertical Slice** | `0.1.0` | 1 bioma kecil, player, build mode, 1 quest | ⬜ Belum | 10 menit gameplay utuh: explore → pecah balok → bangun → objective selesai |
| **M2 — Core Systems** | `0.2.0` | Inventory, quest, combat, save/load, skill tree | ⬜ Belum | Semua sistem M2 punya test & bisa loop tanpa crash |
| **M3 — World & Biomes** | `0.3.0` | Chunk streaming, 3 bioma, fast travel, dynamic audio | ⬜ Belum | 3 bioma dapat dijelajahi tanpa loading screen; 60 FPS di target PC |
| **M4 — Content Complete** | `0.4.0` | 5 World Fragment, 20 quest, bos, NPC, cutscene | ⬜ Belum | Story main path bisa diselesaikan dari awal sampai ending |
| **M5 — Polish & QA** | `0.5.0` | UX, balansi, aksesibilitas, optimasi, bug fix | ⬜ Belum | 0 bug blocker; playtest eksternal ≥ 10 orang; checklist aksesibilitas lolos |
| **M6 — Demo / Release** | `1.0.0` | Export Windows/Linux, store page, LICENSE, docs final | ⬜ Belum | Build stabil ter-export; CHANGELOG & dokumentasi rilisFinal |

## Detail milestone

### M0 — Foundation *(saat ini)*
- [x] Init proyek Godot 4.6 + struktur direktori
- [x] Autoload dasar (EventBus, GameManager, SaveManager, AudioManager)
- [x] GDD bab 00–11 + arsitektur + panduan + template
- [x] Bootstrap minimal `Main.tscn` (state BOOT → PLAYING terverifikasi headless)
- [x] gdUnit4 v6.2.3 terinstal & plugin aktif; 8 test contoh lulus
- [x] CI GitHub Actions: gdlint + gdUnit4 (`.github/workflows/ci.yml`)
- [x] Setup Git & remote — `S-n-g-1/lego-the-infinity-human` (public, branch `main`)
- [x] Branch protection `main` (2 required checks: lint + gdUnit4)

### M1 — Vertical Slice
- [x] Input map 15 aksi (WASD, jump, sprint, attack, build, rotate, blueprint 1-3, vision, interact, pause)
- [x] Player minifigure: movement, kamera orbit third-person, lompat, sprint, health, attack
- [x] Ground placeholder + pencahayaan untuk vertical slice
- [x] Brick breaking: 6 prop pecah jadi pickup balok + stud (magnet ke player)
- [x] Inventory + QuestManager sebagai fondasi (ADR-004)
- [x] Build Mode: ghost placement, snap grid, 3 blueprint (jembatan, tangga, katapel)
- [x] SATU quest: "Perbaiki Jembatan Nexus" + NPC Vera menyeberang
- [x] HUD minimal: health, balok/stud, objective, hint build mode, notifikasi
- [x] 18 unit test aktif (movement, inventory, quest, resource, alur M1)

### M2 — Core Systems
- [x] Inventory & Currency — serialisasi Brick/Stud/Core/Fragment/Suit + save 3 slot
- [ ] Quest graph, prerequisite, dan failure state
- [x] Combat melee (kombo 3 hit + Mega Swing) & gadget Brick Blaster + Brick Grunt AI
- [x] Save/load 3 slot + auto + checkpoint + atomic write, backup, dan migrasi versi
- [x] Creator Level & XP (ADR-005) + reward XP dari quest
- [ ] Blueprint Tree berbasis Blueprint Fragment
- [x] Unit test sistem M2 (10 test baru; total 29 test aktif)

### M3 — World & Biomes
- [ ] WorldFragment streaming (chunk 64×64)
- [ ] Bioma: Brickwood, Sandbox, Frost Circuit, Neon Metropolis, Cosmic Void
- [ ] Fast travel antar *Waypoint Beacon*
- [ ] Dynamic music layer per bioma & state
- [ ] Profiling: target 60 FPS @ 1080p mid-range PC

### M4 — Content Complete
- [ ] 5 World Fragment + puzzle unik per bioma
- [ ] ≤ 20 quest samping + 5 Build Contract
- [ ] 5 bos guardian + 1 final boss
- [ ] NPC companion "Pixel" + sistem dialogue
- [ ] Cutscene opening & ending

### M5 — Polish & QA
- [ ] Remap control, controller support, subtitles
- [ ] Balansi kurva XP & economy
- [ ] Playtest eksternal + survei
- [ ] Optimasi draw call & memory

### M6 — Demo / Release
- [ ] Export preset Windows/Linux
- [ ] Store page, screenshot, trailer
- [ ] LICENSE + finalisasi dokumentasi
- [ ] Tag `v1.0.0` + rilis CHANGELOG

## Kebijakan perubahan roadmap
Roadmap ini living document. Perubahan prioritas dicatat di CHANGELOG under `Changed` dengan alasan singkat, dan keputusan besar wajib punya ADR (lihat `docs/templates/adr-template.md`).
