class_name TestBlueprintTree
extends GdUnitTestSuite
## Blueprint Tree: gate level/fragment/prerequisite, unlock reward, dan round-trip save.

var _progression_snapshot: Dictionary = {}
var _inventory_snapshot: Dictionary = {}
var _tree_snapshot: Dictionary = {}


func before_test() -> void:
	_progression_snapshot = Progression.to_dict()
	_inventory_snapshot = Inventory.to_dict()
	_tree_snapshot = BlueprintTree.to_dict()
	Progression.creator_level = 1
	Progression.xp = 0
	Inventory.from_dict({"materials": {}, "blueprints": [], "suits": []})
	BlueprintTree.reset_state()


func after_test() -> void:
	Progression.from_dict(_progression_snapshot)
	Inventory.from_dict(_inventory_snapshot)
	BlueprintTree.from_dict(_tree_snapshot)


func test_unlock_butuh_level_dan_fragment() -> void:
	assert_bool(BlueprintTree.is_unlocked(&"traversal_root")).is_true()
	assert_bool(BlueprintTree.is_unlocked(&"catapult")).is_false()
	assert_str(BlueprintTree.get_lock_reason(&"catapult")).is_equal("Butuh Creator Lv 2")

	Progression.creator_level = 2
	assert_str(BlueprintTree.get_lock_reason(&"catapult")).is_equal("Butuh 1 Fragment")
	assert_bool(BlueprintTree.unlock(&"catapult")).is_false()

	Inventory.add(&"blueprint_fragment", 1)
	assert_bool(BlueprintTree.can_unlock(&"catapult")).is_true()
	assert_bool(BlueprintTree.unlock(&"catapult")).is_true()
	assert_bool(Inventory.has_blueprint(&"catapult")).is_true()
	assert_int(Inventory.get_amount(&"blueprint_fragment")).is_equal(0)
	assert_bool(BlueprintTree.is_unlocked(&"catapult")).is_true()


func test_node_berantai_butuh_prerequisite() -> void:
	Progression.creator_level = 5
	Inventory.add(&"blueprint_fragment", 6)

	assert_str(BlueprintTree.get_lock_reason(&"architect")).is_equal("Butuh node sebelumnya")
	assert_bool(BlueprintTree.unlock(&"architect")).is_false()

	assert_bool(BlueprintTree.unlock(&"builder")).is_true()
	assert_bool(Inventory.has_suit(&"suit_builder")).is_true()
	assert_str(BlueprintTree.get_lock_reason(&"architect")).is_equal("")
	assert_bool(BlueprintTree.unlock(&"architect")).is_true()
	assert_bool(Inventory.has_suit(&"suit_architect")).is_true()


func test_from_dict_restore_node_setelah_inventory_reset() -> void:
	Progression.creator_level = 3
	Inventory.add(&"blueprint_fragment", 5)
	assert_bool(BlueprintTree.unlock(&"featherstep")).is_true()
	var snapshot: Dictionary = BlueprintTree.to_dict()

	BlueprintTree.reset_state()
	assert_bool(BlueprintTree.is_unlocked(&"featherstep")).is_false()
	Inventory.from_dict({"materials": {}, "blueprints": [], "suits": []})
	assert_bool(Inventory.has_suit(&"suit_featherstep")).is_false()

	BlueprintTree.from_dict(snapshot)
	assert_bool(BlueprintTree.is_unlocked(&"featherstep")).is_true()
	assert_bool(Inventory.has_suit(&"suit_featherstep")).is_true()


func test_semua_node_memiliki_data_valid() -> void:
	var nodes := BlueprintTree.get_all_nodes()
	assert_bool(nodes.size() >= 8).is_true()
	for node: BlueprintNodeDef in nodes:
		assert_bool(node.id != &"").is_true()
		assert_bool(node.display_name != "").is_true()
		assert_bool(
			node.branch == &"traversal"
			or node.branch == &"combat"
			or node.branch == &"utility"
		).is_true()
