class_name TestHud
extends GdUnitTestSuite
## Regresi: HUD harus menerima sinyal dengan argumen (currency_changed)
## maupun tanpa argumen (inventory_changed).

func test_currency_changed_memperbarui_hud() -> void:
	var hud := load("res://scenes/ui/HUD.tscn").instantiate() as CanvasLayer
	add_child(hud)
	await get_tree().process_frame
	await get_tree().process_frame

	EventBus.currency_changed.emit(77)
	await get_tree().process_frame
	var label := hud.get_node("BrickLabel") as Label
	assert_str(label.text).contains("Stud")

	EventBus.inventory_changed.emit()
	await get_tree().process_frame
	assert_str(label.text).contains("Balok")
