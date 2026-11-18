# Arsitektur — Save System

> Versi: 0.1 | Implementasi: `scripts/autoloads/SaveManager.gd` | Terkait: `../gdd/11-technical.md`

## 1. Lokasi & Slot

```text
user://saves/
├── slot_00.json     # Slot manual 1
├── slot_01.json     # Slot manual 2
├── slot_02.json     # Slot manual 3
└── auto.json        # Auto-save (ditimpa)
```

Path di Linux biasanya `~/.local/share/godot/app_userdata/LEGO-The_infinity_human/saves/`.

## 2. Format File

```json
{
  "version": 1,
  "saved_at": "2026-11-18T14:32:10",
  "data": {
    "player": {
      "position": [12.5, 0.0, -4.0],
      "rotation_y": 1.57,
      "hp": 80.0,
      "suit": "suit_featherstep",
      "current_fragment": "brickwood"
    },
    "progression": {
      "creator_level": 4,
      "xp": 310,
      "fragments_restored": ["brickwood"]
    },
    "inventory": {
      "brick": 128,
      "stud": 450,
      "core": 3,
      "blueprint_fragments": 7,
      "blueprints": ["bridge_4m", "catapult"],
      "suits": ["suit_starter", "suit_featherstep"]
    },
    "quests": {
      "active": ["MS_002", "BC_003"],
      "completed": ["BC_001", "DS_001"],
      "progress": { "BC_003": { "obj_build": 1 } }
    },
    "world": {
      "broken_props": ["chunk_1_0_prop_12", "chunk_1_0_prop_19"],
      "built_structures": [
        { "blueprint": "bridge_4m", "position": [10, 0, -2], "rotation": 0 }
      ],
      "beacons_active": ["nexus", "brickwood_01"]
    },
    "settings": {
      "master_volume": 0.8,
      "ui_scale": 1.0,
      "colorblind": "deuteranopia"
    }
  }
}
```

## 3. Aturan Serialisasi

| Aturan | Alasan |
| --- | --- |
| Simpan **ID**, bukan object reference | Object bisa di-free saat load |
| Posisi sebagai array `[x,y,z]` | JSON tidak punya Vector3 |
| Dictionary untuk progress quest | Mudah di-merge saat migrasi |
| Float dibulatkan 3 desimal | Kurangi ukuran file |
| Tidak simpan enemy state | Musuh di-respawn sesuai chunk |
| Tidak simpan particle/audio state | Tidak relevan |

## 4. Atomic Write (wajib M2)

Tulis ke file temp dulu, baru rename:

```text
slot_00.json.tmp  →  (valid)  →  slot_00.json
```

Mencegah save korup jika game crash di tengah tulis. Implementasi di `SaveManager.save_game()` saat M2.

## 5. Migrasi Versi

```gdscript
func _migrate(payload: Dictionary) -> Dictionary:
	var v := int(payload.get("version", 0))
	while v < SAVE_VERSION:
		match v:
			0:
				# contoh: dulu field 'money', sekarang 'stud'
				payload["data"]["inventory"]["stud"] = payload["data"].get("money", 0)
				v = 1
			_:
				push_error("Versi save tidak dikenal: %d" % v)
				break
		payload["version"] = v + 1
	return payload
```

Aturan: **migrasi selalu maju satu versi**, jangan langsung loncat. Simpan file lama sebagai backup `.bak` sebelum migrasi.

## 6. Checkpoint & Auto-save

| Trigger | Slot | Catatan |
| --- | --- | --- |
| Checkpoint disentuh | `auto.json` | + toast "Tersimpan" |
| Quest besar selesai | `auto.json` | — |
| Fragment dipulihkan | `auto.json` | — |
| Tiap 5 menit | `auto.json` | Hanya saat `State.PLAYING` |
| Menu Save | slot pilihan player | Konfirmasi overwrite |
| Quit game | `auto.json` | Frontend kirim `save_game()` |

`EventBus.checkpoint_activated` → `SaveManager` dipanggil oleh `GameManager`, bukan langsung oleh checkpoint scene.

## 7. Edge Cases

| Kasus | Perlakuan |
| --- | --- |
| File tidak ada | `load_game()` return `{}`, UI tampil "Slot kosong" |
| JSON korup | Log error, tawarkan mulai baru, jangan crash |
| Versi lebih baru | Tolak load, pesan "Update game dulu" |
| Disk penuh | Tampilkan notifikasi, jangan hentikan gameplay |
| Save saat cutscene | Dicegah oleh `GameManager.State` |
| Balok hasil bongkar belum tersimpan | Event `structure_built`/`item_removed` langsung flip state |

## 8. Test Wajib

- [ ] Round-trip: save → load → data identik (kecuali `saved_at`)
- [ ] Load slot kosong tidak crash
- [ ] Load file korup tidak crash
- [ ] Migrasi v0 → v1 benar
- [ ] Auto-save tidak menimpa slot manual
- [ ] Prop yang sudah pecah tidak muncul lagi setelah load

## 9. Implementasi Saat Ini (M0)

`SaveManager.gd` sudah punya: `save_game(slot, data)`, `load_game(slot)`, `has_save(slot)`, pembuatan direktori otomatis, dan pengecekan `SAVE_VERSION`.

Belum ada: atomic write, migrasi, metadata UI, backup `.bak`.
