extends Node
## Entry point sementara (M0). Akan diganti bootstrap lengkap di M1.
## Tugasnya hanya memastikan autoload aktif dan alur dasar bisa dites.


func _ready() -> void:
	print("[Main] Boot selesai. State awal: %s" % GameManager.State.keys()[GameManager.current_state])
	call_deferred("_start_game")


func _start_game() -> void:
	EventBus.game_started.emit()
	var state_name: String = GameManager.State.keys()[GameManager.current_state]
	print("[Main] Game started. State sekarang: %s" % state_name)
