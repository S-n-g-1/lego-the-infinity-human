@tool
extends SceneTree
## Generator sekali pakai untuk mengisi [input] di project.godot.
## Jalankan: godot --headless --path . -s tools/setup_input_map.gd

const ACTIONS: Dictionary = {
	"move_forward": [KEY_W],
	"move_back": [KEY_S],
	"move_left": [KEY_A],
	"move_right": [KEY_D],
	"jump": [KEY_SPACE],
	"sprint": [KEY_SHIFT],
	"build_mode": [KEY_B],
	"builder_vision": [KEY_Q],
	"interact": [KEY_E],
	"pause": [KEY_ESCAPE],
}


func _initialize() -> void:
	for action_name: String in ACTIONS:
		var events: Array[InputEvent] = []
		for keycode: int in ACTIONS[action_name]:
			var event := InputEventKey.new()
			event.keycode = keycode
			event.physical_keycode = keycode
			events.append(event)
		ProjectSettings.set_setting("input/" + action_name, {
			"deadzone": 0.5,
			"events": events,
		})
	ProjectSettings.save()
	print("[InputMap] %d aksi terdaftar." % ACTIONS.size())
	quit()
