class_name BaseEffect
extends Resource

enum Target { SELF, OPPONENT, CROWD }

@export var accuracy_modifier: float
@export var target: Target = Target.OPPONENT
@export var conditions: Array[Condition] = []


func conditions_met(context: CombatContext, cell: TimelineCell) -> bool:
	for condition in conditions:
		if not condition.is_met(context, cell):
			return false
	return true


func get_cell_allocation(card: CardBase) -> Dictionary[Vector2i, float]:
	var override: EffectCellOffsets = card.effect_cell_overrides.get(self, null)
	var offsets: Array[Vector2i] = override.offsets if override != null else card.grid_shape
	var allocation: Dictionary[Vector2i, float] = {}
	for offset in offsets:
		allocation[offset] = 1.0 / offsets.size()
	return allocation


func resolve(_accuracy: float, _context: CombatContext, _cell: TimelineCell) -> EffectResult:
	return null
