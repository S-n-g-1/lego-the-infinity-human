# ADR-004 — Inventory dan QuestManager sebagai Autoload

| Field | Isi |
| --- | --- |
| Nomor | ADR-004 |
| Tanggal | 2026-11-18 |
| Status | Accepted |
| Pembuat | Tim |
| Terkait | `../../architecture/overview.md`, `../../gdd/06-items-economy.md` |

## Konteks

M1 membutuhkan material balok yang dipakai bersama oleh pickup, Build Mode, HUD, dan quest tutorial. Jika tiap sistem menyimpan salinan sendiri, jumlah balok bisa tidak sinkron. Quest juga perlu mendengar event dari beberapa sistem tanpa saling merujuk langsung.

## Keputusan

> Tambahkan `Inventory` dan `QuestManager` sebagai autoload kelima dan keenam, setelah `GameManager` dan sebelum `SaveManager`.

Keduanya hanya menyimpan state & aturan; semua notifikasi tetap lewat `EventBus`.

## Alternatif yang Dipertimbangkan

| Opsi | Kelebihan | Kekurangan |
| --- | --- | --- |
| Autoload (dipilih) | Akses konsisten, mudah di-test | Jumlah autoload bertambah |
| Node di `Main.tscn` + group lookup | Tidak menambah autoload | Perlu `get_first_node_in_group` di banyak tempat |
| State di `GameManager` | Satu autoload | GameManager jadi god object |

## Alasan

Jumlah autoload masih wajar (6), dan aturan `docs/architecture/overview.md` tetap dipatuhi: event lintas sistem lewat EventBus, query lewat fungsi publik (`get_amount()`, `get_active_quest()`).

## Konsekuensi

### Positif
- Build Mode cukup memanggil `Inventory.can_afford()` / `pay()`.
- HUD cukup mendengar `EventBus.inventory_changed`.
- Quest bisa mendengar `item_collected`, `structure_built`, `npc_crossed` tanpa tahu pengirimnya.

### Negatif / Trade-off
- Autoload baru wajib didokumentasikan di tabel arsitektur.
- State perlu dimasukkan ke format save di M2.

## Implementasi

- [x] `scripts/systems/Inventory.gd` terdaftar sebagai autoload
- [x] `scripts/systems/QuestManager.gd` terdaftar sebagai autoload
- [x] Tabel autoload di `docs/architecture/overview.md` diperbarui
- [ ] Integrasi save/load di M2
