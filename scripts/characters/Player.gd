class_name Player
extends CharacterBody3D
## Player minifigure dengan kamera orbit third-person.
## M1: movement, jump, sprint, health. M2: combo melee, Mega Swing, dan gadget.

const ATTACK_COOLDOWN: float = 0.32
const COMBO_WINDOW: float = 1.1
const MEGA_CHARGE_SECONDS: float = 0.6
const MEGA_COOLDOWN: float = 4.0
const GADGET_COOLDOWN: float = 1.2

@export var walk_speed: float = PlayerMovement.WALK_SPEED
@export var jump_height: float = PlayerMovement.JUMP_HEIGHT
@export var gravity: float = PlayerMovement.GRAVITY
@export var melee_damage: float = 12.0

var max_health: float = 100.0
var current_health: float = 100.0
var is_sprinting: bool = false

var _yaw: float = 0.0
var _pitch: float = 0.35
var _camera_distance: float = PlayerMovement.CAMERA_DISTANCE
var _jump_velocity: float = 0.0
var _combo_index: int = 0
var _combo_timer: float = 0.0
var _attack_cooldown: float = 0.0
var _mega_cooldown: float = 0.0
var _gadget_cooldown: float = 0.0
var _attack_pressed_at: int = 0

@onready var _visual: Node3D = $Visual
@onready var _camera: Camera3D = $CameraRig/Camera
@onready var _spawn_point: Vector3 = global_position


func _ready() -> void:
	_jump_velocity = PlayerMovement.get_jump_velocity(gravity, jump_height)
	_camera.current = true
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if OS.is_debug_build():
		print("[Player] Spawn: %s" % global_position)
	EventBus.player_spawned.emit(self)
	EventBus.player_health_changed.emit(current_health, max_health)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_yaw -= event.relative.x * PlayerMovement.MOUSE_SENSITIVITY
		_pitch = clampf(
			_pitch + event.relative.y * PlayerMovement.MOUSE_SENSITIVITY,
			-0.3,
			1.1
		)
	if event.is_action_pressed(&"pause"):
		GameManager.toggle_pause()
		Input.set_mouse_mode(
			Input.MOUSE_MODE_CAPTURED if GameManager.is_playing()
			else Input.MOUSE_MODE_VISIBLE
		)
	if not GameManager.is_playing() or _is_build_mode_active():
		return
	if event.is_action_pressed(&"attack"):
		_attack_pressed_at = Time.get_ticks_msec()
		_attack()
	elif event.is_action_released(&"attack"):
		var held := float(Time.get_ticks_msec() - _attack_pressed_at) / 1000.0
		if held >= MEGA_CHARGE_SECONDS and is_zero_approx(_mega_cooldown):
			_mega_swing()
	elif event.is_action_pressed(&"gadget"):
		_fire_gadget()


func _is_build_mode_active() -> bool:
	var build_mode := get_tree().get_first_node_in_group("build_mode")
	return build_mode != null and bool(build_mode.get("enabled"))


func _attack() -> void:
	if _attack_cooldown > 0.0:
		return
	_attack_cooldown = ATTACK_COOLDOWN
	if _combo_timer <= 0.0:
		_combo_index = 0
	else:
		_combo_index = (_combo_index + 1) % CombatMath.COMBO_LENGTH
	_combo_timer = COMBO_WINDOW
	_strike(
		CombatMath.melee_damage(melee_damage, _combo_index),
		CombatMath.break_power(_combo_index)
	)


func _mega_swing() -> void:
	_mega_cooldown = MEGA_COOLDOWN
	_combo_timer = 0.0
	_strike(
		CombatMath.mega_damage(melee_damage),
		CombatMath.MEGA_BREAK_POWER
	)
	EventBus.notification_requested.emit("MEGA SWING!")


