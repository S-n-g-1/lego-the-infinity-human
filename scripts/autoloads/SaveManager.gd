extends Node
## Sistem save/load JSON di user://saves: 3 slot manual + 1 auto.
## Atomic write, backup .bak, migrasi versi, dan metadata slot untuk UI.

const SAVE_VERSION: int = 1
const AUTO_SLOT: int = -1

@export var save_dir: String = "user://saves"


func _ready() -> void:
	call_deferred("_ensure_save_dir")


func _ensure_save_dir() -> void:
	if DirAccess.dir_exists_absolute(save_dir):
		return
	var err: int = DirAccess.make_dir_recursive_absolute(save_dir)
	if err != OK:
		push_error("[SaveManager] Gagal membuat direktori save: %d" % err)


func save_game(slot: int, data: Dictionary) -> Error:
	_ensure_save_dir()
	var path := _path(slot)
	var temp_path := path + ".tmp"
	var payload := {
		"version": SAVE_VERSION,
		"saved_at": Time.get_datetime_string_from_system(),
		"data": data,
	}
	var file: FileAccess = FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(payload, "  "))
	file.flush()
	file.close()

	_backup(path)
	var err: int = DirAccess.rename_absolute(temp_path, path)
	if err != OK:
		push_error("[SaveManager] Gagal menulis slot %d: %d" % [slot, err])
		DirAccess.remove_absolute(temp_path)
		return err
	EventBus.game_saved.emit(slot)
	return OK


func load_game(slot: int) -> Dictionary:
	var path := _path(slot)
	if not FileAccess.file_exists(path):
		push_warning("[SaveManager] Slot %d belum ada." % slot)
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("[SaveManager] Gagal membaca slot %d." % slot)
		return {}
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("[SaveManager] Slot %d korup." % slot)
		return {}
	var payload: Dictionary = parsed
	var version := int(payload.get("version", 0))
	if version > SAVE_VERSION:
		push_warning("[SaveManager] Slot %d dari versi lebih baru; perbarui game dulu." % slot)
		return {}
	if version < SAVE_VERSION:
		_backup(path)
		payload = _migrate(payload)
	EventBus.game_loaded.emit(slot)
	var data: Variant = payload.get("data", {})
	return data if typeof(data) == TYPE_DICTIONARY else {}


func has_save(slot: int) -> bool:
	return FileAccess.file_exists(_path(slot))


func get_slot_meta(slot: int) -> Dictionary:
	var meta := {
		"exists": false,
		"corrupt": false,
		"slot": slot,
		"saved_at": "",
		"creator_level": 1,
		"xp": 0,
	}
	var path := _path(slot)
	if not FileAccess.file_exists(path):
		return meta
	meta["exists"] = true
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		meta["corrupt"] = true
		return meta
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		meta["corrupt"] = true
		return meta
	var payload: Dictionary = parsed
	var data: Dictionary = payload.get("data", {})
	var progression: Dictionary = data.get("progression", {})
	meta["saved_at"] = str(payload.get("saved_at", ""))
	meta["creator_level"] = int(progression.get("creator_level", 1))
	meta["xp"] = int(progression.get("xp", 0))
	return meta


func list_slots() -> Array[Dictionary]:
	var slots: Array[Dictionary] = []
	for slot in [0, 1, 2, AUTO_SLOT]:
		slots.append(get_slot_meta(slot))
	return slots


func delete_slot(slot: int) -> bool:
	var path := _path(slot)
	if not FileAccess.file_exists(path):
		return false
	var ok := true
	for suffix in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(path + suffix):
			if DirAccess.remove_absolute(path + suffix) != OK:
				ok = false
	return ok


func _migrate(payload: Dictionary) -> Dictionary:
	var version := int(payload.get("version", 0))
	while version < SAVE_VERSION:
		match version:
			0:
				var data: Dictionary = payload.get("data", {})
				var inventory: Dictionary = data.get("inventory", {})
				if not inventory.has("stud") and inventory.has("money"):
					inventory["stud"] = inventory["money"]
					inventory.erase("money")
				version = 1
			_:
				push_error("[SaveManager] Versi save tidak dikenal: %d" % version)
				break
		payload["version"] = version
	return payload


func _backup(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	var source: FileAccess = FileAccess.open(path, FileAccess.READ)
	if source == null:
		return
	var content := source.get_as_text()
	source.close()
	var target: FileAccess = FileAccess.open(path + ".bak", FileAccess.WRITE)
	if target != null:
		target.store_string(content)
		target.close()


func _path(slot: int) -> String:
	if slot == AUTO_SLOT:
		return "%s/auto.json" % save_dir
	return "%s/slot_%02d.json" % [save_dir, slot]
