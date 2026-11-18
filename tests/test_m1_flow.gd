class_name TestM1Flow
extends GdUnitTestSuite
## Simulasi alur vertical slice M1 lewat EventBus:
## kumpulkan balok → pasang jembatan → Vera menyeberang → quest selesai.


func test_quest_tutorial_selesai_dan_hadiah_terbuka() -> void:
	if QuestManager.get_active_quest() == null:
		QuestManager.start_quest(&"bc_001")
	for _index in 12:
		EventBus.item_collected.emit(&"brick", 1)
	EventBus.structure_built.emit(&"bridge_4m")
	EventBus.npc_crossed.emit(&"vera")

	assert_int(QuestManager.get_progress(&"obj_collect")).is_equal(12)
	assert_int(QuestManager.get_progress(&"obj_build")).is_equal(1)
	assert_int(QuestManager.get_progress(&"obj_cross")).is_equal(1)
	assert_bool(QuestManager.is_completed(&"bc_001")).is_true()
	assert_bool(Inventory.has_blueprint(&"catapult")).is_true()
