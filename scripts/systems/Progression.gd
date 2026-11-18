extends Node
## Creator Level & XP. Mendengar EventBus.xp_gained agar tetap decoupled.
## Tabel mengikuti GDD 05 — akan dipindah ke data/progression.csv saat Blueprint Tree masuk.

const XP_TABLE: Dictionary = {
	1: 0,
	2: 100,
	3: 250,
	5: 600,
	8: 1400,
	10: 2200,
	15: 4000,
	20: 6000,
}

var xp: int = 0
var creator_level: int = 1


func _ready() -> void:
	call_deferred("_connect_signals")


func _connect_signals() -> void:
	EventBus.xp_gained.connect(add_xp)


func add_xp(amount: int, _source: StringName = &"") -> void:
	if amount <= 0:
		return
	xp += amount
	var previous_level := creator_level
	creator_level = maxi(previous_level, get_level_for_xp(xp))
	EventBus.creator_level_changed.emit(creator_level, xp)
	if creator_level > previous_level:
		EventBus.notification_requested.emit("Creator Level %d!" % creator_level)


func get_level_for_xp(total_xp: int) -> int:
	var result := 1
	for level in XP_TABLE:
		if total_xp >= int(XP_TABLE[level]):
			result = int(level)
	return result


func to_dict() -> Dictionary:
	return {
		"creator_level": creator_level,
		"xp": xp,
	}


func from_dict(data: Dictionary) -> void:
	xp = maxi(0, int(data.get("xp", 0)))
	creator_level = maxi(1, int(data.get("creator_level", 1)))
	EventBus.creator_level_changed.emit(creator_level, xp)
