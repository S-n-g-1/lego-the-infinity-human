# ADR-006 — BlueprintTree sebagai Autoload

| Field | Isi |
| --- | --- |
| Nomor | ADR-006 |
| Tanggal | 2026-11-18 |
| Status | Accepted |
| Pembuat | Tim |
| Terkait | ADR-005, `../../gdd/05-progression.md`, `../../gdd/03-character-system.md` |

## Konteks

Blueprint Tree adalah progresi vertikal global: node terbuka dipakai Inventory, BuildMode, HUD, UI tree, dan save/load. Menaruhnya di dalam scene `Main` membuat aksesnya bergantung pada `get_tree()` dan rawan hilang saat scene berganti (M3 akan ada chunk/world streaming).

## Keputusan

> Tambahkan `BlueprintTree` sebagai autoload kedelapan. `BlueprintTree` memuat `BlueprintNodeDef` dari `res://resources/blueprints/*.tres`, menyimpan daftar node terbuka, dan membelanjakan `blueprint_fragment` lewat `EventBus.item_removed`.

Aturan penting sesuai GDD 05: **Creator Level membuka slot, Fragment membuka node**. Keduanya dicek di `get_lock_reason()`.

## Alternatif yang Dipertimbangkan

| Opsi | Kelebihan | Kekurangan |
| --- | --- | --- |
| Autoload (dipilih) | Akses global, ikut lifecycle game, mudah diserialisasi | Bertambah satu autoload |
| Node di `Main` | Tidak menambah autoload | Hilang saat scene berganti, butuh group lookup |
| Disimpan di `Inventory` | Fragment sudah di sana | Inventory jadi pengelola progresi, melanggar batas tanggung jawab |

## Konsekuensi

### Positif
- `SaveGame` cukup memanggil `BlueprintTree.to_dict()` / `from_dict()`.
- UI tree dan HUD bisa langsung memanggil `can_unlock()` / `is_unlocked()`.
- Quest reward `fragment` masuk ke Inventory, tree yang membelanjakan — alur jelas.

### Negatif / Trade-off
- Delapan autoload perlu pengawasan; ADR ini menjadi batas penambahan berikutnya.
- Node dengan `unlock_blueprint` kosong (root cabang) hanya berfungsi sebagai gate; akan diisi konten saat turret/grapple masuk.

## Implementasi

- [x] `scripts/systems/BlueprintTree.gd` + `BlueprintNodeDef.gd`
- [x] 8 node `.tres` di `resources/blueprints/`
- [x] UI tree dengan pintasan `T`
- [x] Serialisasi di `SaveGame`
- [ ] Node turret/grapple dengan konten blueprint nyata (M2 lanjutan)
