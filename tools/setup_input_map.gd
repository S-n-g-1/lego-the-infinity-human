@tool
extends SceneTree
## Generator sekali pakai untuk mengisi [input] di project.godot.
## Jalankan: godot --headless --path . -s tools/setup_input_map.gd
## Spec aksi: {"key": KEY_X} atau {"mouse": MOUSE_BUTTON_LEFT}.

const ACTIONS: Dictionary = {
	"move_forward": [{"key": KEY_W}],
	"move_back": [{"key": KEY_S}],
	"move_left": [{"key": KEY_A}],
	"move_right": [{"key": KEY_D}],
	"jump": [{"key": KEY_SPACE}],
	"sprint": [{"key": KEY_SHIFT}],
	"attack": [{"mouse": MOUSE_BUTTON_LEFT}],
	"gadget": [{"mouse": MOUSE_BUTTON_RIGHT}],
	"build_mode": [{"key": KEY_B}],
	"rotate_build": [{"key": KEY_R}],
	"blueprint_1": [{"key": KEY_1}],
	"blueprint_2": [{"key": KEY_2}],
	"blueprint_3": [{"key": KEY_3}],
	"builder_vision": [{"key": KEY_Q}],
	"interact": [{"key": KEY_E}],
	"pause": [{"key": KEY_ESCAPE}],
	"save_menu": [{"key": KEY_F6}],
	"blueprint_tree": [{"key": KEY_T}],
}


func _initialize() -> void:
	for action_name: String in ACTIONS:
		var events: Array[InputEvent] = []
		for spec: Dictionary in ACTIONS[action_name]:
			if spec.has("mouse"):
				var mouse_event := InputEventMouseButton.new()
				mouse_event.button_index = spec["mouse"]
				events.append(mouse_event)
			else:
				var key_event := InputEventKey.new()
				key_event.keycode = spec["key"]
				key_event.physical_keycode = spec["key"]
				events.append(key_event)
		ProjectSettings.set_setting("input/" + action_name, {
			"deadzone": 0.5,
			"events": events,
		})
	ProjectSettings.save()
	print("[InputMap] %d aksi terdaftar." % ACTIONS.size())
	quit()
