class_name BrickPickup
extends Area3D
## Balok melayang sebentar lalu magnet ke player dan masuk inventory.

@export var amount: int = 1
@export var magnet_delay: float = 0.45
@export var magnet_speed: float = 9.0
@export var collect_radius: float = 0.85

var _velocity: Vector3 = Vector3.ZERO
var _age: float = 0.0
var _player: Node3D


func _ready() -> void:
	_velocity = Vector3(
		randf_range(-2.0, 2.0),
		randf_range(2.0, 4.0),
		randf_range(-2.0, 2.0)
	)
	_player = get_tree().get_first_node_in_group("player") as Node3D


func _physics_process(delta: float) -> void:
	_age += delta
	if _age < magnet_delay:
		_velocity.y -= 9.8 * delta
		global_position += _velocity * delta
		return
	if _player == null or not is_instance_valid(_player):
		return
	var target := _player.global_position + Vector3(0.0, 1.0, 0.0)
	var to_player := target - global_position
	if to_player.length() <= collect_radius:
		_collect()
		return
	global_position += to_player.normalized() * magnet_speed * delta


func _collect() -> void:
	EventBus.item_collected.emit(&"brick", amount)
	queue_free()