func _strike(damage: float, break_power: int) -> void:
	var facing := Vector3(sin(_visual.rotation.y), 0.0, cos(_visual.rotation.y))
	for node: Node in get_tree().get_nodes_in_group("breakable"):
		if not is_instance_valid(node):
			continue
		var target := node as Node3D
		if target == null or not target.has_method("hit"):
			continue
		if CombatMath.can_hit(global_position, target.global_position, facing):
			target.call("hit", 1)
	for node: Node in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(node):
			continue
		var target := node as Node3D
		if target == null or not target.has_method("take_damage"):
			continue
		if CombatMath.can_hit(global_position, target.global_position, facing):
			target.call("take_damage", damage, break_power)


func _fire_gadget() -> void:
	if _gadget_cooldown > 0.0:
		return
	_gadget_cooldown = GADGET_COOLDOWN
	var packed := load("res://scenes/gameplay/BrickProjectile.tscn") as PackedScene
	var parent := get_tree().current_scene
	if packed == null or parent == null:
		return
	var projectile := packed.instantiate() as Node3D
	parent.add_child(projectile)
	var direction := -_camera.global_transform.basis.z.normalized()
	projectile.global_position = global_position + Vector3(0.0, 1.2, 0.0) + direction * 0.9
	if projectile.has_method("setup"):
		projectile.call("setup", direction, self)


func _physics_process(delta: float) -> void:
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	_combo_timer = maxf(0.0, _combo_timer - delta)
	_mega_cooldown = maxf(0.0, _mega_cooldown - delta)
	_gadget_cooldown = maxf(0.0, _gadget_cooldown - delta)
	var input := Vector2(
		Input.get_axis(&"move_left", &"move_right"),
		Input.get_axis(&"move_back", &"move_forward")
	)
	is_sprinting = Input.is_action_pressed(&"sprint")
	var speed := PlayerMovement.get_speed(is_sprinting, walk_speed)
	var direction := PlayerMovement.get_move_direction(input, _yaw)

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed(&"jump") and is_on_floor():
		velocity.y = _jump_velocity

	move_and_slide()
	_update_visual(direction, delta)
	_update_camera()


func take_damage(amount: float) -> void:
	if amount <= 0.0:
		return
	current_health = maxf(0.0, current_health - amount)
	EventBus.player_health_changed.emit(current_health, max_health)
	if is_zero_approx(current_health):
		_respawn()


func heal(amount: float) -> void:
	current_health = minf(max_health, current_health + amount)
	EventBus.player_health_changed.emit(current_health, max_health)


func _respawn() -> void:
	global_position = _spawn_point
	velocity = Vector3.ZERO
	current_health = max_health
	EventBus.player_health_changed.emit(current_health, max_health)
	EventBus.player_died.emit()


func _update_visual(direction: Vector3, delta: float) -> void:
	if direction.length_squared() < 0.001:
		return
	var target_yaw := atan2(direction.x, direction.z)
	_visual.rotation.y = lerp_angle(_visual.rotation.y, target_yaw, 12.0 * delta)


func _update_camera() -> void:
	var target := global_position + Vector3(0.0, 1.2, 0.0)
	var dir := Vector3(
		sin(_yaw) * cos(_pitch),
		sin(_pitch),
		cos(_yaw) * cos(_pitch)
	)
	_camera.global_position = target + dir * _camera_distance
	_camera.look_at(target)


func to_dict() -> Dictionary:
	return {
		"position": [
			snappedf(global_position.x, 0.001),
			snappedf(global_position.y, 0.001),
			snappedf(global_position.z, 0.001),
		],
		"rotation_y": snappedf(rotation.y, 0.001),
		"hp": current_health,
	}


func from_dict(data: Dictionary) -> void:
	var position_data: Array = data.get("position", [])
	if position_data.size() == 3:
		global_position = Vector3(
			float(position_data[0]), float(position_data[1]), float(position_data[2])
		)
	rotation.y = float(data.get("rotation_y", 0.0))
	current_health = clampf(float(data.get("hp", max_health)), 0.0, max_health)
	_spawn_point = global_position
	velocity = Vector3.ZERO
	EventBus.player_health_changed.emit(current_health, max_health)
