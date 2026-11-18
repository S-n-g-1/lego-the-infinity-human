class_name DropTableDef
extends Resource
## Drop acak untuk musuh saat pecah. Disimpan sebagai .tres, bukan hardcode.

@export var bricks_min: int = 6
@export var bricks_max: int = 10
@export var studs_min: int = 5
@export var studs_max: int = 8
@export var xp: int = 0


func roll(rng: RandomNumberGenerator = null) -> Dictionary:
	var generator: RandomNumberGenerator = rng
	if generator == null:
		generator = RandomNumberGenerator.new()
		generator.randomize()
	return {
		"bricks": generator.randi_range(_min(bricks_min, bricks_max), _max(bricks_min, bricks_max)),
		"studs": generator.randi_range(_min(studs_min, studs_max), _max(studs_min, studs_max)),
		"xp": maxi(0, xp),
	}


func _min(first: int, second: int) -> int:
	return maxi(0, mini(first, second))


func _max(first: int, second: int) -> int:
	return maxi(_min(first, second), maxi(first, second))
