class_name EffectBase
extends Resource

enum Target { SELF, OPPONENT, CROWD }

@export var accuracy_modifier: float
@export var default_target: Target = Target.OPPONENT:
	set(value):
		default_target = value
		target = value
@export var conditions: Array[ConditionBase] = []

var target: Target
var category: EffectResult.Category


func conditions_met(context: CombatContext, cell: TimelineCell) -> bool:
	for condition: ConditionBase in conditions:
		if not condition.is_met(context, cell):
			return false
	return true


func get_cell_allocation(card: CardData, trigger_offsets: Array[Vector2i]) -> Dictionary[Vector2i, float]:
	var offsets: Array[Vector2i] = trigger_offsets if not trigger_offsets.is_empty() else card.grid_shape
	var allocation: Dictionary[Vector2i, float] = { }
	for offset in offsets:
		allocation[offset] = 1.0 / offsets.size()
	return allocation


func resolve(_accuracy: float, _context: CombatContext, _cell: TimelineCell, _trigger_offsets: Array[Vector2i], _timeline: Timeline) -> EffectResult:
	return null
