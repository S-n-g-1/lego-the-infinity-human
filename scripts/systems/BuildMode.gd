class_name BuildMode
extends Node
## Build Mode M1: pilih blueprint, ghost placement, snap grid, dan pasang struktur.

const GRID_SIZE: float = 0.5
const PLACE_DISTANCE: float = 3.5
const GHOST_VALID: Color = Color(0.2, 0.9, 1.0, 0.55)
const GHOST_INVALID: Color = Color(1.0, 0.3, 0.3, 0.55)

@export var blueprint_paths: Array[String] = [
	"res://resources/items/bp_bridge_4m.tres",
	"res://resources/items/bp_stair_2m.tres",
	"res://resources/items/bp_catapult.tres",
]

var enabled: bool = false

var _player: Node3D
var _structures: Node3D
var _blueprints: Array[BlueprintDef] = []
var _ghost: Node3D
var _ghost_material: StandardMaterial3D
var _selected: int = 0
var _yaw: float = 0.0
var _valid: bool = false


func _ready() -> void:
	_load_blueprints()
	_player = get_tree().get_first_node_in_group("player") as Node3D
	_structures = get_tree().get_first_node_in_group("structures") as Node3D
	call_deferred("_connect_signals")


func _load_blueprints() -> void:
	for path: String in blueprint_paths:
		var blueprint := load(path) as BlueprintDef
		if blueprint == null:
			push_warning("[BuildMode] Gagal memuat %s" % path)
			continue
		_blueprints.append(blueprint)


func _connect_signals() -> void:
	EventBus.quest_completed.connect(_on_quest_completed)


func _on_quest_completed(_quest_id: StringName) -> void:
	_refresh_selection()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"build_mode"):
		toggle()
		get_viewport().set_input_as_handled()
		return
	if not enabled:
		return
	var handled := false
	if event.is_action_pressed(&"attack"):
		place()
		handled = true
	elif event.is_action_pressed(&"rotate_build"):
		_yaw += deg_to_rad(45.0)
		handled = true
	elif event.is_action_pressed(&"blueprint_1"):
		_select_available(0)
		handled = true
	elif event.is_action_pressed(&"blueprint_2"):
		_select_available(1)
		handled = true
	elif event.is_action_pressed(&"blueprint_3"):
		_select_available(2)
		handled = true
	elif event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_select_available(_selected - 1)
				handled = true
			MOUSE_BUTTON_WHEEL_DOWN:
				_select_available(_selected + 1)
				handled = true
	if handled:
		get_viewport().set_input_as_handled()


func toggle() -> void:
	enabled = not enabled
	if enabled:
		_select_available(0)
	else:
		_clear_ghost()
	EventBus.build_mode_toggled.emit(enabled)


func _select_available(index: int) -> void:
	if _blueprints.is_empty():
		return
	for offset in _blueprints.size():
		var candidate := wrapi(index + offset, 0, _blueprints.size())
		if Inventory.has_blueprint(_blueprints[candidate].id):
			_selected = candidate
			break
	_build_ghost()
	_emit_selection()


func _refresh_selection() -> void:
	_select_available(_selected)


func _process(_delta: float) -> void:
	if not enabled or _ghost == null or _player == null:
		return
	var camera := _player.get_node_or_null("CameraRig/Camera") as Camera3D
	var forward := Vector3.FORWARD
	if camera != null:
		forward = -camera.global_transform.basis.z
		forward.y = 0.0
		if forward.length_squared() > 0.001:
			forward = forward.normalized()
		else:
			forward = Vector3.FORWARD
	var target := _player.global_position + forward * PLACE_DISTANCE
	_ghost.global_position = Vector3(
		snappedf(target.x, GRID_SIZE), 0.0, snappedf(target.z, GRID_SIZE)
	)
	_ghost.rotation.y = _yaw
	_valid = _check_valid(_ghost.global_position)
	_apply_ghost_color(GHOST_VALID if _valid else GHOST_INVALID)


func _check_valid(pos: Vector3) -> bool:
	var blueprint := _blueprints[_selected]
	if not Inventory.can_afford(blueprint.cost):
		return false
	if _structures == null:
		return true
	for child in _structures.get_children():
		if child == _ghost:
			continue
		var node := child as Node3D
		if node != null and node.global_position.distance_to(pos) < 2.0:
			return false
	return true


func place() -> void:
	if not enabled or _ghost == null or not _valid:
		return
	var blueprint := _blueprints[_selected]
	if not Inventory.pay(blueprint.cost):
		return
	var packed := load(blueprint.scene_path) as PackedScene
	if packed == null:
		Inventory.refund(blueprint.cost)
		return
	var instance := packed.instantiate() as Node3D
	instance.global_position = _ghost.global_position
	instance.rotation.y = _yaw
	_structures.add_child(instance)
	EventBus.structure_built.emit(blueprint.id)
	EventBus.notification_requested.emit("%s terpasang" % blueprint.display_name)
	_build_ghost()


func _build_ghost() -> void:
	_clear_ghost()
	if _blueprints.is_empty() or _structures == null:
		return
	var blueprint := _blueprints[_selected]
	var packed := load(blueprint.scene_path) as PackedScene
	if packed == null:
		push_warning("[BuildMode] Gagal memuat %s" % blueprint.scene_path)
		return
	_ghost = packed.instantiate() as Node3D
	for shape in _ghost.find_children("*", "CollisionShape3D", true, false):
		(shape as CollisionShape3D).disabled = true
	if _ghost_material == null:
		_ghost_material = StandardMaterial3D.new()
		_ghost_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_apply_ghost_color(GHOST_VALID)
	_structures.add_child(_ghost)


func _apply_ghost_color(color: Color) -> void:
	if _ghost == null or _ghost_material == null:
		return
	_ghost_material.albedo_color = color
	for mesh in _ghost.find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = _ghost_material


func _clear_ghost() -> void:
	if _ghost != null and is_instance_valid(_ghost):
		_ghost.queue_free()
	_ghost = null


func _emit_selection() -> void:
	if _blueprints.is_empty():
		return
	var blueprint := _blueprints[_selected]
	EventBus.blueprint_selected.emit(
		blueprint.id, blueprint.display_name, blueprint.cost
	)
