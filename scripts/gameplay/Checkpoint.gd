class_name Checkpoint
extends Area3D
## Checkpoint sederhana: saat player masuk, memicu auto-save via SaveGame.

@export var checkpoint_id: StringName = &"nexus_start"


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	EventBus.checkpoint_activated.emit(checkpoint_id)
	EventBus.notification_requested.emit("Checkpoint tersimpan")
