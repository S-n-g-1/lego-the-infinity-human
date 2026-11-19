extends Node
## Blueprint Tree bercabang 3: traversal, combat, utility.
## XP hanya membuka slot (Creator Level); Blueprint Fragment membuka node itu sendiri.

const NODE_DIR: String = "res://resources/blueprints"

var _nodes: Dictionary = {}
var _unlocked: Dictionary = {}


func _ready() -> void:
	_load_nodes()
	reset_state()


func _load_nodes() -> void:
	var dir := DirAccess.open(NODE_DIR)
	if dir == null:
		push_warning("[BlueprintTree] Folder %s tidak ditemukan." % NODE_DIR)
		return
	for file_name: String in dir.get_files():
		if not file_name.ends_with(".tres"):
			continue
		var node := load(NODE_DIR + "/" + file_name) as BlueprintNodeDef
		if node == null:
			continue
		_nodes[node.id] = node


func reset_state() -> void:
	_unlocked.clear()
	for node_id in _nodes:
		var node: BlueprintNodeDef = _nodes[node_id]
		if node.required_level <= 1 and node.fragment_cost == 0 and node.prerequisite_node == &"":
			_unlocked[node_id] = true
			_apply(node)


func get_node_def(node_id: StringName) -> BlueprintNodeDef:
	return _nodes.get(node_id) as BlueprintNodeDef


func get_all_nodes() -> Array[BlueprintNodeDef]:
	var result: Array[BlueprintNodeDef] = []
	for node_id in _nodes:
		result.append(_nodes[node_id] as BlueprintNodeDef)
	return result


func is_unlocked(node_id: StringName) -> bool:
	return _unlocked.has(node_id)


func can_unlock(node_id: StringName) -> bool:
	return get_lock_reason(node_id) == ""


func get_lock_reason(node_id: StringName) -> String:
	var node := get_node_def(node_id)
	if node == null:
		return "Node tidak ditemukan"
	if is_unlocked(node_id):
		return "Sudah terbuka"
	if Progression.creator_level < node.required_level:
		return "Butuh Creator Lv %d" % node.required_level
	if node.prerequisite_node != &"" and not is_unlocked(node.prerequisite_node):
		return "Butuh node sebelumnya"
	if Inventory.get_amount(&"blueprint_fragment") < node.fragment_cost:
		return "Butuh %d Fragment" % node.fragment_cost
	return ""


func unlock(node_id: StringName) -> bool:
	if not can_unlock(node_id):
		return false
	var node := get_node_def(node_id)
	EventBus.item_removed.emit(&"blueprint_fragment", node.fragment_cost)
	_unlocked[node_id] = true
	_apply(node)
	EventBus.blueprint_node_unlocked.emit(node_id)
	EventBus.notification_requested.emit("Node %s terbuka!" % node.display_name)
	return true


func _apply(node: BlueprintNodeDef) -> void:
	if node.unlock_blueprint != &"":
		Inventory.unlock_blueprint(node.unlock_blueprint)
	if node.unlock_suit != &"":
		Inventory.unlock_suit(node.unlock_suit)


func to_dict() -> Dictionary:
	var unlocked: Array[String] = []
	for node_id in _unlocked:
		unlocked.append(String(node_id))
	return {"unlocked": unlocked}


func from_dict(data: Dictionary) -> void:
	_unlocked.clear()
	for node_id in data.get("unlocked", []):
		var id := StringName(node_id)
		if not _nodes.has(id):
			continue
		_unlocked[id] = true
		_apply(_nodes[id] as BlueprintNodeDef)
