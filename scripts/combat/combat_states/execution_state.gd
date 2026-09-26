@icon("res://addons/at-icons/node/swords.svg")
extends StateBase

var timeline: Timeline
var combat_state_machine: CombatStateMachine
var context: CombatContext

@onready var state_label: Label = %StateLabel
@onready var return_to_preparation_button: Button = %BackToPreparationButton


func enter(p_context: CombatContext, p_combat_state_machine: CombatStateMachine) -> void:
	combat_state_machine = p_combat_state_machine
	context = p_context
	timeline = context.timeline
	state_label.text = "Current state: Execution"
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
