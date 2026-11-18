extends Node
## Inventaris global untuk material, currency, blueprint, dan suit.
## Weightless sesuai GDD 06 — tidak ada batas jumlah balok.

const STARTER_BLUEPRINTS: Array[StringName] = [&"bridge_4m", &"stair_2m"]
const STARTER_SUIT: StringName = &"suit_starter"

var _items: Dictionary = {
	&"brick": 0,
	&"stud": 0,
	&"core": 0,
	&"blueprint_fragment": 0,
}
var _blueprints: Dictionary = {}
var _suits: Dictionary = {}


func _ready() -> void:
	_reset_to_defaults()
	call_deferred("_connect_signals")


func _reset_to_defaults() -> void:
	for item_id in _items:
		_items[item_id] = 0
	_blueprints.clear()
	_suits.clear()
	for blueprint_id in STARTER_BLUEPRINTS:
		unlock_blueprint(blueprint_id)
	unlock_suit(STARTER_SUIT)


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


func unlock_suit(id: StringName) -> void:
	_suits[id] = true


func has_suit(id: StringName) -> bool:
	return _suits.has(id)


func to_dict() -> Dictionary:
	var materials: Dictionary = {}
	for item_id in _items:
		materials[String(item_id)] = int(_items[item_id])
	var blueprints: Array[String] = []
	for blueprint_id in _blueprints:
		blueprints.append(String(blueprint_id))
	var suits: Array[String] = []
	for suit_id in _suits:
		suits.append(String(suit_id))
	return {
		"materials": materials,
		"blueprints": blueprints,
		"suits": suits,
	}


func from_dict(data: Dictionary) -> void:
	_reset_to_defaults()
	var materials: Dictionary = data.get("materials", {})
	for item_id in materials:
		_items[StringName(item_id)] = maxi(0, int(materials[item_id]))
	for blueprint_id in data.get("blueprints", []):
		unlock_blueprint(StringName(blueprint_id))
	for suit_id in data.get("suits", []):
		unlock_suit(StringName(suit_id))
	EventBus.inventory_changed.emit()
	EventBus.currency_changed.emit(get_studs())
