@icon("res://addons/at-icons/node/swatches.svg")
class_name CombatStateMachine
extends Node

signal combat_finished

var current_state: StateBase
var combat_context: = CombatContext.new()

@onready var combat_hud: CanvasLayer = %CombatHUD
@onready var rhythm_state: StateBase = %RhythmState
@onready var preparation_state: StateBase = %PreparationState
@onready var execution_state: StateBase = %ExecutionState


func _ready() -> void:
	print("changing to preparation state")
	change_state(preparation_state, current_state)
	connect("combat_finished", combat_hud.combat_check)


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func change_state(next_state: StateBase, calling_state: StateBase) -> void:
	if calling_state != current_state:
		return
	if current_state:
		current_state = null
	current_state = next_state
	current_state.enter(combat_context, self)
