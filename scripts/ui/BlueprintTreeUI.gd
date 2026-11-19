extends CanvasLayer
## UI Blueprint Tree (pintasan T). Kolom per cabang, tombol unlock per node.
## UI dibuat di kode agar prototyping cepat, mengikuti pola SaveMenu.

const BRANCHES: Array[StringName] = [&"traversal", &"combat", &"utility"]

var _header: Label
var _buttons: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	hide()
	call_deferred("_connect_signals")


func _connect_signals() -> void:
	EventBus.blueprint_node_unlocked.connect(_on_node_unlocked)
	EventBus.creator_level_changed.connect(_on_level_changed)
	EventBus.inventory_changed.connect(_on_inventory_changed)


func _on_node_unlocked(_node_id: StringName) -> void:
	_refresh_if_visible()


func _on_level_changed(_level: int, _xp: int) -> void:
	_refresh_if_visible()


func _on_inventory_changed() -> void:
	_refresh_if_visible()


func _refresh_if_visible() -> void:
	if visible:
		_refresh()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"blueprint_tree"):
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
	panel.custom_minimum_size = Vector2(820, 560)
	add_child(panel)

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	_header = Label.new()
	_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_header)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(780, 450)
	vbox.add_child(scroll)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)

	var nodes := BlueprintTree.get_all_nodes()
	for branch in BRANCHES:
		var section := Label.new()
		section.text = str(branch).to_upper()
		list.add_child(section)
		for node: BlueprintNodeDef in nodes:
			if node.branch != branch:
				continue
			var button := Button.new()
			button.pressed.connect(_on_node_pressed.bind(node.id))
			_buttons[node.id] = button
			list.add_child(button)

	var close_button := Button.new()
	close_button.text = "Tutup (T)"
	close_button.pressed.connect(toggle)
	vbox.add_child(close_button)


func _refresh() -> void:
	_header.text = "BLUEPRINT TREE — Fragment %d · Creator Lv %d" % [
		Inventory.get_amount(&"blueprint_fragment"), Progression.creator_level
	]
	for node_id: StringName in _buttons:
		var node := BlueprintTree.get_node_def(node_id)
		var button: Button = _buttons[node_id]
		if BlueprintTree.is_unlocked(node_id):
			button.text = "✓ %s — terbuka" % node.display_name
			button.disabled = true
			continue
		var reason := BlueprintTree.get_lock_reason(node_id)
		button.text = "%s — %d Fragment · %s" % [
			node.display_name,
			node.fragment_cost,
			reason if reason != "" else "siap dibuka",
		]
		button.disabled = reason != ""


func _on_node_pressed(node_id: StringName) -> void:
	BlueprintTree.unlock(node_id)
	_refresh()
