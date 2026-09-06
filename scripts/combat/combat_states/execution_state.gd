@icon("res://addons/at-icons/node/swords.svg")
extends StateBase

var timeline: Timeline
var combat_state_machine: CombatStateMachine

@onready var sequence_creator: SequenceCreator = %SequenceCreator
@onready var state_label: Label = %StateLabel
@onready var context: CombatContext
@onready var return_to_preparation_button: Button = %BackToPreparationButton
@onready var inventory: GridContainer = %InventoryUI


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func enter(_context: CombatContext, _combat_state_machine: CombatStateMachine) -> void:
	combat_state_machine = _combat_state_machine
	context = _context
	timeline = context.timeline
	state_label.text = "Current State: Execution State"
	return_to_preparation_button.disabled = false
	var results: Array[EffectResult] = EffectResolver.resolve_timeline(timeline, context)
	for result in results:
		print(result.source_card.name, " - ", result.Category.find_key(result.category), " ", result.magnitude, " -> ", EffectBase.Target.find_key(result.target), result.comments)


func update(_delta: float) -> void:
	pass


func exit() -> void:
	if combat_state_machine == null:
		return
	combat_state_machine.change_state(combat_state_machine.preparation_state, self)


func _on_button_2_button_up() -> void:
	exit()
