extends Node
## Mengelola quest aktif, progres objective, dan reward.
## Quest dimuat otomatis dari resources/quests/*.tres.

const QUEST_DIR := "res://resources/quests"

var _quests: Dictionary = {}
var _active_id: StringName = &""
var _progress: Dictionary = {}
var _completed: Dictionary = {}


func _ready() -> void:
	_load_quests()
	call_deferred("_connect_signals")
	call_deferred("_start_initial_quest")


func _load_quests() -> void:
	var dir := DirAccess.open(QUEST_DIR)
	if dir == null:
		push_warning("[QuestManager] Folder quest tidak ditemukan.")
		return
	for file_name: String in dir.get_files():
		if not file_name.ends_with(".tres"):
			continue
		var quest := load(QUEST_DIR + "/" + file_name) as QuestDef
		if quest == null:
			push_warning("[QuestManager] Gagal memuat %s" % file_name)
			continue
		_quests[quest.id] = quest


func _connect_signals() -> void:
	EventBus.item_collected.connect(_on_item_collected)
	EventBus.structure_built.connect(_on_structure_built)
	EventBus.npc_crossed.connect(_on_npc_crossed)


func _start_initial_quest() -> void:
	for quest_id in _quests:
		var quest: QuestDef = _quests[quest_id]
		if quest.start_active:
			start_quest(quest.id)
			return


func start_quest(quest_id: StringName) -> void:
	if not _quests.has(quest_id):
		push_warning("[QuestManager] Quest %s tidak ditemukan." % quest_id)
		return
	_active_id = quest_id
	EventBus.quest_started.emit(quest_id)
	var quest: QuestDef = _quests[quest_id]
	for objective in quest.objectives:
		var objective_id: StringName = objective.get("id", &"")
		EventBus.quest_objective_updated.emit(
			quest_id, objective_id, int(_progress.get(objective_id, 0))
		)


func get_active_quest() -> QuestDef:
	if _active_id == &"":
		return null
	return _quests.get(_active_id) as QuestDef


func get_progress(objective_id: StringName) -> int:
	return int(_progress.get(objective_id, 0))


func is_completed(quest_id: StringName) -> bool:
	return _completed.has(quest_id)


func _on_item_collected(item_id: StringName, amount: int) -> void:
	_advance(&"collect", item_id, amount)


func _on_structure_built(blueprint_id: StringName) -> void:
	_advance(&"build", blueprint_id, 1)


func _on_npc_crossed(npc_id: StringName) -> void:
	_advance(&"interact", npc_id, 1)


func _advance(objective_type: StringName, target: StringName, amount: int) -> void:
	var quest := get_active_quest()
	if quest == null:
		return
	for objective in quest.objectives:
		if StringName(objective.get("type", &"")) != objective_type:
			continue
		if StringName(objective.get("target", &"")) != target:
			continue
		var objective_id: StringName = objective.get("id", &"")
		var required: int = int(objective.get("required", 1))
		var previous: int = get_progress(objective_id)
		var next_value: int = mini(required, previous + amount)
		if next_value == previous:
			continue
		_progress[objective_id] = next_value
		EventBus.quest_objective_updated.emit(quest.id, objective_id, next_value)
	_check_completion(quest)


func _check_completion(quest: QuestDef) -> void:
	for objective in quest.objectives:
		var objective_id: StringName = objective.get("id", &"")
		if get_progress(objective_id) < int(objective.get("required", 1)):
			return
	_complete(quest)


func _complete(quest: QuestDef) -> void:
	var quest_id: StringName = quest.id
	if _completed.has(quest_id):
		return
	_completed[quest_id] = true
	_active_id = &""
	for item_id in quest.rewards:
		var value: Variant = quest.rewards[item_id]
		if StringName(item_id) == &"blueprint":
			Inventory.unlock_blueprint(StringName(value))
		else:
			EventBus.item_collected.emit(StringName(item_id), int(value))
	EventBus.quest_completed.emit(quest_id)
