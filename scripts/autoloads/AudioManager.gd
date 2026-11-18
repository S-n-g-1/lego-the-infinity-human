extends Node
## Pengelola musik, SFX, dan bus audio.
## TODO(M3): audio bus Music/SFX dibuat di Audio Layout, lalu mapping SFX
## dipindahkan ke resources/settings/sfx_db.tres.

@export var master_bus: StringName = &"Master"
@export var music_bus: StringName = &"Music"
@export var sfx_bus: StringName = &"SFX"


func _ready() -> void:
	call_deferred("_connect_signals")


func _connect_signals() -> void:
	EventBus.notification_requested.connect(_on_notification)


func _on_notification(_text: String) -> void:
	play_sfx(&"ui_notification")


func play_sfx(sfx_name: StringName, volume_db: float = 0.0) -> void:
	print("[AudioManager] SFX: %s (%.1f dB)" % [sfx_name, volume_db])


func play_music(track: StringName, fade_seconds: float = 1.0) -> void:
	print("[AudioManager] Music: %s (fade %.1fs)" % [track, fade_seconds])


func set_bus_volume(bus: StringName, linear: float) -> void:
	var index: int = AudioServer.get_bus_index(bus)
	if index == -1:
		push_warning("[AudioManager] Bus '%s' tidak ditemukan." % bus)
		return
	AudioServer.set_bus_volume_db(index, linear_to_db(linear))
