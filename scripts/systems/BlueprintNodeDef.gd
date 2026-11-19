class_name BlueprintNodeDef
extends Resource
## Satu node Blueprint Tree. Fragment membuka node; Creator Level membuka slot.

@export var id: StringName
@export var display_name: String
@export var branch: StringName = &"traversal"
@export var required_level: int = 1
@export var fragment_cost: int = 1
@export var prerequisite_node: StringName = &""
@export var unlock_blueprint: StringName = &""
@export var unlock_suit: StringName = &""
@export var description: String = ""
