class_name TestPlayerMovement
extends GdUnitTestSuite
## Test untuk kalkulasi movement murni di PlayerMovement.


func test_jump_velocity_untuk_ketinggian_2_2() -> void:
	var velocity := PlayerMovement.get_jump_velocity(9.8, 2.2)
	assert_float(velocity).is_equal_approx(6.5702, 0.01)


func test_kecepatan_dasar_dan_sprint() -> void:
	assert_float(PlayerMovement.get_speed(false)).is_equal_approx(6.0, 0.001)
	assert_float(PlayerMovement.get_speed(true)).is_equal_approx(7.2, 0.001)


func test_arah_maju_mengikuti_yaw() -> void:
	var direction := PlayerMovement.get_move_direction(Vector2(0.0, 1.0), 0.0)
	assert_float(direction.x).is_equal_approx(0.0, 0.001)
	assert_float(direction.z).is_equal_approx(-1.0, 0.001)


func test_input_diagonal_tidak_melebihi_satu() -> void:
	var direction := PlayerMovement.get_move_direction(Vector2(1.0, 1.0), 0.5)
	assert_float(direction.length()).is_equal_approx(1.0, 0.001)
