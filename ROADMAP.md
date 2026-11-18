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
- [x] Input map 10 aksi (WASD, jump, sprint, build, vision, interact, pause)
- [x] Player minifigure: movement, kamera orbit third-person, lompat, sprint, health
- [x] Ground placeholder + pencahayaan untuk vertical slice
- [x] 4 unit test movement (total 12 test aktif)
- [ ] Brick breaking: objek pecah jadi pickup balok
- [ ] Build Mode: place 3 blueprint sederhana (jembatan, tangga, katapel)
- [ ] SATU quest: "Perbaiki Jembatan Nexus"
- [ ] HUD minimal: health, balok, objective

### M2 — Core Systems
- [ ] Inventory & Currency (Studs, Bricks, Cores)
- [ ] QuestManager + objective tracker
- [ ] Combat melee + gadget ranged
- [ ] Save/load 3 slot + checkpoint
- [ ] Creator Level & Blueprint Tree
- [ ] Unit test untuk tiap sistem (gdUnit4)

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
