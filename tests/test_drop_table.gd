class_name TestDropTable
extends GdUnitTestSuite
## Drop table harus jadi data (.tres) dan hasil roll tetap dalam batas.


func test_resource_grunt_valid() -> void:
	var definition := load("res://resources/characters/enemy_brick_grunt.tres") as EnemyDef
	assert_object(definition).is_not_null()
	assert_str(str(definition.id)).is_equal("brick_grunt")
	assert_float(definition.max_health).is_equal_approx(30.0, 0.001)
	assert_object(definition.drop_table).is_not_null()


func test_roll_terbatas_oleh_rentang() -> void:
	var table := DropTableDef.new()
	table.bricks_min = 6
	table.bricks_max = 10
	table.studs_min = 5
	table.studs_max = 8
	table.xp = 4
	var rng := RandomNumberGenerator.new()
	rng.seed = 1234
	for _index in 50:
		var loot: Dictionary = table.roll(rng)
		assert_int(int(loot["bricks"])).is_greater_equal(6)
		assert_int(int(loot["bricks"])).is_less_equal(10)
		assert_int(int(loot["studs"])).is_greater_equal(5)
		assert_int(int(loot["studs"])).is_less_equal(8)
		assert_int(int(loot["xp"])).is_equal(4)


func test_rentang_terbalik_dinormalkan() -> void:
	var table := DropTableDef.new()
	table.bricks_min = 10
	table.bricks_max = 6
	var loot: Dictionary = table.roll()
	assert_int(int(loot["bricks"])).is_greater_equal(6)
	assert_int(int(loot["bricks"])).is_less_equal(10)
