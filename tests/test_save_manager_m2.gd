class_name TestSaveManagerM2
extends GdUnitTestSuite
## Test M2 untuk atomic write, migrasi, metadata, dan pemisahan slot auto.

const TEST_DIR: String = "user://saves_gdunit_test"

var _original_dir: String = ""


func before_test() -> void:
	_original_dir = SaveManager.save_dir
	SaveManager.save_dir = TEST_DIR
	_clear_dir()


func after_test() -> void:
	_clear_dir()
	SaveManager.save_dir = _original_dir


func test_round_trip_dan_metadata() -> void:
	var data := {
		"player": {"hp": 80.0},
		"progression": {"creator_level": 4, "xp": 310},
	}
	assert_int(SaveManager.save_game(0, data)).is_equal(OK)
	var loaded: Dictionary = SaveManager.load_game(0)
	assert_float(loaded["player"]["hp"]).is_equal(80.0)

	var meta: Dictionary = SaveManager.get_slot_meta(0)
	assert_bool(bool(meta.get("exists", false))).is_true()
	assert_int(int(meta.get("creator_level", 1))).is_equal(4)
	assert_int(int(meta.get("xp", 0))).is_equal(310)


func test_slot_kosong_dan_korup() -> void:
	assert_bool(SaveManager.has_save(2)).is_false()
	assert_int(SaveManager.load_game(2).size()).is_equal(0)

	_write_raw(2, "ini bukan JSON")
	var meta: Dictionary = SaveManager.get_slot_meta(2)
	assert_bool(bool(meta.get("exists", false))).is_true()
	assert_bool(bool(meta.get("corrupt", false))).is_true()
	assert_int(SaveManager.load_game(2).size()).is_equal(0)


func test_migrasi_v0_ke_v1() -> void:
	_write_raw(1, JSON.stringify({
		"version": 0,
		"saved_at": "2026-01-01T00:00:00",
		"data": {"inventory": {"money": 250}},
	}))
	var loaded: Dictionary = SaveManager.load_game(1)
	var inventory: Dictionary = loaded.get("inventory", {})
	assert_int(int(inventory.get("stud", 0))).is_equal(250)
	assert_bool(FileAccess.file_exists(SaveManager._path(1) + ".bak")).is_true()


func test_atomic_write_tanpa_file_tmp() -> void:
	assert_int(SaveManager.save_game(1, {"a": 1})).is_equal(OK)
	assert_int(SaveManager.save_game(1, {"a": 2})).is_equal(OK)
	var path := SaveManager._path(1)
	assert_bool(FileAccess.file_exists(path + ".tmp")).is_false()
	assert_bool(FileAccess.file_exists(path + ".bak")).is_true()


func test_auto_slot_terpisah_dari_slot_manual() -> void:
	assert_int(SaveManager.save_game(0, {"source": "manual"})).is_equal(OK)
	assert_int(SaveManager.save_game(SaveManager.AUTO_SLOT, {"source": "auto"})).is_equal(OK)
	assert_bool(FileAccess.file_exists(SaveManager._path(0))).is_true()
	assert_bool(FileAccess.file_exists(SaveManager._path(SaveManager.AUTO_SLOT))).is_true()
	assert_str(str(SaveManager.load_game(0).get("source", ""))).is_equal("manual")
	assert_str(str(SaveManager.load_game(SaveManager.AUTO_SLOT).get("source", ""))).is_equal("auto")


func _write_raw(slot: int, text: String) -> void:
	SaveManager._ensure_save_dir()
	var file: FileAccess = FileAccess.open(SaveManager._path(slot), FileAccess.WRITE)
	if file == null:
		return
	file.store_string(text)
	file.close()


func _clear_dir() -> void:
	if not DirAccess.dir_exists_absolute(TEST_DIR):
		return
	var dir := DirAccess.open(TEST_DIR)
	if dir != null:
		for file_name: String in dir.get_files():
			dir.remove(file_name)
		DirAccess.remove_absolute(TEST_DIR)
