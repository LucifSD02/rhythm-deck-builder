class_name Modifier
extends BaseEffect

@export var modifies_category: EffectResult.Category
@export var operation: EffectResult.Operation = EffectResult.Operation.MULTIPLY
@export var modifier_magnitude: float = 2.0
@export var scope: EffectResult.Scope = EffectResult.Scope.RELATIVE_CELLS
@export var cell_offsets: Array[Vector2i] = [Vector2i(1, 0)]



func resolve(_accuracy: float, context: CombatContext, cell: TimelineCell) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	result.category = EffectResult.Category.MODIFIER
	result.magnitude = modifier_magnitude
	result.target = target
	result.source_card = cell.card_reference
	result.cell = cell
	result.modifies_category = modifies_category
	result.operation = operation
	result.scope = scope

	if scope == EffectResult.Scope.RELATIVE_CELLS:
		var origin: Vector2i = Vector2i(cell.column, cell.row)
		for offset in cell_offsets:
			var target_cell: TimelineCell = context.timeline.get_cell_at(origin + offset)
			if target_cell != null:
				result.target_cells.append(target_cell)

	return result
