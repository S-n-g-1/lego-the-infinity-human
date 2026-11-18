extends Node
## Pengelola state global dan transisi alur game.
## State machine ini menjadi sumber kebenaran untuk mode game saat ini.

enum State { BOOT, MENU, PLAYING, PAUSED, DIALOGUE, CUTSCENE, GAME_OVER }

@export var starting_state: State = State.BOOT

var current_state: State = State.BOOT
var is_debug_mode: bool = OS.is_debug_build()


func _ready() -> void:
	#Deferred memastikan semua autoload sudah masuk tree sebelum menyambung sinyal.
	call_deferred("_connect_signals")
	change_state(starting_state)


func _connect_signals() -> void:
	EventBus.game_started.connect(func() -> void: change_state(State.PLAYING))
	EventBus.dialogue_started.connect(func(_id: StringName) -> void: change_state(State.DIALOGUE))
	EventBus.dialogue_finished.connect(func(_id: StringName) -> void: change_state(State.PLAYING))


func change_state(new_state: State) -> void:
	if new_state == current_state:
		return
	var previous: State = current_state
	current_state = new_state
	_apply_state(new_state)
	print("[GameManager] %s -> %s" % [State.keys()[previous], State.keys()[new_state]])


func _apply_state(state: State) -> void:
	match state:
		State.PAUSED:
			get_tree().paused = true
		State.PLAYING, State.BOOT, State.MENU:
			get_tree().paused = false
		_:
			# DIALOGUE / CUTSCENE / GAME_OVER: pause bisa diatur per-kasus.
			pass


func is_playing() -> bool:
	return current_state == State.PLAYING


func toggle_pause() -> void:
	match current_state:
		State.PLAYING:
			change_state(State.PAUSED)
			EventBus.game_paused.emit(true)
		State.PAUSED:
			change_state(State.PLAYING)
			EventBus.game_paused.emit(false)
		_:
			pass
