extends State

@onready var sequence_creator: SequenceCreator = $"../SequenceCreator"
@onready var label: Label = $"../../CanvasLayer/Label"
@onready var context: CombatContext
@onready var button_2: Button = $"../../CanvasLayer/Button2"
@onready var timeline_ui: TimelineUi = %TimelineUI
@onready var inventory: GridContainer = $"../../CanvasLayer/Inventory"

var timeline: Timeline
var combat_state_machine: CombatStateMachine

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func enter(_context: CombatContext, _combat_state_machine: CombatStateMachine) -> void:
	combat_state_machine = _combat_state_machine
	context = _context
	timeline = context.timeline
	label.text = "Current State: Execution State"
	button_2.disabled = false

func update(_delta: float) -> void:
	pass

func exit() -> void:
	timeline_ui.clear_timeline()
	if combat_state_machine == null:
		return
	combat_state_machine.change_state(combat_state_machine.preparation_state, self)


func _on_button_2_button_up() -> void:
	exit()
