class_name BrickProjectile
extends Area3D
## Projectile Brick Blaster: 8 damage, 1.2 dtk cooldown di Player.
## Hilang setelah menyentuh satu target atau habis masa hidupnya.

@export var speed: float = 18.0
@export var damage: float = 8.0
@export var break_power: int = 1
@export var lifetime: float = 2.0

var _direction: Vector3 = Vector3.FORWARD
var _source: Node = null
var _age: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func setup(direction: Vector3, source: Node) -> void:
	_direction = direction.normalized()
	_source = source


func _physics_process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		queue_free()
		return
	global_position += _direction * speed * delta
	look_at(global_position + _direction)


func _on_body_entered(body: Node3D) -> void:
	if body == _source:
		return
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.call("take_damage", damage, break_power)
	elif body.is_in_group("breakable") and body.has_method("hit"):
		body.call("hit", 1)
	else:
		return
	queue_free()
