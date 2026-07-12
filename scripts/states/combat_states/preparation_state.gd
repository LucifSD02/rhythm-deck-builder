@icon("res://addons/at-icons/control/brain.svg")
extends State

@onready var timeline_manager: TimelineManager = $"../TimelineManager"

var combat_state_machine: CombatStateMachine
var context: GameContext
var timeline: Timeline

func enter(_context: GameContext, _combat_state_machine: CombatStateMachine) -> void:
	combat_state_machine = _combat_state_machine
	context = _context
	pass

func update(_delta: float) -> void:
	pass

func exit() -> void:
	timeline = timeline_manager.construct_timeline()
	context.timeline = timeline
	combat_state_machine.change_state(combat_state_machine.rhythm_state, self)

func _on_button_button_up() -> void:
	exit()
