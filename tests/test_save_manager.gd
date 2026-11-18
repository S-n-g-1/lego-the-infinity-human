class_name TestSaveManager
extends GdUnitTestSuite
## Test untuk path slot dan deteksi save di SaveManager.


func test_path_slot_memakai_nomor_dua_digit() -> void:
	assert_str(SaveManager._path(7)).ends_with("slot_07.json")
	assert_str(SaveManager._path(42)).ends_with("slot_42.json")


func test_slot_kosong_tidak_terdeteksi() -> void:
	assert_bool(SaveManager.has_save(999)).is_false()


func test_save_load_round_trip() -> void:
	# JSON.parse_string() mengembalikan angka sebagai float, jadi pakai float di sini.
	var data := {"player": {"hp": 80.0, "suit": "suit_starter"}}
	assert_int(SaveManager.save_game(9, data)).is_equal(OK)

	var loaded: Dictionary = SaveManager.load_game(9)
	assert_bool(loaded.has("player")).is_true()
	assert_float(loaded["player"]["hp"]).is_equal(80.0)
	assert_str(loaded["player"]["suit"]).is_equal("suit_starter")
