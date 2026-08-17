class_name Attack
extends EffectBase

@export var attack_damage: int = 0
@export var debuff_duration: int = 0


func _init() -> void:
	category = EffectResult.Category.DAMAGE


func resolve(accuracy: float, _context: CombatContext, cell: TimelineCell, trigger_offsets: Array[Vector2i], _timeline: Timeline) -> EffectResult:
	var portion: float = get_cell_allocation(cell.card_reference, trigger_offsets).get(cell.local_offset, 0.0)
	if portion <= 0.0:
		return null
	var result: EffectResult = create_effect_result(cell, accuracy, portion)
	return result


func create_effect_result(cell: TimelineCell, accuracy: float, portion: float) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	result.category = EffectResult.Category.DAMAGE
	result.magnitude = attack_damage * accuracy * portion
	result.target = target
	result.source_card = cell.card_reference
	result.cell = cell
	return result
