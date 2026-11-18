class_name TestInventoryAndQuests
extends GdUnitTestSuite
## Test integrasi ringan untuk Inventory, QuestManager, dan resource quest.


func test_starter_blueprint_terbuka() -> void:
	assert_bool(Inventory.has_blueprint(&"bridge_4m")).is_true()
	assert_bool(Inventory.has_blueprint(&"stair_2m")).is_true()


func test_bayar_dan_refund() -> void:
	var before := Inventory.get_bricks()
	Inventory.add(&"brick", 20)
	assert_bool(Inventory.can_afford({&"brick": 12})).is_true()
	assert_bool(Inventory.pay({&"brick": 12})).is_true()
	assert_int(Inventory.get_bricks()).is_equal(before + 8)
	Inventory.refund({&"brick": 12})
	assert_int(Inventory.get_bricks()).is_equal(before + 20)


func test_quest_aktif_termuat() -> void:
	if QuestManager.get_active_quest() == null:
		QuestManager.start_quest(&"bc_001")
	var quest := QuestManager.get_active_quest()
	assert_bool(quest != null).is_true()
	if quest != null:
		assert_str(String(quest.id)).is_equal("bc_001")
		assert_int(quest.objectives.size()).is_equal(3)


func test_progres_collect_bertambah() -> void:
	var before := QuestManager.get_progress(&"obj_collect")
	EventBus.item_collected.emit(&"brick", 1)
	assert_int(QuestManager.get_progress(&"obj_collect")).is_equal(mini(12, before + 1))


func test_blueprint_resource_valid() -> void:
	var blueprint := load("res://resources/items/bp_bridge_4m.tres") as BlueprintDef
	assert_bool(blueprint != null).is_true()
	if blueprint != null:
		assert_str(String(blueprint.id)).is_equal("bridge_4m")
		assert_int(int(blueprint.cost.get(&"brick", 0))).is_equal(12)
