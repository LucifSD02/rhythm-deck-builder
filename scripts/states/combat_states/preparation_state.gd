@icon("res://addons/at-icons/node/brain.svg")
extends State

@onready var timeline_manager: TimelineManager = $"../TimelineManager"
@onready var label: Label = $"../../CanvasLayer/Label"
@onready var button: Button = $"../../CanvasLayer/Button"
@onready var inventory: GridContainer = $"../../CanvasLayer/Inventory"
@onready var timeline_ui: TimelineUi = %Timeline

var combat_state_machine: CombatStateMachine
var context: GameContext
var timeline: Timeline

func enter(_context: GameContext, _combat_state_machine: CombatStateMachine) -> void:
	combat_state_machine = _combat_state_machine
	context = _context
	label.text = "Current State: Preparation state"

func update(_delta: float) -> void:
	pass

func exit() -> void:
	timeline = timeline_manager.construct_timeline()
	timeline.cards = timeline_ui.get_cards_from_timeline_ui()
	timeline_manager.set_all_relative_note_event_timings(timeline)
	context.timeline = timeline
	combat_state_machine.change_state(combat_state_machine.rhythm_state, self)
	button.disabled = true
	timeline_ui.visible = false
	inventory.visible = false

func _on_button_button_up() -> void:
	exit()
