class_name TestGameManager
extends GdUnitTestSuite
## Test untuk state machine dasar di GameManager.


func test_state_enum_tersedia() -> void:
	assert_int(GameManager.State.BOOT).is_equal(0)
	assert_int(GameManager.State.PLAYING).is_equal(2)


func test_change_state_mengubah_state_aktif() -> void:
	GameManager.change_state(GameManager.State.MENU)
	assert_int(GameManager.current_state).is_equal(GameManager.State.MENU)

	GameManager.change_state(GameManager.State.PLAYING)
	assert_int(GameManager.current_state).is_equal(GameManager.State.PLAYING)

	# Kembalikan ke state awal agar test lain tidak terpengaruh.
	GameManager.change_state(GameManager.State.BOOT)


func test_change_state_ke_state_sama_tidak_efek() -> void:
	GameManager.change_state(GameManager.State.MENU)
	GameManager.change_state(GameManager.State.MENU)
	assert_int(GameManager.current_state).is_equal(GameManager.State.MENU)
	GameManager.change_state(GameManager.State.BOOT)
