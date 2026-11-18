extends Node
## Inventaris global untuk material dan currency.
## TODO(M2): integrasi save/load, kategori item lengkap, dan stack generals.

var _items: Dictionary = {
	&"brick": 0,
	&"stud": 0,
	&"core": 0,
}
var _blueprints: Dictionary = {}


func _ready() -> void:
	unlock_blueprint(&"bridge_4m")
	unlock_blueprint(&"stair_2m")
	call_deferred("_connect_signals")


func _connect_signals() -> void:
	EventBus.item_collected.connect(_on_item_collected)
	EventBus.item_removed.connect(_on_item_removed)


func _on_item_collected(item_id: StringName, amount: int) -> void:
	add(item_id, amount)


func _on_item_removed(item_id: StringName, amount: int) -> void:
	remove(item_id, amount)


func get_amount(item_id: StringName) -> int:
	return int(_items.get(item_id, 0))


func get_bricks() -> int:
	return get_amount(&"brick")


func get_studs() -> int:
	return get_amount(&"stud")


func add(item_id: StringName, amount: int) -> void:
	if amount <= 0:
		return
	_items[item_id] = get_amount(item_id) + amount
	EventBus.inventory_changed.emit()
	if item_id == &"stud":
		EventBus.currency_changed.emit(get_amount(item_id))


func remove(item_id: StringName, amount: int) -> void:
	if amount <= 0:
		return
	var next_value: int = maxi(0, get_amount(item_id) - amount)
	_items[item_id] = next_value
	EventBus.inventory_changed.emit()
	if item_id == &"stud":
		EventBus.currency_changed.emit(next_value)


func can_afford(cost: Dictionary) -> bool:
	for item_id in cost:
		if get_amount(StringName(item_id)) < int(cost[item_id]):
			return false
	return true


func pay(cost: Dictionary) -> bool:
	if not can_afford(cost):
		return false
	for item_id in cost:
		remove(StringName(item_id), int(cost[item_id]))
	return true


func refund(cost: Dictionary) -> void:
	for item_id in cost:
		add(StringName(item_id), int(cost[item_id]))


func unlock_blueprint(id: StringName) -> void:
	_blueprints[id] = true


func has_blueprint(id: StringName) -> bool:
	return _blueprints.has(id)
