@icon("res://addons/at-icons/node/brain.svg")
extends StateBase

const START_SLOT_BARS: int = 4
const MIN_LEAD_BEATS: float = 2.0

var combat_state_machine: CombatStateMachine
var context: CombatContext

@onready var state_label: Label = %StateLabel
@onready var confirm_timeline_button: Button = %ConfirmTimelineButton
@onready var inventory: InventoryUI = %InventoryUI
@onready var timeline_ui: TimelineUI = %TimelineUI
@onready var return_to_preparation_button: Button = %BackToPreparationButton
@onready var player: Player = %Player
@onready var enemy: Enemy = %Enemy


func enter(p_context: CombatContext, p_combat_state_machine: CombatStateMachine) -> void:
	combat_state_machine = p_combat_state_machine
	context = p_context

	inventory.reload_inventory()
	player.reset_energy()
	player.reset_grid()
	enemy.reset_energy()
	enemy.reset_grid()
	enemy.plan_turn()

	state_label.text = "Current state: Preparation"
	confirm_timeline_button.disabled = false
	timeline_ui.visible = true
	inventory.visible = true
	return_to_preparation_button.disabled = true


func update(_delta: float) -> void:
	pass


func exit() -> void:
	var starting_beat: int = RhythmClock.get_next_timeline_start_beat(START_SLOT_BARS, MIN_LEAD_BEATS)
	context.timeline = player.create_timeline(starting_beat)
	context.enemy_timeline = enemy.create_timeline(starting_beat)

	combat_state_machine.change_state(combat_state_machine.rhythm_state, self)
	confirm_timeline_button.disabled = true
	timeline_ui.visible = false
	inventory.visible = false


func _on_button_button_up() -> void:
	exit()
