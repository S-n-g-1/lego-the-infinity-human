class_name TestQuestGraph
extends GdUnitTestSuite
## Quest graph: prerequisite ganda, state machine, chain, failure/retry, dan load save.

var _snapshot: Dictionary = {}
var _original_quests: Dictionary = {}


func before_test() -> void:
	_snapshot = QuestManager.to_dict()
	_original_quests = QuestManager._quests.duplicate()
	QuestManager._quests = _original_quests.duplicate()


func after_test() -> void:
	QuestManager._quests = _original_quests
	QuestManager.from_dict(_snapshot)


func _add_quest(
	id: StringName,
	prerequisites: Array[StringName] = [],
	next_id: StringName = &"",
	fail_on_death: bool = false,
	objectives: Array[Dictionary] = []
) -> QuestDef:
	var quest := QuestDef.new()
	quest.id = id
	quest.title = "Test %s" % id
	quest.prerequisites = prerequisites
	quest.next_quest = next_id
	quest.fail_on_player_death = fail_on_death
	quest.objectives = objectives
	QuestManager._quests[id] = quest
	return quest


func _objective(id: StringName, type: StringName, target: StringName, required: int) -> Dictionary:
	return {"id": id, "type": type, "target": target, "required": required, "label": id}


func test_prerequisite_ganda_memblokir_aktivasi() -> void:
	var quest_a := _add_quest(&"__test_qa")
	var quest_b := _add_quest(&"__test_qb")
	_add_quest(&"__test_qc", [&"__test_qa", &"__test_qb"])
	QuestManager.reset_state()

	assert_bool(QuestManager.start_quest(&"__test_qc")).is_false()
	assert_int(QuestManager.get_state(&"__test_qc")).is_equal(QuestManager.QuestState.LOCKED)

	QuestManager._complete(quest_a)
	assert_bool(QuestManager.is_available(&"__test_qc")).is_false()

	QuestManager._complete(quest_b)
	assert_bool(QuestManager.is_available(&"__test_qc")).is_true()
	assert_bool(QuestManager.start_quest(&"__test_qc")).is_true()
	assert_bool(QuestManager.start_quest(&"__test_qa")).is_false()


func test_progres_tidak_dobel_setelah_from_dict() -> void:
	_add_quest(
		&"__test_qd", [], &"", false,
		[_objective(&"__obj_qd", &"collect", &"core", 10)]
	)
	QuestManager.reset_state()
	assert_bool(QuestManager.start_quest(&"__test_qd")).is_true()

	EventBus.item_collected.emit(&"core", 4)
	var snapshot: Dictionary = QuestManager.to_dict()
	EventBus.item_collected.emit(&"core", 3)
	assert_int(QuestManager.get_progress(&"__obj_qd")).is_equal(7)

	QuestManager.from_dict(snapshot)
	assert_int(QuestManager.get_progress(&"__obj_qd")).is_equal(4)


func test_gagal_saat_player_mati_lalu_retry() -> void:
	_add_quest(
		&"__test_qe", [], &"", true,
		[_objective(&"__obj_qe", &"defeat", &"grunt", 2)]
	)
	QuestManager.reset_state()
	assert_bool(QuestManager.start_quest(&"__test_qe")).is_true()

	EventBus.enemy_defeated.emit(&"grunt")
	assert_int(QuestManager.get_progress(&"__obj_qe")).is_equal(1)

	EventBus.player_died.emit()
	assert_int(QuestManager.get_state(&"__test_qe")).is_equal(QuestManager.QuestState.FAILED)
	assert_bool(QuestManager.get_active_quest() == null).is_true()

	assert_bool(QuestManager.retry_quest(&"__test_qe")).is_true()
	assert_int(QuestManager.get_progress(&"__obj_qe")).is_equal(0)
	assert_int(QuestManager.get_state(&"__test_qe")).is_equal(QuestManager.QuestState.ACTIVE)


func test_next_quest_auto_start_setelah_complete() -> void:
	var quest_f := _add_quest(&"__test_qf", [], &"__test_qg")
	_add_quest(&"__test_qg", [&"__test_qf"])
	QuestManager.reset_state()

	assert_bool(QuestManager.start_quest(&"__test_qf")).is_true()
	QuestManager._complete(quest_f)

	assert_bool(QuestManager.is_completed(&"__test_qf")).is_true()
	assert_int(QuestManager.get_state(&"__test_qg")).is_equal(QuestManager.QuestState.ACTIVE)
	var active := QuestManager.get_active_quest()
	assert_bool(active != null).is_true()
	if active != null:
		assert_str(String(active.id)).is_equal("__test_qg")


func test_data_chain_quest_asli_terhubung() -> void:
	var first := load("res://resources/quests/bc_001.tres") as QuestDef
	var second := load("res://resources/quests/sq_001.tres") as QuestDef
	assert_str(String(first.next_quest)).is_equal("sq_001")
	assert_str(String(second.prerequisites[0])).is_equal("bc_001")
	assert_str(String(second.next_quest)).is_equal("bc_002")
