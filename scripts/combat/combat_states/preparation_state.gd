@icon("res://addons/at-icons/node/brain.svg")
extends State

@onready var timeline_manager: TimelineManager = $"../TimelineManager"
@onready var label: Label = $"../../CanvasLayer/Label"
@onready var button: Button = $"../../CanvasLayer/Button"
@onready var inventory: InventoryUi = $"../../CanvasLayer/Inventory"
@onready var timeline_ui: TimelineUi = %TimelineUI
@onready var button_2: Button = $"../../CanvasLayer/Button2"

var combat_state_machine: CombatStateMachine
var context: CombatContext
var timeline: Timeline

func enter(_context: CombatContext, _combat_state_machine: CombatStateMachine) -> void:
	inventory.reload_inventory()
	combat_state_machine = _combat_state_machine
	context = _context
	label.text = "Current State: Preparation state"
	button.disabled = false
	timeline_ui.visible = true
	inventory.visible = true
	button_2.disabled = true

func update(_delta: float) -> void:
	pass

func exit() -> void:
	timeline = timeline_manager.construct_timeline()
	timeline.coordinate_to_slot_map = timeline_ui.coordinate_to_slot_map
	timeline.grid_occupancy = timeline_ui.grid_occupancy
	timeline.flattened_cells = timeline_ui.get_cells_for_timeline()
	timeline.cards = timeline_ui.get_cards_from_timeline_ui()
	timeline_manager.set_all_relative_note_event_timings()
	timeline_manager.convert_to_timeline_cells(timeline)
	context.timeline = timeline
	combat_state_machine.change_state(combat_state_machine.rhythm_state, self)
	button.disabled = true
	timeline_ui.visible = false
	inventory.visible = false


func _on_button_button_up() -> void:
	exit()
