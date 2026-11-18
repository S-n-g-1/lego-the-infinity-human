extends Node
## Mengambil snapshot seluruh state dan memulihkannya lewat SaveManager.
## Dipanggil oleh menu save/load, checkpoint, quest besar, dan auto-save timer.

const AUTO_INTERVAL: float = 300.0

var _broken_props: Dictionary = {}
var _elapsed: float = 0.0


func _ready() -> void:
	add_to_group("save_game")
	call_deferred("_connect_signals")


func _connect_signals() -> void:
	EventBus.prop_broken.connect(_on_prop_broken)
	EventBus.checkpoint_activated.connect(_on_checkpoint)
	EventBus.quest_completed.connect(_on_quest_completed)


func _on_prop_broken(prop_id: StringName) -> void:
	if prop_id != &"":
		_broken_props[prop_id] = true


func _on_checkpoint(_checkpoint_id: StringName) -> void:
	save_auto()


func _on_quest_completed(_quest_id: StringName) -> void:
	save_auto()


func _process(delta: float) -> void:
	if not GameManager.is_playing():
		return
	_elapsed += delta
	if _elapsed >= AUTO_INTERVAL:
		_elapsed = 0.0
		save_auto()


func capture_state() -> Dictionary:
	var player := get_tree().get_first_node_in_group("player")
	var player_data: Dictionary = {}
	if player != null and player.has_method("to_dict"):
		player_data = player.call("to_dict")
	return {
		"player": player_data,
		"progression": Progression.to_dict(),
		"inventory": Inventory.to_dict(),
		"quests": QuestManager.to_dict(),
		"world": _capture_world(),
	}


func _capture_world() -> Dictionary:
	var structures: Array[Dictionary] = []
	var container := get_tree().get_first_node_in_group("structures")
	if container != null:
		for child in container.get_children():
			var blueprint_id: StringName = child.get_meta("blueprint_id", &"")
			var node := child as Node3D
			if blueprint_id == &"" or node == null:
				continue
			structures.append({
				"blueprint": String(blueprint_id),
				"position": [
					snappedf(node.global_position.x, 0.001),
					snappedf(node.global_position.y, 0.001),
					snappedf(node.global_position.z, 0.001),
				],
				"rotation": snappedf(node.rotation.y, 0.001),
			})
	var broken: Array[String] = []
	for prop_id in _broken_props:
		broken.append(String(prop_id))
	return {
		"broken_props": broken,
		"built_structures": structures,
	}


func save_to_slot(slot: int) -> Error:
	return SaveManager.save_game(slot, capture_state())


func save_auto() -> Error:
	return SaveManager.save_game(SaveManager.AUTO_SLOT, capture_state())


func load_from_slot(slot: int) -> bool:
	var data := SaveManager.load_game(slot)
	if data.is_empty():
		return false
	apply_state(data)
	return true


func apply_state(data: Dictionary) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("from_dict"):
		player.call("from_dict", data.get("player", {}))
	Progression.from_dict(data.get("progression", {}))
	Inventory.from_dict(data.get("inventory", {}))
	QuestManager.from_dict(data.get("quests", {}))
	_apply_world(data.get("world", {}))


func _apply_world(world: Dictionary) -> void:
	_broken_props.clear()
	for prop_id in world.get("broken_props", []):
		_broken_props[StringName(prop_id)] = true
	for node in get_tree().get_nodes_in_group("breakable"):
		var breakable := node as Breakable
		if breakable != null and _broken_props.has(breakable.breakable_id):
			node.queue_free()

	var build_mode := get_tree().get_first_node_in_group("build_mode") as BuildMode
	var container := get_tree().get_first_node_in_group("structures")
	if container == null or build_mode == null:
		return
	for child in container.get_children():
		if child.get_meta("blueprint_id", &"") != &"":
			child.queue_free()
	for entry in world.get("built_structures", []):
		var blueprint_id := StringName(entry.get("blueprint", &""))
		var blueprint := build_mode.get_blueprint(blueprint_id)
		if blueprint == null:
			continue
		var packed := load(blueprint.scene_path) as PackedScene
		if packed == null:
			continue
		var instance := packed.instantiate() as Node3D
		var position_data: Array = entry.get("position", [0, 0, 0])
		if position_data.size() == 3:
			instance.global_position = Vector3(
				float(position_data[0]), float(position_data[1]), float(position_data[2])
			)
		instance.rotation.y = float(entry.get("rotation", 0.0))
		instance.set_meta("blueprint_id", blueprint_id)
		container.add_child(instance)
