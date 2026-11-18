class_name QuestDef
extends Resource
## Definisi quest berbasis resource. Objective adalah Dictionary dengan field:
## id, type (collect/build/interact/explore), target, required, label.

@export var id: StringName
@export var title: String
@export var description: String
@export var objectives: Array[Dictionary] = []
@export var rewards: Dictionary = {}
@export var start_active: bool = false


func get_objective(objective_id: StringName) -> Dictionary:
	for objective in objectives:
		if StringName(objective.get("id", "")) == objective_id:
			return objective
	return {}
