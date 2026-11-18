# Panduan — Standar Kode GDScript

> Berlaku untuk seluruh `scripts/`. Ringkasan dari Godot GDScript style guide + aturan proyek.

## 1. Format

- Indentasi: **Tab** (4 visual). Cocok dengan `.editorconfig`.
- Baris maksimal: **100 karakter**.
- UTF-8, akhir baris LF.
- Satu `class_name` per file, nama mengikuti file (`PascalCase`).

```gdscript
class_name BuildMode
extends Node
## Deskripsi singkat. Baris pertama setelah extends = docstring.
## Baris berikutnya boleh lebih detail.


@export var build_range: float = 8.0
var _undo_stack: Array[BuildCommand] = []
```

## 2. Urutan Deklarasi dalam File

1. `class_name` + `extends`
2. Docstring `##`
3. `signal`
4. `@export` var
5. `const` / `enum`
6. `var` public
7. `var` private (`_prefix`)
8. `_init`, `_ready`, `_enter_tree`, `_exit_tree`
9. Fungsi public
10. Fungsi private (`_prefix`)
11. Fungsi callback sinyal (`_on_*`)

## 3. Penamaan

| Jenis | Aturan | Contoh |
| --- | --- | --- |
| Variabel/fungsi | `snake_case` | `build_range`, `has_item()` |
| Private | `_snake_case` | `_undo_stack` |
| Konstanta | `UPPER_SNAKE` | `MAX_STACK` |
| Enum | `PascalCase`, anggota `UPPER_SNAKE` | `State.PLAYING` |
| Sinyal | `past_tense` | `item_collected` |
| Callback | `_on_<node>_<signal>` | `_on_button_pressed` |
| Class | `PascalCase` | `QuestManager` |
| File | `snake_case.gd` | `quest_manager.gd` |

## 4. Tipe & Error

- **Selalu pakai type hint** untuk `@export`, `var` publik, parameter, dan return.
- Hindari `Variant` kecuali memang dinamis (JSON parse).
- Cek null sebelum pakai node opsional.

```gdscript
func get_item_count(item_id: StringName) -> int:
	return _items.get(item_id, 0)


func _on_player_died() -> void:
	if _player == null:
		push_warning("Player null saat event mati.")
		return
	_respawn(_player)
```

## 5. Sinyal

- Deklarasi sinyal lintas sistem **hanya** di `EventBus.gd`.
- Sinyal lokal boleh di sistem sendiri.
- Putuskan koneksi di `_exit_tree()` jika node bisa di-free.
- Istilah: `emit` (bukan `emit_signal` di GDScript 4).

```gdscript
EventBus.item_collected.emit(item_id, amount)
```

## 6. Komentar & Dokumentasi

- Gunakan `##` untuk docstring fungsi publik.
- Gunakan `#` untuk catatan implementasi.
- Awali TODO dengan `TODO(M<angka>):` agar mudah dilacak di milestone.

```gdscript
## Mengembalikan sisa balok setelah biaya dikurangkan.
func pay(cost: Dictionary) -> int:
	# TODO(M2): catat transaksi ke telemetri debug.
	...
```

## 7. Dilarang

- ❌ `get_node("/root/...")` di luar autoload.
- ❌ Hardcode ID item/quest di logika; pakai resource/const.
- ❌ `print()` di rilis → pakai `if is_debug_mode: print(...)`.
- ❌ `await` tanpa timeout di call yang bisa gagal.
- ❌ Mengubah `.tres` hasil generator secara manual.
- ❌ `PASS` kosong di state machine tanpa alasan (tulis komentar).

## 8. Contoh Fungsi Baik

```gdscript
## Memproses hasil pecahan balok dan memberi tahu sistem lain.
func on_brick_broken(item_id: StringName, amount: int) -> void:
	if amount <= 0:
		push_warning("Jumlah balok tidak valid: %d" % amount)
		return
	_items[item_id] = _items.get(item_id, 0) + amount
	EventBus.item_collected.emit(item_id, amount)
	EventBus.inventory_changed.emit()
```

## 9. Checklist Sebelum Commit

- [ ] `Ctrl+S` & tidak ada error di Godot Output
- [ ] Type hint lengkap
- [ ] Tanpa `print()` debug rilis
- [ ] Nama sinyal & fungsi sesuai konvensi
- [ ] GDD bab terkait di-update (jika gameplay berubah)
- [ ] Test lulus (jika menyentuh sistem inti)
- [ ] CHANGELOG `Unreleased` diisi
