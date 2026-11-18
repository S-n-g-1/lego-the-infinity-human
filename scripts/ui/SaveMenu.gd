extends CanvasLayer
## Menu save/load 3 slot manual + 1 auto. Dibuka dengan F6.
## UI dibuat di kode agar cepat di prototyping; akan dipindah ke .tscn saat UX final.

const SLOT_LABELS: Array[String] = ["Slot 1", "Slot 2", "Slot 3", "Auto"]

var _slot_values: Array[int] = []
var _rows: Array[Label] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_slot_values = [0, 1, 2, SaveManager.AUTO_SLOT]
	_build_ui()
	hide()
	call_deferred("_connect_signals")


func _connect_signals() -> void:
	EventBus.game_saved.connect(_on_state_changed)
	EventBus.game_loaded.connect(_on_state_changed)


func _on_state_changed(_slot: int) -> void:
	_refresh()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"save_menu"):
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	visible = not visible
	Input.set_mouse_mode(
		Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_CAPTURED
	)
	if visible:
		_refresh()
		if GameManager.current_state == GameManager.State.PLAYING:
			GameManager.change_state(GameManager.State.PAUSED)
	elif GameManager.current_state == GameManager.State.PAUSED:
		GameManager.change_state(GameManager.State.PLAYING)


func _build_ui() -> void:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(560, 340)
	add_child(panel)

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "SAVE / LOAD"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	for index in _slot_values.size():
		var row := HBoxContainer.new()
		vbox.add_child(row)
		var info := Label.new()
		info.custom_minimum_size = Vector2(300, 40)
		row.add_child(info)
		_rows.append(info)

		var save_button := Button.new()
		save_button.text = "Simpan"
		save_button.pressed.connect(_on_save_pressed.bind(_slot_values[index]))
		row.add_child(save_button)

		var load_button := Button.new()
		load_button.text = "Muat"
		load_button.pressed.connect(_on_load_pressed.bind(_slot_values[index]))
		row.add_child(load_button)

	var close_button := Button.new()
	close_button.text = "Tutup (F6)"
	close_button.pressed.connect(toggle)
	vbox.add_child(close_button)


func _refresh() -> void:
	var metas := SaveManager.list_slots()
	for index in metas.size():
		if index >= _rows.size():
			break
		var meta: Dictionary = metas[index]
		var label_name: String = SLOT_LABELS[index] if index < SLOT_LABELS.size() else "Slot"
		if not bool(meta.get("exists", false)):
			_rows[index].text = "%s — kosong" % label_name
		elif bool(meta.get("corrupt", false)):
			_rows[index].text = "%s — korup" % label_name
		else:
			_rows[index].text = "%s — Lv%d · %s" % [
				label_name,
				int(meta.get("creator_level", 1)),
				str(meta.get("saved_at", "")),
			]


func _get_save_game() -> Node:
	return get_tree().get_first_node_in_group("save_game")


func _on_save_pressed(slot: int) -> void:
	var service := _get_save_game()
	if service == null:
		return
	service.call("save_to_slot", slot)
	_refresh()


func _on_load_pressed(slot: int) -> void:
	var service := _get_save_game()
	if service == null:
		return
	if bool(service.call("load_from_slot", slot)):
		toggle()
