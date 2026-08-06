class_name Modifier
extends BaseEffect

@export var modifies_category: EffectResult.Category
@export var operation: EffectResult.Operation = EffectResult.Operation.MULTIPLY
@export var modifier_magnitude: float = 2.0
@export var scope: EffectResult.Scope = EffectResult.Scope.RELATIVE_CELLS
@export var cell_offsets: Array[Vector2i] = [Vector2i(1, 0)]



func resolve(accuracy: float, _context: CombatContext, cell: TimelineCell, trigger_offsets: Array[Vector2i], _timeline: Timeline) -> EffectResult:
	var active_offsets: Array[Vector2i]
	if trigger_offsets.size() != 0:
		active_offsets = trigger_offsets
	else:
		active_offsets = [Vector2i.ZERO]
	if not active_offsets.has(cell.local_offset):
		return null

	var result: EffectResult = create_effect_result(cell)

	if scope == EffectResult.Scope.RELATIVE_CELLS:
		var origin: Vector2i = Vector2i(cell.column, cell.row)
		for offset in cell_offsets:
			var target_cell: TimelineCell = _timeline.get_cell_at(origin + offset)
			if target_cell != null:
				result.target_cells.append(target_cell)

	return result

func create_effect_result(cell: TimelineCell) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	result.category = EffectResult.Category.MODIFIER
	result.magnitude = modifier_magnitude
	result.target = target
	result.source_card = cell.card_reference
	result.cell = cell
	result.modifies_category = modifies_category
	result.operation = operation
	result.scope = scope
	return result
