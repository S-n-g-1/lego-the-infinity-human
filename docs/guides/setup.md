# Panduan — Setup Lingkungan

## 1. Kebutuhan

| Software | Versi | Catatan |
| --- | --- | --- |
| Godot Engine | **4.6 stable** | https://godotengine.org |
| Git | ≥ 2.40 | Untuk branch & commit |
| gdUnit4 | latest | Plugin test (M0) |
| Text editor | bebas | VS Code + gdscript extension disarankan |
| Python | ≥ 3.10 | Opsional, untuk script `tools/` |

Tidak perlu C# / .NET untuk M0–M4. Keputusan C# dibahas di ADR-003.

## 2. Langkah Pertama

```bash
# 1. Clone / init repo
git init
git remote add origin <URL_REPO>

# 2. Buka di Godot
#    Godot 4.6 → Project → Open → pilih folder proyek ini

# 3. Verifikasi
#    - Project Settings → Autoload: 4 entri terdaftar
#    - Project Settings → Physics → 3d: Jolt Physics
#    - Project Settings → Rendering → GL Compatibility
#    - Tekan F5 → player spawn, kamera aktif, state "BOOT -> PLAYING"
#    - Kontrol: WASD jalan, mouse kamera, Space lompat, Shift sprint, klik kiri serang
#    - Tutorial: pecah balok → B → 1 → klik pasang jembatan → Vera menyeberang
#    - Input map dibuat ulang (jika perlu): godot --headless -s tools/setup_input_map.gd
```

## 3. Struktur Awal yang Sudah Ada

- 6 autoload: `EventBus`, `GameManager`, `Inventory`, `QuestManager`, `SaveManager`, `AudioManager`
- Folder lengkap sesuai `../architecture/overview.md`
- `.editorconfig` (UTF-8) & `.gitattributes`
- `.gitignore` (mengabaikan `.godot/`, `exports/`, log, save lokal)

## 4. gdUnit4 (sudah terinstal, v6.2.3)

Plugin ada di `addons/gdUnit4/` dan sudah aktif lewat `[editor_plugins]` di `project.godot`.

- UI editor: menu **gdUnit4 → Run Tests**
- CLI: lihat [`ci.md`](ci.md#3-menjalankan-locally)

Test ada di `tests/test_*.gd` (EventBus, SaveManager, GameManager, movement, inventory, quest, dan alur M1).

## 5. Font & Aset

- Simpan font di `assets/fonts/` dengan lisensi **SIL OFL / CC0**.
- Catat sumber lisensi di `assets/fonts/CREDITS.md`.
- Hindari aset LEGO® resmi sebelum izin clears (lihat `../gdd/00-overview.md`).

## 6. Konfigurasi Editor yang Disarankan

- `Editor > Editor Settings > Text Editor > Indent`: **Tab (4)** — mengikuti GDScript standar.
- Aktifkan `Debug > Visible Collision Shapes` saat mengerjakan physics.
- Simpan scene dengan `Ctrl+S` sebelum jalankan test.
- Gunakan `Ctrl+Shift+F` untuk cari referensi sinyal.

## 7. Menjalankan Generator Data

```bash
# Contoh (setelah tool tersedia di M1)
godot --headless --path . --script tools/generate_items.gd
```

Generator membaca `data/*.csv` dan menulis `resources/*.tres`. **Jangan edit `.tres` hasil generate.**

## 8. Masalah Umum

| Gejala | Solusi |
| --- | --- |
| Autoload "script not found" | Cek path di `project.godot`, pastikan file ada |
| Error Jolt tidak aktif | Project Settings → Physics → 3d → `Jolt Physics` |
| F5 tidak merespons | Cek `run/main_scene` di `project.godot` mengarah ke `scenes/main/Main.tscn` |
| Git mendeteksi `.godot/` | Pastikan `.gitignore` aktif & file belum ter-track |
| Font kotak-kotak | Pastikan glyph Latin + UTF-8, cek `.import` |

## 9. Checklist Kontributor Baru

- [ ] Godot 4.6 terinstal & proyek terbuka tanpa error
- [ ] Baca `../gdd/00-overview.md` & `../architecture/overview.md`
- [ ] Baca `coding-standards.md` & `git-workflow.md`
- [ ] Pilih satu issue kecil dari ROADMAP M0/M1 sebagai first task
