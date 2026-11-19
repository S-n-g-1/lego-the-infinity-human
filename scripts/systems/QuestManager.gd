extends Node
## Quest graph: prerequisite, state machine, chain, failure/retry, dan objective.
## Quest dimuat otomatis dari resources/quests/*.tres.

enum QuestState { LOCKED, AVAILABLE, ACTIVE, COMPLETED, FAILED }

const QUEST_DIR := "res://resources/quests"

var _quests: Dictionary = {}
var _states: Dictionary = {}
var _active_id: StringName = &""
var _progress: Dictionary = {}
var _completed: Dictionary = {}
var _failed: Dictionary = {}


func _ready() -> void:
	_load_quests()
	reset_state()
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
	EventBus.enemy_defeated.connect(_on_enemy_defeated)
	EventBus.area_entered.connect(_on_area_entered)
	EventBus.dialogue_finished.connect(_on_dialogue_finished)
	EventBus.player_died.connect(_on_player_died)


func reset_state() -> void:
	_states.clear()
	_active_id = &""
	_progress.clear()
	_completed.clear()
	_failed.clear()
	for quest_id in _quests:
		var quest: QuestDef = _quests[quest_id]
		_states[quest_id] = (
			QuestState.AVAILABLE if _prerequisites_met(quest) else QuestState.LOCKED
		)


func _start_initial_quest() -> void:
	for quest_id in _quests:
		var quest: QuestDef = _quests[quest_id]
		if quest.start_active and get_state(quest.id) == QuestState.AVAILABLE:
			start_quest(quest.id)
			return


func get_state(quest_id: StringName) -> QuestState:
	return int(_states.get(quest_id, QuestState.LOCKED))


func is_available(quest_id: StringName) -> bool:
	return get_state(quest_id) == QuestState.AVAILABLE


func get_available_quests() -> Array[QuestDef]:
	var result: Array[QuestDef] = []
	for quest_id in _quests:
		if is_available(quest_id):
			result.append(_quests[quest_id] as QuestDef)
	return result


func start_quest(quest_id: StringName) -> bool:
	if not _quests.has(quest_id):
		push_warning("[QuestManager] Quest %s tidak ditemukan." % quest_id)
		return false
	if get_state(quest_id) != QuestState.AVAILABLE:
		return false
	if _active_id != &"":
		return false
	_active_id = quest_id
	_states[quest_id] = QuestState.ACTIVE
	EventBus.quest_started.emit(quest_id)
	_emit_objectives(quest_id)
	return true


func _emit_objectives(quest_id: StringName) -> void:
	var quest: QuestDef = _quests[quest_id]
	for objective in quest.objectives:
		var objective_id: StringName = objective.get("id", &"")
		EventBus.quest_objective_updated.emit(
			quest_id, objective_id, int(_progress.get(objective_id, 0))
		)


func fail_active_quest() -> void:
	if _active_id == &"":
		return
	var quest_id := _active_id
	_active_id = &""
	_states[quest_id] = QuestState.FAILED
	_failed[quest_id] = true
	EventBus.quest_failed.emit(quest_id)


func retry_quest(quest_id: StringName) -> bool:
	if not _quests.has(quest_id) or not _failed.has(quest_id):
		return false
	var quest: QuestDef = _quests[quest_id]
	for objective in quest.objectives:
		_progress.erase(StringName(objective.get("id", &"")))
	_failed.erase(quest_id)
	_states[quest_id] = QuestState.AVAILABLE
	return start_quest(quest_id)


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


func _on_enemy_defeated(enemy_id: StringName) -> void:
	_advance(&"defeat", enemy_id, 1)


func _on_area_entered(area_id: StringName) -> void:
	_advance(&"explore", area_id, 1)


func _on_dialogue_finished(dialogue_id: StringName) -> void:
	_advance(&"talk", dialogue_id, 1)


func _on_player_died() -> void:
	var quest := get_active_quest()
	if quest != null and quest.fail_on_player_death:
		fail_active_quest()


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
	_failed.erase(quest_id)
	_states[quest_id] = QuestState.COMPLETED
	_active_id = &""
	_grant_rewards(quest)
	_unlock_following_states()
	EventBus.quest_completed.emit(quest_id)
	if quest.next_quest != &"" and is_available(quest.next_quest):
		start_quest(quest.next_quest)


func _grant_rewards(quest: QuestDef) -> void:
	for item_id in quest.rewards:
		var value: Variant = quest.rewards[item_id]
		match StringName(item_id):
			&"blueprint":
				Inventory.unlock_blueprint(StringName(value))
			&"suit":
				Inventory.unlock_suit(StringName(value))
			&"xp":
				EventBus.xp_gained.emit(int(value), quest.id)
			&"fragment", &"blueprint_fragment":
				EventBus.item_collected.emit(&"blueprint_fragment", int(value))
			_:
				EventBus.item_collected.emit(StringName(item_id), int(value))


func _unlock_following_states() -> void:
	for quest_id in _states:
		if get_state(quest_id) != QuestState.LOCKED:
			continue
		var quest: QuestDef = _quests[quest_id]
		if _prerequisites_met(quest):
			_states[quest_id] = QuestState.AVAILABLE


func _prerequisites_met(quest: QuestDef) -> bool:
	for prerequisite in quest.prerequisites:
		if not _completed.has(StringName(prerequisite)):
			return false
	return true


func to_dict() -> Dictionary:
	var progress_copy: Dictionary = {}
	for objective_id in _progress:
		progress_copy[String(objective_id)] = int(_progress[objective_id])
	var completed: Array[String] = []
	for quest_id in _completed:
		completed.append(String(quest_id))
	var failed: Array[String] = []
	for quest_id in _failed:
		failed.append(String(quest_id))
	var states: Dictionary = {}
	for quest_id in _states:
		states[String(quest_id)] = int(_states[quest_id])
	return {
		"active": String(_active_id),
		"completed": completed,
		"failed": failed,
		"progress": progress_copy,
		"states": states,
	}


func from_dict(data: Dictionary) -> void:
	_active_id = StringName(data.get("active", &""))
	_completed.clear()
	for quest_id in data.get("completed", []):
		_completed[StringName(quest_id)] = true
	_failed.clear()
	for quest_id in data.get("failed", []):
		_failed[StringName(quest_id)] = true
	_progress.clear()
	var saved_progress: Dictionary = data.get("progress", {})
	for objective_id in saved_progress:
		_progress[StringName(objective_id)] = int(saved_progress[objective_id])

	_states.clear()
	var saved_states: Dictionary = data.get("states", {})
	for quest_id in _quests:
		var state_key := String(quest_id)
		if saved_states.has(state_key):
			_states[quest_id] = int(saved_states[state_key])
		elif _completed.has(quest_id):
			_states[quest_id] = QuestState.COMPLETED
		else:
			var quest: QuestDef = _quests[quest_id]
			_states[quest_id] = (
				QuestState.AVAILABLE if _prerequisites_met(quest) else QuestState.LOCKED
			)
	if _active_id != &"" and _quests.has(_active_id):
		_states[_active_id] = QuestState.ACTIVE
		EventBus.quest_started.emit(_active_id)
