class_name EffectResolver
extends RefCounted


static func resolve_timeline(timeline: Timeline, context: CombatContext) -> Array[EffectResult]:
	var raw_results: Array[EffectResult] = gather_results(timeline, context)
	return apply_modifiers(raw_results)


static func gather_results(timeline: Timeline, context: CombatContext) -> Array[EffectResult]:
	var results: Array[EffectResult] = []

	for cell in timeline.flattened_cells:
		var card: CardData = cell.card_reference

		for placement: EffectPlacement in card.effects:
			var effect: EffectBase = placement.effect
			if effect == null:
				continue
			if not effect.conditions_met(context, cell):
				continue

			var accuracy: float = context.judgements_individual_cards.get(card.timeline_id, 0.0)
			var result: EffectResult = effect.resolve(accuracy, context, cell, placement.trigger_offsets, timeline)
			if result != null:
				results.append(result)

	return results


static func apply_modifiers(results: Array[EffectResult]) -> Array[EffectResult]:
	var modifiers: Array[EffectResult] = []
	var final_results: Array[EffectResult] = []

	for result in results:
		if result.category == EffectResult.Category.MODIFIER:
			modifiers.append(result)
		else:
			final_results.append(result)

	for modifier: EffectResult in modifiers:
		for result in final_results:
			if result.category == modifier.modifies_category and is_in_scope(modifier, result):
				apply_operation(modifier, result)
				result.comments.append(modifier.source_card.name)

	return final_results


static func is_in_scope(modifier: EffectResult, result: EffectResult) -> bool:
	match modifier.scope:
		EffectResult.Scope.THIS_CARD:
			return result.source_card == modifier.source_card
		EffectResult.Scope.THIS_BAR:
			return result.cell == modifier.cell
		EffectResult.Scope.RELATIVE_CELLS:
			return modifier.target_cells.has(result.cell)
	return false


static func apply_operation(modifier: EffectResult, result: EffectResult) -> void:
	match modifier.operation:
		EffectResult.Operation.ADD:
			result.magnitude += modifier.magnitude
		EffectResult.Operation.MULTIPLY:
			result.magnitude *= modifier.magnitude
