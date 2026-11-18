class_name TestProgression
extends GdUnitTestSuite
## Test Creator Level & XP sesuai tabel GDD 05.


func test_level_dari_ambang_xp() -> void:
	assert_int(Progression.get_level_for_xp(0)).is_equal(1)
	assert_int(Progression.get_level_for_xp(100)).is_equal(2)
	assert_int(Progression.get_level_for_xp(249)).is_equal(2)
	assert_int(Progression.get_level_for_xp(250)).is_equal(3)
	assert_int(Progression.get_level_for_xp(6000)).is_equal(20)


func test_xp_menambah_dan_level_tidak_mundur() -> void:
	var before_xp := Progression.xp
	var before_level := Progression.creator_level
	EventBus.xp_gained.emit(150, &"test")
	var expected_level := maxi(
		before_level, Progression.get_level_for_xp(before_xp + 150)
	)
	assert_int(Progression.xp).is_equal(before_xp + 150)
	assert_int(Progression.creator_level).is_equal(expected_level)


func test_from_dict_tidak_menurunkan_state() -> void:
	var before_xp := Progression.xp
	Progression.from_dict({"xp": before_xp, "creator_level": 1})
	assert_int(Progression.xp).is_equal(before_xp)
