class_name AccuracyCondition
extends Condition

enum Scope { CARD, TIMELINE }
enum Comparison { GREATER_EQUAL, GREATER, LESS_EQUAL, LESS, EQUAL }

@export var scope: Scope = Scope.CARD
@export var comparison: Comparison = Comparison.GREATER_EQUAL
@export var threshold: float = 0.0


func is_met(context: CombatContext, cell: TimelineCell) -> bool:
	var accuracy: float = get_accuracy(context, cell)
	return compare(accuracy, threshold)


func get_accuracy(context: CombatContext, cell: TimelineCell) -> float:
	if scope == Scope.TIMELINE:
		return context.judgement_whole_timeline
	return context.judgements_individual_cards.get(cell.card_reference.timeline_id, 0.0)


func compare(accuracy: float, target: float) -> bool:
	match comparison:
		Comparison.GREATER_EQUAL:
			return accuracy >= target
		Comparison.GREATER:
			return accuracy > target
		Comparison.LESS_EQUAL:
			return accuracy <= target
		Comparison.LESS:
			return accuracy < target
		Comparison.EQUAL:
			return is_equal_approx(accuracy, target)
	return false
