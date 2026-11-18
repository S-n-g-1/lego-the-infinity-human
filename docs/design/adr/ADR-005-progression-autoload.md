# ADR-005 — Progression sebagai Autoload

| Field | Isi |
| --- | --- |
| Nomor | ADR-005 |
| Tanggal | 2026-11-18 |
| Status | Accepted |
| Pembuat | Tim |
| Terkait | ADR-004, `../../gdd/05-progression.md`, `../../architecture/overview.md` |

## Konteks

Creator Level dan XP dipakai oleh quest, combat, HUD, save/load, dan unlock blueprint. Menaruhnya di `GameManager` akan membuat state machine itu menjadi *god object*, melanggar batas tanggung jawab yang sudah ditetapkan di arsitektur.

## Keputusan

> Tambahkan `Progression` sebagai autoload ketujuh. `Progression` menyimpan `xp` dan `creator_level`, menghitung level dari tabel XP GDD, dan mendengar `EventBus.xp_gained`.

`Progression` tidak tahu siapa pemberi XP; sistem lain cukup emit `EventBus.xp_gained(amount, source)`.

## Alternatif yang Dipertimbangkan

| Opsi | Kelebihan | Kekurangan |
| --- | --- | --- |
| Autoload (dipilih) | Satu sumber kebenaran, mudah diakses semua sistem | Bertambah satu autoload |
| Field di `GameManager` | Tanpa file baru | Melanggar pemisahan tanggung jawab |
| Simpan di `SaveManager` | Ikut tersimpan otomatis | SaveManager jadi storage state hidup, bukan serializer |

## Konsekuensi

### Positif
- Quest reward tinggal emit XP; tidak perlu memanggil Progression langsung.
- Serialisasi cukup `Progression.to_dict()` / `from_dict()`.
- HUD bisa mendengar `creator_level_changed` tanpa query.

### Negatif / Trade-off
- Tabel XP masih hardcode di konstanta; akan dipindah ke `data/progression.csv` + generator saat Blueprint Tree diimplementasikan (M2 lanjutan).

## Implementasi

- [x] `scripts/systems/Progression.gd` terdaftar sebagai autoload
- [x] Tabel level mengikuti GDD 05
- [x] `to_dict()` / `from_dict()` untuk save system
- [ ] Blueprint Tree berbasis Fragment (M2 lanjutan)
