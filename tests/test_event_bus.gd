class_name TestEventBus
extends GdUnitTestSuite
## Test bahwa sinyal global bisa dipancarkan dan diterima.


func test_sinyal_notification_terkirim() -> void:
	var diterima: Array[String] = []
	var callback := func(text: String) -> void: diterima.append(text)

	EventBus.notification_requested.connect(callback)
	EventBus.notification_requested.emit("Halo dari test")
	EventBus.notification_requested.disconnect(callback)

	assert_int(diterima.size()).is_equal(1)
	assert_str(diterima[0]).is_equal("Halo dari test")


func test_sinyal_quest_completed_terkirim() -> void:
	var terima_id: Array[StringName] = []
	var callback := func(id: StringName) -> void: terima_id.append(id)

	EventBus.quest_completed.connect(callback)
	EventBus.quest_completed.emit(&"BC_001")
	EventBus.quest_completed.disconnect(callback)

	assert_int(terima_id.size()).is_equal(1)
	assert_str(terima_id[0]).is_equal("BC_001")
