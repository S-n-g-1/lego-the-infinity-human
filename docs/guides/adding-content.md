# Panduan — Menambah Konten Baru

Panduan praktis untuk tugas paling sering: menambah item, quest, musuh, blueprint, dan bioma.

## 1. Aturan Umum

1. **Source of truth = `data/`.** Edit CSV/JSON, lalu jalankan generator.
2. **Jangan edit `.tres` hasil generate.**
3. **ID unik & stabil** — sekali dipakai, jangan diganti (dipakai save file).
4. Prefix ID: `item_`, `quest_`, `enemy_`, `bp_`, `frag_`.
5. Setelah tambah konten: update GDD terkait + CHANGELOG.

## 2. Menambah Item

**Langkah:**
1. Tambah baris di `data/items.csv`:

```csv
id,display_name,category,stack_size,sell_value,description
item_core_frost,Inti Es,material,99,15,"Core dari Frost Circuit."
```

2. Jalankan generator:
```bash
godot --headless --path . --script tools/generate_items.gd
```
3. Cek hasil di `resources/items/item_core_frost.tres`.
4. Tambah ikon di `assets/art/ui/icons/` dengan nama `<id>.png`.
5. Tambah drop ke `data/drop_tables.csv` jika item harus bisa didapat.
6. Tambah entri di `data/localization/id_ID.csv` & `en_US.csv`:
```csv
KEY,id_ID,en_US
ITEM_CORE_FROST,Inti Es,Frost Core
```

## 3. Menambah Quest

1. Tambah baris di `data/quests.csv` dengan objective & reward.
2. Buat file dialog di `data/dialog/<quest_id>.json`.
3. Generate: `godot --headless --script tools/generate_quests.gd`
4. Daftarkan prerequisite di `QuestDef` (ID quest lain).
5. Pastikan quest **mengubah dunia** (flag/POI/Suit) — lihat `../gdd/07-quests.md`.
6. Test: terima quest → selesai objective → reward → simpan & load → progress tetap.

Contoh objective:
```json
{ "id": "obj_build", "type": "build", "target": "bp_bridge_4m", "required": 1 }
```

## 4. Menambah Musuh

1. Baris baru di `data/enemies.csv` (HP, damage, speed, break_power, drop_table).
2. Generate `.tres` ke `resources/characters/`.
3. Buat scene `scenes/enemies/<Nama>.tscn` turunan `EnemyBase`.
4. Tambah stateAI di `scripts/enemies/<nama>.gd` jika perilaku unik.
5. Daftarkan spawn di `data/world/<fragment>/spawn.json`.
6. Test: break power lebih rendah dari syarat → elite tidak pecah total.

## 5. Menambah Blueprint

1. Buat scene struktur di `scenes/gameplay/structures/<nama>.tscn`.
2. Buat `resources/items/bp_<nama>.tres` lewat `data/blueprints.csv`:
   - `id`, `category`, `cost` (Dictionary), `scene_path`, `icon`
3. Tambah node di `Blueprint Tree` (`resources/upgrades/blueprint_tree.tres`).
4. Tambah ke radial wheel default jika termasuk 8 favorit awal.
5. Test: biaya > inventory → ghost merah, tidak bisa place; bongkar → refund penuh.

## 6. Menambah World Fragment / Bioma

> Ini lebih besar dari konten biasa — butuh ADR & update GDD `02-world-design.md`.

1. Tentukan `Build Rule` unik bioma (judul, efek, batasan).
2. Buat `resources/world/frag_<id>.tres`.
3. Buat chunk di `data/world/<frag>/chunk_x_z.json` via `tools/generate_chunks.gd`.
4. Tambah tema musik & ambience (lihat `../gdd/10-audio.md`).
5. Tambah Beacon, Shrine, bos, dan 3–5 POI per fragmen.
6. Update daftar unlock di `../gdd/05-progression.md`.
7. Test performa: ≤ 40 chunk aktif, 60 FPS @ target.

## 7. Menambah Dialog

1. Tambah node di `data/dialog/<id>.json`.
2. Field: `id`, `speaker`, `text_key`, `choices`, `condition`, `next`.
3. Gunakan `tr()` key dari file lokalisasi — jangan teks literal.
4. Test: pilihan → next node → `dialogue_finished` ter-emit.

## 8. Checklist Umum

- [ ] ID unik & tidak mengubah ID lama
- [ ] Generator dijalankan, `.tres` ter-update
- [ ] Ikon & lokalisasi tersedia
- [ ] GDD bab terkait di-update
- [ ] Test sistem inti lulus
- [ ] CHANGELOG `Unreleased` diisi
