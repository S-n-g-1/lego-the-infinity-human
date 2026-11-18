# Indeks Dokumentasi

Seluruh dokumentasi proyek **LEGO — The Infinity Human**. Dokumen bersifat *living*: ikut berubah bersama implementasi.

## 1. Game Design Document (GDD)

| # | Dokumen | Topik |
| --- | --- | --- |
| 00 | [Overview](gdd/00-overview.md) | Visi, genre, audiens, USP, tone, scope |
| 01 | [Core Gameplay Loop](gdd/01-core-loop.md) | Loop utama, moment-to-moment, engagement |
| 02 | [World Design](gdd/02-world-design.md) | Struktur dunia, bioma, chunk, POI |
| 03 | [Character & Build System](gdd/03-character-system.md) | Player, Suit, mekanik balok/merakit |
| 04 | [Combat](gdd/04-combat.md) | Melee, gadget, musuh, bos |
| 05 | [Progression](gdd/05-progression.md) | XP, Creator Level, Blueprint Tree |
| 06 | [Items & Economy](gdd/06-items-economy.md) | Currency, inventory, crafting |
| 07 | [Quests](gdd/07-quests.md) | Main/side quest, contract, reward |
| 08 | [UI / UX](gdd/08-ui-ux.md) | HUD, menu, kontrol, aksesibilitas |
| 09 | [Narrative](gdd/09-narrative.md) | Story, karakter, lore, dialog |
| 10 | [Audio](gdd/10-audio.md) | Arah musik, SFX, dynamic layer |
| 11 | [Technical Design](gdd/11-technical.md) | Requirement, performa, data, testing |

## 2. Arsitektur Teknis

- [Overview](architecture/overview.md) — peta sistem, scene tree, aturan dependensi
- [Save System](architecture/save-system.md) — format data, migrasi, checkpoint

## 3. Panduan Kontributor

- [Setup Lingkungan](guides/setup.md)
- [Standar Kode](guides/coding-standards.md)
- [Menambah Konten Baru](guides/adding-content.md)
- [Alur Git & Konvensi Commit](guides/git-workflow.md)
- [CI GitHub Actions](guides/ci.md)

## 4. Template

- [Feature Spec](templates/feature-spec-template.md)
- [Architecture Decision Record (ADR)](templates/adr-template.md)
- [Bug Report](templates/bug-report-template.md)

## 5. Log & Perencanaan

- [CHANGELOG](../CHANGELOG.md) — catatan perubahan rilis
- [ROADMAP](../ROADMAP.md) — milestone & kriteria kelulusan

## Cara menjaga dokumen tetap hidup

1. Setiap perubahan gameplay **wajib** update bab GDD terkait di PR yang sama.
2. Keputusan teknis besar → buat ADR baru bernomor urut.
3. Fitur baru → isi Feature Spec sebelum coding (minimal untuk fitur M1 ke atas).
4. Rilis → pindahkan entri `Unreleased` di CHANGELOG ke versi baru.
