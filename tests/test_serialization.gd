class_name TestSerialization
extends GdUnitTestSuite
## Round-trip state sistem untuk keperluan save/load.


func test_inventory_round_trip() -> void:
	Inventory.add(&"core", 3)
	var snapshot: Dictionary = Inventory.to_dict()
	Inventory.add(&"core", 5)
	Inventory.from_dict(snapshot)
	var expected: int = int(snapshot["materials"].get("core", 0))
	assert_int(Inventory.get_amount(&"core")).is_equal(expected)
	assert_bool(Inventory.has_blueprint(&"bridge_4m")).is_true()
	assert_bool(Inventory.has_suit(&"suit_starter")).is_true()


func test_quest_round_trip() -> void:
	if QuestManager.get_active_quest() == null:
		QuestManager.start_quest(&"bc_001")
	EventBus.item_collected.emit(&"brick", 2)
	var snapshot: Dictionary = QuestManager.to_dict()
	EventBus.item_collected.emit(&"brick", 3)
	QuestManager.from_dict(snapshot)
	var saved_progress: Dictionary = snapshot.get("progress", {})
	var expected: int = int(saved_progress.get("obj_collect", 0))
	assert_int(QuestManager.get_progress(&"obj_collect")).is_equal(expected)
