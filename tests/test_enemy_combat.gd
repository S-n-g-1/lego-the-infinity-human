class_name TestEnemyCombat
extends GdUnitTestSuite
## Perilaku EnemyBase: damage, break power, pop, dan dampak ke inventory.

const GRUNT_SCENE: String = "res://scenes/enemies/BrickGrunt.tscn"


func test_grunt_menerima_damage() -> void:
	var enemy := _spawn_grunt()
	assert_float(enemy.health).is_equal_approx(30.0, 0.001)
	enemy.take_damage(12.0, 1)
	assert_float(enemy.health).is_equal_approx(18.0, 0.001)
	assert_int(enemy.state).is_not_equal(EnemyBase.State.POP)


func test_break_power_satu_tidak_pecah_elite() -> void:
	var elite := EnemyDef.new()
	elite.id = &"elite_test"
	elite.max_health = 30.0
	elite.required_break_power = 2
	elite.drop_table = null
	var enemy := _spawn_grunt()
	enemy.enemy_def = elite
	enemy.health = elite.max_health
	enemy.take_damage(12.0, 1)
	assert_float(enemy.health).is_equal_approx(27.0, 0.001)
	assert_int(enemy.state).is_not_equal(EnemyBase.State.POP)


func test_pop_tidak_mengurangi_balok_inventory() -> void:
	Inventory.add(&"brick", 25)
	var before := Inventory.get_amount(&"brick")
	var enemy := _spawn_grunt()
	enemy.take_damage(999.0, CombatMath.MEGA_BREAK_POWER)
	assert_int(enemy.state).is_equal(EnemyBase.State.POP)
	assert_int(Inventory.get_amount(&"brick")).is_equal(before)


func test_player_mati_tidak_menghilangkan_balance() -> void:
	Inventory.add(&"brick", 17)
	var before := Inventory.get_amount(&"brick")
	var player := load("res://scenes/characters/Player.tscn").instantiate() as Player
	add_child(player)
	player.current_health = 1.0
	player.take_damage(10.0)
	assert_float(player.current_health).is_equal_approx(player.max_health, 0.001)
	assert_int(Inventory.get_amount(&"brick")).is_equal(before)


func _spawn_grunt() -> EnemyBase:
	var packed := load(GRUNT_SCENE) as PackedScene
	var enemy := packed.instantiate() as EnemyBase
	add_child(enemy)
	return enemy
