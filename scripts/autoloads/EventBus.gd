extends Node
## Bus sinyal global.
##
## Semua komunikasi antar-sistem sebaiknya lewat sinyal di sini agar modul
## tidak saling tahu detail implementasi (low coupling). Sistem boleh tetap
## punya sinyal lokal untuk kebutuhan internal.

# --- Alur game -------------------------------------------------------------
signal game_started()
signal game_paused(is_paused: bool)
signal game_saved(slot: int)
signal game_loaded(slot: int)

# --- Player ----------------------------------------------------------------
signal player_spawned(player: Node)
signal player_died()
signal player_health_changed(current: float, maximum: float)
signal suit_changed(suit_id: StringName)

# --- Item & inventory ------------------------------------------------------
signal item_collected(item_id: StringName, amount: int)
signal item_removed(item_id: StringName, amount: int)
signal inventory_changed()
signal currency_changed(amount: int)

# --- Quest -----------------------------------------------------------------
signal quest_started(quest_id: StringName)
signal quest_objective_updated(quest_id: StringName, objective_id: StringName, progress: int)
signal quest_completed(quest_id: StringName)
signal quest_failed(quest_id: StringName)

# --- Dunia -----------------------------------------------------------------
signal area_entered(area_id: StringName)
signal area_exited(area_id: StringName)
signal checkpoint_activated(checkpoint_id: StringName)
signal world_fragment_restored(fragment_id: StringName)
signal build_mode_toggled(enabled: bool)
signal structure_built(blueprint_id: StringName)
signal blueprint_selected(id: StringName, display_name: String, cost: Dictionary)
signal npc_crossed(npc_id: StringName)
signal prop_broken(prop_id: StringName)

# --- Progresi --------------------------------------------------------------
signal xp_gained(amount: int, source: StringName)
signal creator_level_changed(level: int, xp: int)

# --- UI & naratif ----------------------------------------------------------
signal notification_requested(text: String)
signal objective_updated(text: String)
signal dialogue_started(dialogue_id: StringName)
signal dialogue_finished(dialogue_id: StringName)
signal cutscene_requested(cutscene_id: StringName)
