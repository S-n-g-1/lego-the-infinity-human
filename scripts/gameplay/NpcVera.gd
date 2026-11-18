class_name NpcVera
extends Node3D
## NPC tutorial. Menyeberang setelah jembatan dipasang lalu memberi sinyal quest.

@export var walk_distance: float = 4.0
@export var walk_duration: float = 2.5

var _moving: bool = false


func _ready() -> void:
	EventBus.structure_built.connect(_on_structure_built)


func _on_structure_built(blueprint_id: StringName) -> void:
	if blueprint_id != &"bridge_4m" or _moving:
		return
	_moving = true
	var start := global_position
	var tween := create_tween()
	tween.tween_property(
		self, "global_position", start + Vector3(0.0, 0.0, -walk_distance), walk_duration
	)
	tween.finished.connect(_on_arrived)


func _on_arrived() -> void:
	EventBus.npc_crossed.emit(&"vera")
	EventBus.notification_requested.emit("Vera berhasil menyeberang!")
