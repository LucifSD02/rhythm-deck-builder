class_name State
extends Node

signal transition_requested(next_state: String, context: CombatContext)

func enter(context: CombatContext, combat_state_machine: CombatStateMachine) -> void:
	pass

func update(_delta: float) -> void:
	pass

func exit() -> void:
	pass
