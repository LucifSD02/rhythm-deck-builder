class_name State
extends Node

signal transition_requested(next_state: String, context: GameContext)

func enter(context: GameContext, combat_state_machine: CombatStateMachine) -> void:
	pass

func update(_delta: float) -> void:
	pass

func exit() -> void:
	pass
