class_name Breakable
extends StaticBody3D
## Prop yang bisa dipecah dengan serangan. Menghasilkan pickup balok + stud.

@export var bricks_drop: int = 3
@export var studs_drop: int = 3
@export var hits_required: int = 1
@export var breakable_id: StringName = &""

var _hits: int = 0


func _ready() -> void:
	add_to_group("breakable")
	_hits = maxi(1, hits_required)


func hit(damage: int = 1) -> void:
	if _hits <= 0:
		return
	_hits -= damage
	if _hits > 0:
		_punch()
		return
	_spawn_drops()
	if studs_drop > 0:
		EventBus.item_collected.emit(&"stud", studs_drop)
	EventBus.notification_requested.emit("+%d balok" % bricks_drop)
	queue_free()


func _punch() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3(1.15, 1.15, 1.15), 0.05)
	tween.tween_property(self, "scale", Vector3.ONE, 0.1)


func _spawn_drops() -> void:
	var pickup_scene := load("res://scenes/gameplay/BrickPickup.tscn") as PackedScene
	if pickup_scene == null:
		push_warning("[Breakable] BrickPickup.tscn tidak ditemukan.")
		return
	for _index in bricks_drop:
		var pickup := pickup_scene.instantiate()
		get_parent().add_child(pickup)
		pickup.global_position = global_position + Vector3(
			randf_range(-0.45, 0.45),
			randf_range(0.6, 1.0),
			randf_range(-0.45, 0.45)
		)
