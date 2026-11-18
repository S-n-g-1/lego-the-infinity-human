class_name TestCombat
extends GdUnitTestSuite
## Test kalkulasi combat murni (GDD 04).


func test_kombo_tiga_hit_lebih_kuat() -> void:
	assert_float(CombatMath.melee_damage(12.0, 0)).is_equal_approx(12.0, 0.001)
	assert_float(CombatMath.melee_damage(12.0, 1)).is_equal_approx(12.0, 0.001)
	assert_float(CombatMath.melee_damage(12.0, 2)).is_equal_approx(18.0, 0.001)


func test_hit_ketiga_punya_break_power_dua() -> void:
	assert_int(CombatMath.break_power(0)).is_equal(1)
	assert_int(CombatMath.break_power(1)).is_equal(1)
	assert_int(CombatMath.break_power(2)).is_equal(2)


func test_mega_swing_tiga_kali_damage() -> void:
	assert_float(CombatMath.mega_damage(12.0)).is_equal_approx(36.0, 0.001)
	assert_int(CombatMath.MEGA_BREAK_POWER).is_equal(3)


func test_break_power_kurang_mengurangi_damage() -> void:
	assert_float(CombatMath.resolve_damage(12.0, 1, 2)).is_equal_approx(3.0, 0.001)
	assert_float(CombatMath.resolve_damage(12.0, 2, 2)).is_equal_approx(12.0, 0.001)
	assert_float(CombatMath.resolve_damage(2.0, 1, 4)).is_equal_approx(1.0, 0.001)


func test_can_hit_memperhatikan_arah_dan_jarak() -> void:
	var attacker := Vector3.ZERO
	var facing := Vector3.BACK
	assert_bool(CombatMath.can_hit(attacker, Vector3(0, 0, 2), facing)).is_true()
	assert_bool(CombatMath.can_hit(attacker, Vector3(0, 0, -2), facing)).is_false()
	assert_bool(CombatMath.can_hit(attacker, Vector3(0, 0, 10), facing)).is_false()
