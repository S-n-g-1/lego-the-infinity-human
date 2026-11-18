class_name EnemyDef
extends Resource
## Definisi statis musuh. Sumber tabel ada di docs/gdd/04-combat.md.

@export var id: StringName = &""
@export var display_name: String = ""
@export var max_health: float = 30.0
@export var required_break_power: int = 1
@export var move_speed: float = 2.5
@export var detect_radius: float = 12.0
@export var attack_damage: float = 10.0
@export var attack_range: float = 1.6
@export var attack_interval: float = 1.2
@export var drop_table: DropTableDef
