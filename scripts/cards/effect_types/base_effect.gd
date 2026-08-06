class_name BaseEffect
extends Resource

enum Target { SELF, OPPONENT, CROWD }

@export var accuracy_modifier: float
@export var activation_bar_offset: int = 0
@export var target: Target = Target.OPPONENT
@export var conditions: Array[Condition] = []
var comments: Array[String]


func conditions_met(context: CombatContext, cell: TimelineCell) -> bool:
	for condition in conditions:
		if not condition.is_met(context, cell):
			return false
	return true


func get_cell_allocation(card: CardBase) -> Dictionary[Vector2i, float]:
	var allocation: Dictionary[Vector2i, float] = {}
	var occupied_cells: int = card.grid_shape.size()
	for offset in card.grid_shape:
		allocation[offset] = 1.0 / occupied_cells
	return allocation


func resolve(_accuracy: float, _context: CombatContext, _cell: TimelineCell) -> EffectResult:
	return null
