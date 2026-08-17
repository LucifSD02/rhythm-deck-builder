@icon("res://addons/at-icons/node/brain.svg")
extends State

@onready var label: Label = $"../../CanvasLayer/Label"
@onready var button: Button = $"../../CanvasLayer/Button"
@onready var inventory: InventoryUi = $"../../CanvasLayer/Inventory"
@onready var timeline_ui: TimelineUi = %TimelineUI
@onready var button_2: Button = $"../../CanvasLayer/Button2"
@onready var player: Player = %Player
@onready var enemy: Enemy = %Enemy

var combat_state_machine: CombatStateMachine
var context: CombatContext


func enter(_context: CombatContext, _combat_state_machine: CombatStateMachine) -> void:
	combat_state_machine = _combat_state_machine
	context = _context

	inventory.reload_inventory()
	player.reset_energy()
	player.reset_grid()
	enemy.reset_energy()
	enemy.reset_grid()
	enemy.plan_turn()

	label.text = "Current State: Preparation state"
	button.disabled = false
	timeline_ui.visible = true
	inventory.visible = true
	button_2.disabled = true


func update(_delta: float) -> void:
	pass


func exit() -> void:
	var starting_bar: int = RhythmClock.get_next_suitable_starting_bar(4)
	context.timeline = player.build_timeline(starting_bar)
	context.enemy_timeline = enemy.build_timeline(starting_bar)

	combat_state_machine.change_state(combat_state_machine.rhythm_state, self)
	button.disabled = true
	timeline_ui.visible = false
	inventory.visible = false


func _on_button_button_up() -> void:
	exit()
