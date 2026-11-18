class_name CombatMath
extends RefCounted
## Kalkulasi combat murni. Tidak bergantung pada scene/Node agar mudah di-test.

const COMBO_LENGTH: int = 3
const HEAVY_HIT_INDEX: int = 2
const HEAVY_DAMAGE_MULTIPLIER: float = 1.5
const HEAVY_BREAK_POWER: int = 2
const MEGA_DAMAGE_MULTIPLIER: float = 3.0
const MEGA_BREAK_POWER: int = 3
const INSUFFICIENT_BREAK_MULTIPLIER: float = 0.25
const MINIMUM_CHIP_DAMAGE: float = 1.0
const HIT_RANGE: float = 3.0
const MIN_FACING_DOT: float = 0.2


static func melee_damage(base_damage: float, combo_index: int) -> float:
	if combo_index >= HEAVY_HIT_INDEX:
		return base_damage * HEAVY_DAMAGE_MULTIPLIER
	return base_damage


static func break_power(combo_index: int) -> int:
	if combo_index >= HEAVY_HIT_INDEX:
		return HEAVY_BREAK_POWER
	return 1


static func mega_damage(base_damage: float) -> float:
	return base_damage * MEGA_DAMAGE_MULTIPLIER


static func resolve_damage(
	amount: float,
	attacker_break_power: int,
	required_break_power: int
) -> float:
	if attacker_break_power >= required_break_power:
		return amount
	return maxf(MINIMUM_CHIP_DAMAGE, amount * INSUFFICIENT_BREAK_MULTIPLIER)


static func can_hit(
	attacker: Vector3,
	target: Vector3,
	facing: Vector3,
	max_range: float = HIT_RANGE
) -> bool:
	var offset := target - attacker
	offset.y = 0.0
	if offset.length() > max_range:
		return false
	if offset.length_squared() < 0.0001:
		return true
	var flat_facing := Vector3(facing.x, 0.0, facing.z)
	if flat_facing.length_squared() < 0.0001:
		return false
	return flat_facing.normalized().dot(offset.normalized()) >= MIN_FACING_DOT
