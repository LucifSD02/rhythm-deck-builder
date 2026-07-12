class_name GameStateMachine
extends Node

var current_state: State
var game_context: GameContext

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_state.update(delta)

func change_state(next_state_name: String) -> void:
	if current_state:
		current_state.exit()
		remove_child(current_state)
	var next_state: State = load("res://src/logic/states/" + next_state_name + ".gd").new()
	pass
