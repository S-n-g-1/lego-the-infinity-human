# GDD 08 — UI / UX

> Versi: 0.1 | Terkait: `03-character-system.md`, `07-quests.md`

## 1. Prinsip UI

- **Readable chaos:** UI tenang di atas dunia yang sibuk. Gunakan panel gelap transparan + aksen kuning/cyan.
- **Satu layar, satu fokus.** Build Mode menyembunyikan HUD pertarungan.
- **Tanpa teks panjang.** Ikon + ≤ 8 kata per hint.
- **Konsisten warna:** kuning = interaktif, cyan = valid/build, merah = bahaya, hijau = selesai, abu = terkunci.

## 2. Layout HUD (Play Mode)

```text
┌──────────────────────────────────────────────────┐
│ [HP ████████] [Suit icon]      [Fragment 2/5]   │ ← kiri atas: status
│                                                  │
│                  ● objective marker              │ ← tengah: world marker
│                                                  │
│                                  🧱 128          │ ← kanan atas: material
│ [Quest: perbaiki menara 3/5]                     │ ← kiri bawah: tracker
│         [Q Vision] [B Build] [M Map]             │ ← bawah tengah: prompt
└──────────────────────────────────────────────────┘
```

Elemen:
| Elemen | Posisi | Muncul saat |
| --- | --- | --- |
| Health bar | Kiri atas | Selalu |
| Suit badge | Kiri atas | Selalu |
| Material counter | Kanan atas | Selalu (animasi saat bertambah) |
| Compass | Atas tengah | Saat quest aktif |
| Objective tracker | Kiri bawah | 1 main + 1 contract |
| Action prompt | Bawah tengah | Saat dekat interaksi |
| Notification toast | Kanan bawah | Event singkat, 3 dtk |

## 3. Build Mode UI

- Radial wheel 8 slot di sekitar crosshair (mouse) / D-pad (controller).
- Panel biaya di bawah wheel: `🧱 12  ⚙️ 0  💠 0`.
- Grid ghost + warna validasi (lihat `03-character-system.md`).
- Baris hint: `R = putar · Ctrl+Z = undo · X = bongkar · B = keluar`.
- HUD normal memudar ke 20% opacity saat Build Mode aktif.

## 4. Menu

| Menu | Isi | Shortcut |
| --- | --- | --- |
| Main | New Game, Continue, Settings, Credits, Quit | — |
| Pause | Resume, Quest Log, Inventory, Suit, Map, Settings, Save | `Esc` |
| Inventory | 4 tab + detail item | `I` |
| Blueprint Tree | 3 cabang, node lock/unlock | `K` |
| Map | Fragmen, Beacon, POI | `M` |
| Settings | Graphics, Audio, Controls, Accessibility, Language | — |
| Quest Log | Lihat `07-quests.md` | `J` |

Semua menu **bisa ditutup dengan `Esc`** dan mendukung navigasi keyboard penuh.

## 5. Font & Tipografi

| Usage | Font | Ukuran (1080p) |
| --- | --- | --- |
| Judul | `assets/fonts/display_bold.ttf` | 48–72 px |
| UI label | `assets/fonts/ui_regular.ttf` | 20–24 px |
| Body / dialog | `assets/fonts/ui_regular.ttf` | 22 px |
| Angka material | Font monospace internal | 26 px |

Font lisensi bebas (SIL OFL / CC0) — catat di `docs/guides/setup.md`. Pastikan fallback glyph UTF-8 untuk Bahasa Indonesia.

## 6. Feedback & Micro-interaction

| Aksi | Respons UI |
| --- | --- |
| Dapat balok | Counter membesar 1.15× + angka melayang |
| Quest update | Toast hijau + tracker berdenyut 1× |
| Blueprint unlock | Full-screen card 1.5 dtk, bisa di-skip |
| Save berhasil | Ikon floppy di pojok kanan 2 dtk |
| Error place | Ghost merah + bunyi "buzz" lembut |

## 7. Aksesibilitas (wajib M5, dasar sejak M1)

| Fitur | Detail |
| --- | --- |
| Remap kontrol | Semua aksi bisa diubah |
| Colorblind mode | 3 preset + ikon tambahan pada warna status |
| Subtitle | Dialog + SFX penting, ukuran 3 level |
| UI scale | 80% / 100% / 125% / 150% |
| Motion reduce | Matikan kamera shake, time dilation, parallax |
| Hold-to-confirm | Opsi untuk aksi destruktif |
| Skip day/night | Dari pause menu |
| Text speed | Sesuaikan kecepatan typewriter |

## 8. Lokalisasi

- Bahasa saat rilis: **Indonesia + English**. Struktur string pakai `TranslationServer` + CSV di `data/localization/`.
- Semua teks UI wajib pakai `tr("KEY")`, bukan literal di scene.
- Angka & satuan mengikuti locale (m vs ft, koma vs titik).

## 9. Implementasi (rencana)

```text
scenes/ui/HUD.tscn
scenes/ui/BuildWheel.tscn
scenes/ui/MenuPause.tscn
scenes/ui/InventoryPanel.tscn
scripts/ui/HUD.gd
scripts/ui/BuildWheel.gd
resources/settings/ui_theme.tres
```

UI mendengar `EventBus`: `currency_changed`, `inventory_changed`, `objective_updated`, `notification_requested`, `quest_*`, `build_mode_toggled`.

## 10. Checklist

- [ ] Theme `.tres` terpusat (warna, font, stylebox)
- [ ] Semua string lewat `tr()`
- [ ] UI scale tested di 720p & 1440p
- [ ] Test: Build Mode menyembunyikan HUD combat
