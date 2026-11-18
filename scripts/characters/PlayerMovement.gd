class_name PlayerMovement
extends Node
## Kalkulasi movement murni untuk player.
## Sengaja statis agar bisa di-unit-test tanpa instantiate CharacterBody3D.

const WALK_SPEED: float = 6.0
const SPRINT_MULTIPLIER: float = 1.2
const GRAVITY: float = 9.8
const JUMP_HEIGHT: float = 2.2
const MOUSE_SENSITIVITY: float = 0.0025
const CAMERA_DISTANCE: float = 5.0


## Kecepatan awal lompat agar mencapai [param height] meter.
static func get_jump_velocity(gravity: float = GRAVITY, height: float = JUMP_HEIGHT) -> float:
	return sqrt(2.0 * gravity * height)


## Kecepatan horizontal sesuai status sprint.
static func get_speed(sprinting: bool, base_speed: float = WALK_SPEED) -> float:
	return base_speed * (SPRINT_MULTIPLIER if sprinting else 1.0)


## Arah gerak relatif terhadap yaw kamera, sudah dinormalisasi jika diagonal.
static func get_move_direction(input: Vector2, yaw: float) -> Vector3:
	var forward := Vector3(-sin(yaw), 0.0, -cos(yaw))
	var right := Vector3(cos(yaw), 0.0, -sin(yaw))
	var direction := forward * input.y + right * input.x
	if direction.length_squared() > 1.0:
		direction = direction.normalized()
	return direction
