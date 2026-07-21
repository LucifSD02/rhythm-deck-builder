@icon("res://addons/at-icons/node/note_double.svg")
extends State

@onready var sequence_creator: SequenceCreator = $"../SequenceCreator"
@onready var label: Label = $"../../CanvasLayer/Label"
@onready var context: GameContext

var combat_state_machine: CombatStateMachine

func enter(_context: GameContext, _combat_state_machine: CombatStateMachine) -> void:
	combat_state_machine = _combat_state_machine
	context = _context
	var timeline: Timeline = context.timeline
	sequence_creator.convert_to_sequence(timeline)
	label.text = "Current State: Rhythm state"

func update(_delta: float) -> void:
	pass

func exit() -> void:
	if combat_state_machine == null:
		return
	combat_state_machine.change_state(combat_state_machine.preparation_state, self)
	combat_state_machine.combat_finished.emit()


func _on_button_button_up() -> void:
	exit()
