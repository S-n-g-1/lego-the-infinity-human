extends CanvasLayer
## HUD minimal M1: status player, material, objective quest, dan hint build mode.

@onready var _health_label: Label = $HealthLabel
@onready var _brick_label: Label = $BrickLabel
@onready var _level_label: Label = $LevelLabel
@onready var _objective_label: Label = $ObjectiveLabel
@onready var _build_label: Label = $BuildLabel
@onready var _hint_label: Label = $HintLabel


func _ready() -> void:
	call_deferred("_connect_signals")
	call_deferred("_refresh_objective")


func _connect_signals() -> void:
	EventBus.player_health_changed.connect(_on_health_changed)
	EventBus.inventory_changed.connect(_refresh_inventory)
	EventBus.currency_changed.connect(_on_currency_changed)
	EventBus.quest_started.connect(_refresh_objective)
	EventBus.quest_objective_updated.connect(_on_objective_updated)
	EventBus.quest_completed.connect(_on_quest_completed)
	EventBus.build_mode_toggled.connect(_on_build_mode_toggled)
	EventBus.blueprint_selected.connect(_on_blueprint_selected)
	EventBus.notification_requested.connect(_on_notification)
	EventBus.creator_level_changed.connect(_on_creator_level_changed)
	_refresh_inventory()
	_refresh_level()


func _on_health_changed(current: float, maximum: float) -> void:
	_health_label.text = "HP  %d / %d" % [int(current), int(maximum)]


func _refresh_inventory() -> void:
	_brick_label.text = "Balok  %d     Stud  %d" % [
		Inventory.get_bricks(), Inventory.get_studs()
	]


func _on_currency_changed(_amount: int) -> void:
	_refresh_inventory()


func _on_creator_level_changed(_level: int, _xp: int) -> void:
	_refresh_level()


func _refresh_level() -> void:
	_level_label.text = "Creator Lv %d  ·  %d XP" % [
		Progression.creator_level, Progression.xp
	]


func _refresh_objective(_quest_id: StringName = &"") -> void:
	var quest := QuestManager.get_active_quest()
	if quest == null:
		_objective_label.text = "Quest selesai — misi berikutnya segera hadir"
		return
	var lines: Array[String] = [quest.title]
	for objective in quest.objectives:
		var objective_id: StringName = objective.get("id", &"")
		var required: int = int(objective.get("required", 1))
		var progress: int = QuestManager.get_progress(objective_id)
		var mark := "x" if progress >= required else " "
		lines.append("[%s] %s  %d/%d" % [
			mark, str(objective.get("label", "")), progress, required
		])
	_objective_label.text = "\n".join(lines)


func _on_objective_updated(
	_quest_id: StringName, _objective_id: StringName, _progress: int
) -> void:
	_refresh_objective()


func _on_quest_completed(_quest_id: StringName) -> void:
	_refresh_objective()
	_show_notification("Quest selesai! +30 stud, Katapel terbuka")


func _on_build_mode_toggled(enabled: bool) -> void:
	if enabled:
		_build_label.text = "BUILD — 1/2/3 pilih · R putar · Klik pasang · B keluar"
	else:
		_build_label.text = ""
		_hint_label.text = ""


func _on_blueprint_selected(
	_id: StringName, display_name: String, cost: Dictionary
) -> void:
	var cost_text := ""
	for item_id in cost:
		cost_text += "%d %s   " % [int(cost[item_id]), str(item_id)]
	_build_label.text = "BUILD · %s — %s" % [display_name, cost_text]


func _on_notification(text: String) -> void:
	_show_notification(text)


func _show_notification(text: String) -> void:
	_hint_label.text = text
	await get_tree().create_timer(3.0).timeout
	if _hint_label.text == text:
		_hint_label.text = ""
