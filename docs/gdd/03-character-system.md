# GDD 03 — Character & Build System

> Versi: 0.1 | Terkait: `02-world-design.md`, `05-progression.md`, `06-items-economy.md`

## 1. Player: The Infinity Human

Minifigure dengan proporsi LEGO®: kepala silindris, tangan cakar, kaki bisa diputar. **Tanpa wajah tetap** — ekspresi muncul lewat animasi tubuh dan ikon, memudahkan identifikasi pemain.

| Atribut | Nilai awal | Catatan |
| --- | --- | --- |
| Health | 100 | 5 hati (20 each) |
| Movement speed | 6 m/s | +20% saat sprint |
| Jump height | 2.2 m | Double jump setelah Fragment 1 |
| Carry capacity | Unlimited | Balok tidak punya berat (lihat `06`) |
| Build range | 8 m | Bisa dinaikkan Suit "Architect" |
| Interaction range | 2.5 m | Magnet balok 2 m |

## 2. Kontrol Dasar (PC — Keyboard + Mouse)

| Aksi | Input | Alternatif |
| --- | --- | --- |
| Move | `W A S D` | Left stick |
| Kamera | Mouse | Right stick |
| Jump | `Space` | A / Cross |
| Sprint | `Shift` | L3 |
| Serang / Pecah | `Left Click` | X / Square |
| Gadget | `Right Click` | RB / R1 |
| Build Mode | `B` | D-pad Up |
| Builder Vision | `Q` | L1 |
| Radial Wheel | Hold `Wheel / Tab` | D-pad |
| Interact | `E` | A / Cross |
| Peta | `M` | Select |
| Pause | `Esc` | Options |

> Controller support masuk M5; daftar di atas sudah dipetakan agar tidak mengubah desain nanti.

## 3. Build Mode — Mekanik Inti

### 3.1 Alur
1. Tekan `B` → waktu melambat (0.25×), kamera orbit ke atas bahu.
2. Radial wheel muncul dengan blueprint yang **sedang diketahui** (maksimal 8 slot, scroll untuk halaman berikut).
3. Pilih blueprint → muncul ghost transparan dengan grid snap.
4. Gerakkan mouse untuk posisi; putar dengan `R` / scroll (rotasi 45°).
5. Warna ghost:
   - **Cyan** = valid
   - **Merah** = terhalang / balok kurang
   - **Kuning** = butuh 1 balok lagi
6. Klik untuk place → balok terpotong dari inventory.
7. `Ctrl+Z` = undo, `X` = bongkar struktur (balok kembali 100%, M2).

### 3.2 Grid & Snap
- Grid 0.5 m (mode Presisi: 0.25 m, unlock setelah Fragment 3).
- Snap ke permukaan: lantai, dinding, plafon, dan balok lain.
- Mode **Free Place** (tanpa grid) untuk dekorasi, unlock via Suit "Freehand".

### 3.3 Kategori Blueprint

| Kategori | Contoh | Fungsi |
| --- | --- | --- |
| Traversal | Jembatan, Tangga, Katapel | Menembus gap |
| Combat | Turret balok, Perisai, Landmine | Bertahan / serangan |
| Utility | Crane, Lift, Lamp, Magnet Pad | Interaksi lingkungan |
| Puzzle | Pressure plate, Relay, Mirror | Menyelesaikan teka-teki |
| Cosmetic | Patung, Bendera, House kit | Ekspresi (tidak memengaruhi quest) |

## 4. Suit System

Suit = **loadout kosmetik + gameplay modifier**, bukan kelas. Pemain bisa ganti kapan saja di Suit Station / pause menu (di luar combat).

| Suit | Unlock | Modifier |
| --- | --- | --- |
| Starter | Awal | Balanced |
| Featherstep | Fragment 1 | Double jump, +10% move |
| Builder | Blueprint Vault | Build range +4 m, snap lebih cepat |
| Bulwark | Fragment 2 | +40 HP, -10% speed |
| Comet | Fragment 3 | Air dash |
| Magnet | Sandbox | Magnet balok 6 m |
| Freehand |Fragment 4 | Free place |
| Architect | 30 Blueprint | Build range +8 m, undo 5 langkah |
| Voidwalker | Fragment 5 | Zero-G hop |

> Total 12 Suit di v1.0 (8 di tabel + 4 cosmetic-only).

## 5. Animasi & Feedback

| State | Feedback |
| --- | --- |
| Break objek | *pop* + 6–12 balok + SFX klik + Studs floating |
| Place struktur | *snap* sound + cyan flash + short camera shake |
| Terkena damage | Layar merah 0.2 dtk + minifigure terdorong |
| Suit ganti | Spin 360° + sparkle + change SFX |
| Build Mode masuk | Time dilation + UI vignette biru |

## 6. Aturan Desain Karakter

- **Tidak ada damage dari falling** di luar bos (menghukum eksplorasi = tidak).
- **Respawn 3 detik** di checkpoint terdekat, tanpa kehilangan balok.
- **Semua modifier Suit bisa dimatikan** di menu aksesibilitas (opsi "classic mode").

## 7. Implementasi Godot (rencana)

```text
scenes/characters/Player.tscn
├── CharacterBody3D (Player)
│   ├── CollisionShape3D
│   ├── Skeleton3D / MeshInstance3D (minifigure)
│   ├── CameraRig (Node3D)
│   │   └── Camera3D
│   ├── BuildAnchor (Marker3D)
│   └── AnimationTree
scripts/characters/Player.gd
scripts/characters/PlayerMovement.gd
scripts/systems/BuildMode.gd
resources/characters/suit_starter.tres
```

Sinyal yang dipakai: `EventBus.player_spawned`, `player_health_changed`, `suit_changed`, `build_mode_toggled`, `structure_built`.

## 8. Checklist

- [ ] `Suit` resource (`id`, `modifiers: Dictionary`, `unlock_condition`)
- [ ] `Blueprint` resource (`id`, `cost: Dictionary`, `category`, `scene`)
- [ ] Build Mode state di `GameManager` (tambah `State.BUILD`)
- [ ] Undo stack & refund balok
- [ ] Test: place → undo → inventory kembali utuh
