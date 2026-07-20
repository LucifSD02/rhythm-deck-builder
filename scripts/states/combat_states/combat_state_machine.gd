@icon("res://addons/at-icons/node/swatches.svg")
class_name CombatStateMachine
extends Node

@onready var canvas_layer: CanvasLayer = $"../CanvasLayer"
@onready var rhythm_state: State = %RhythmState
@onready var preparation_state: State = %PreparationState

var current_state: State
var game_context: GameContext = GameContext.new()
signal combat_finished

func _ready() -> void:
	print("changing to preparation state")
	change_state(preparation_state, current_state)
	connect("combat_finished", canvas_layer.combat_check)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func change_state(next_state: State, calling_state: State) -> void:
	if calling_state != current_state:
		return
	if current_state:
		current_state = null
	current_state = next_state
	current_state.enter(game_context, self)
