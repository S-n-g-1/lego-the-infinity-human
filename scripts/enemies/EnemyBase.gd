class_name EnemyBase
extends CharacterBody3D
## Musuh balok dengan AI: Patrol → Detect → Chase → Attack → Retreat → Pop.
## State musuh sengaja tidak disimpan (GDD 11: musuh respawn saat load).

enum State { PATROL, DETECT, CHASE, ATTACK, RETREAT, POP }

@export var enemy_def: EnemyDef

var health: float = 30.0
var state: State = State.PATROL

var _player: Node3D
var _visual: Node3D
var _patrol_origin: Vector3
var _patrol_direction: float = 1.0
var _detect_timer: float = 0.0
var _attack_timer: float = 0.0


func _ready() -> void:
	add_to_group("enemy")
	_visual = get_node_or_null("Visual") as Node3D
	if enemy_def == null:
		push_warning("[EnemyBase] enemy_def belum di-set; musuh tidak aktif.")
		set_physics_process(false)
		return
	health = enemy_def.max_health
	_patrol_origin = global_position
	_player = get_tree().get_first_node_in_group("player") as Node3D


func _physics_process(delta: float) -> void:
	if enemy_def == null or state == State.POP:
		return
	_detect_timer = maxf(0.0, _detect_timer - delta)
	_attack_timer = maxf(0.0, _attack_timer - delta)
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node3D
	if _player == null:
		velocity = Vector3(_patrol_step(delta).x * enemy_def.move_speed, 0.0, 0.0)
		move_and_slide()
		return

	var distance := _flat_distance_to(_player.global_position)
	var desired := _update_state(delta, distance)
	velocity.x = desired.x * enemy_def.move_speed
	velocity.z = desired.z * enemy_def.move_speed
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0
	move_and_slide()


func _update_state(delta: float, distance: float) -> Vector3:
	var to_player := _player.global_position - global_position
	to_player.y = 0.0
	var desired := Vector3.ZERO
	match state:
		State.PATROL:
			if distance <= enemy_def.detect_radius:
				state = State.DETECT
				_detect_timer = 0.3
			else:
				desired = _patrol_step(delta)
		State.DETECT:
			_face(to_player, delta)
			if _detect_timer <= 0.0:
				state = State.CHASE
		State.CHASE:
			_face(to_player, delta)
			if health < enemy_def.max_health * 0.25:
				state = State.RETREAT
			elif distance <= enemy_def.attack_range:
				state = State.ATTACK
				_attack_timer = 0.0
			else:
				desired = to_player.normalized()
		State.ATTACK:
			_face(to_player, delta)
			if health < enemy_def.max_health * 0.25:
				state = State.RETREAT
			elif distance > enemy_def.attack_range * 1.4:
				state = State.CHASE
			elif _attack_timer <= 0.0:
				_attack_timer = enemy_def.attack_interval
				if _player.has_method("take_damage"):
					_player.call("take_damage", enemy_def.attack_damage)
		State.RETREAT:
			if health >= enemy_def.max_health * 0.25:
				state = State.CHASE
			else:
				desired = -to_player.normalized()
		State.POP:
			pass
	return desired


func _flat_distance_to(target: Vector3) -> float:
	var offset := target - global_position
	offset.y = 0.0
	return offset.length()


func _patrol_step(delta: float) -> Vector3:
	var offset := global_position.x - _patrol_origin.x
	if offset > 1.5:
		_patrol_direction = -1.0
	elif offset < -1.5:
		_patrol_direction = 1.0
	if _visual != null:
		var target_yaw := atan2(_patrol_direction, 0.0)
		_visual.rotation.y = lerp_angle(_visual.rotation.y, target_yaw, 8.0 * delta)
	return Vector3.RIGHT * _patrol_direction


func _face(target: Vector3, delta: float) -> void:
	if target.length_squared() < 0.001 or _visual == null:
		return
	var target_yaw := atan2(target.x, target.z)
	_visual.rotation.y = lerp_angle(_visual.rotation.y, target_yaw, 10.0 * delta)


func take_damage(amount: float, attacker_break_power: int = 1) -> void:
	if state == State.POP or amount <= 0.0 or enemy_def == null:
		return
	var effective := CombatMath.resolve_damage(
		amount, attacker_break_power, enemy_def.required_break_power
	)
	health = maxf(0.0, health - effective)
	_flash()
	EventBus.enemy_damaged.emit(enemy_def.id, health)
	if is_zero_approx(health):
		_pop()


func _flash() -> void:
	if _visual == null:
		return
	var tween := create_tween()
	tween.tween_property(_visual, "position:y", 0.12, 0.05)
	tween.tween_property(_visual, "position:y", 0.0, 0.08)


func _pop() -> void:
	state = State.POP
	velocity = Vector3.ZERO
	_drop_loot()
	EventBus.enemy_defeated.emit(enemy_def.id)
	EventBus.notification_requested.emit("%s pecah!" % enemy_def.display_name)
	var tween := create_tween()
	if _visual != null:
		tween.tween_property(_visual, "position:y", -0.8, 0.18)
	tween.finished.connect(_finish_pop)


func _finish_pop() -> void:
	queue_free()


func _drop_loot() -> void:
	if enemy_def.drop_table == null:
		return
	var loot: Dictionary = enemy_def.drop_table.roll()
	var pickup_scene := load("res://scenes/gameplay/BrickPickup.tscn") as PackedScene
	if pickup_scene != null:
		for _index in int(loot.get("bricks", 0)):
			var pickup := pickup_scene.instantiate() as Node3D
			get_parent().add_child(pickup)
			pickup.global_position = global_position + Vector3(
				randf_range(-0.5, 0.5), randf_range(0.5, 1.0), randf_range(-0.5, 0.5)
			)
	var studs := int(loot.get("studs", 0))
	if studs > 0:
		EventBus.item_collected.emit(&"stud", studs)
	var xp_reward := int(loot.get("xp", 0))
	if xp_reward > 0:
		EventBus.xp_gained.emit(xp_reward, &"enemy")
