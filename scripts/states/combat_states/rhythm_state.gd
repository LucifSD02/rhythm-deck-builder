extends State

@onready var sequence_creator: SequenceCreator = $"../SequenceCreator"

var combat_state_machine: CombatStateMachine

func enter(context: GameContext, _combat_state_machine: CombatStateMachine) -> void:
	combat_state_machine = _combat_state_machine
	sequence_creator.convert_to_sequence(context.timeline)

func update(_delta: float) -> void:
	pass

func exit() -> void:
	if combat_state_machine == null:
		return
	combat_state_machine.change_state(combat_state_machine.preparation_state, self)
	combat_state_machine.combat_finished.emit()


func _on_button_button_up() -> void:
	exit()
