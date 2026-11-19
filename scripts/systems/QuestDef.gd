class_name QuestDef
extends Resource
## Definisi quest berbasis resource. Objective adalah Dictionary dengan field:
## id, type (collect/build/defeat/interact/explore/talk), target, required, label.
## Prerequisite dan next_quest membentuk graph; fail_on_player_death mengaktifkan retry.

@export var id: StringName
@export var title: String
@export var description: String
@export var quest_type: StringName = &"contract"
@export var objectives: Array[Dictionary] = []
@export var rewards: Dictionary = {}
@export var prerequisites: Array[StringName] = []
@export var next_quest: StringName = &""
@export var fail_on_player_death: bool = false
@export var start_active: bool = false


func get_objective(objective_id: StringName) -> Dictionary:
	for objective in objectives:
		if StringName(objective.get("id", "")) == objective_id:
			return objective
	return {}
