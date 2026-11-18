extends Node
## Sistem save/load berbasis JSON di folder user://.
## TODO(M2): tambahkan migrasi versi, enkripsi ringan, dan slot metadata UI.

const SAVE_DIR := "user://saves"
const SAVE_VERSION := 1


func _ready() -> void:
	call_deferred("_ensure_save_dir")


func _ensure_save_dir() -> void:
	if DirAccess.dir_exists_absolute(SAVE_DIR):
		return
	var err: int = DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	if err != OK:
		push_error("[SaveManager] Gagal membuat direktori save: %d" % err)


func save_game(slot: int, data: Dictionary) -> Error:
	_ensure_save_dir()
	var payload := {
		"version": SAVE_VERSION,
		"saved_at": Time.get_datetime_string_from_system(),
		"data": data,
	}
	var file: FileAccess = FileAccess.open(_path(slot), FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(payload, "  "))
	file.close()
	EventBus.game_saved.emit(slot)
	return OK


func load_game(slot: int) -> Dictionary:
	var path := _path(slot)
	if not FileAccess.file_exists(path):
		push_warning("[SaveManager] Slot %d belum ada." % slot)
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("[SaveManager] Slot %d korup." % slot)
		return {}
	var payload: Dictionary = parsed
	if int(payload.get("version", 0)) != SAVE_VERSION:
		push_warning("[SaveManager] Versi save berbeda; migrasi belum diimplementasikan.")
		return {}
	EventBus.game_loaded.emit(slot)
	return payload.get("data", {})


func has_save(slot: int) -> bool:
	return FileAccess.file_exists(_path(slot))


func _path(slot: int) -> String:
	return "%s/slot_%02d.json" % [SAVE_DIR, slot]
