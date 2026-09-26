extends GutTest

const TIMELINE_50_PLUS: AccuracyCondition = preload("uid://o7ly8nrofmd1")

var timeline_50_plus_cases: Array[Dictionary] = [
	{"name": "exactly 50% timeline, passes", "timeline": 0.5, "card": 0.0, "expected": true},
	{"name": "exactly 49% timeline, fails", "timeline": 0.49, "card": 1.0, "expected": false},
]


func test_timeline_50_plus(p: Dictionary = use_parameters(timeline_50_plus_cases)) -> void:
	var context: CombatContext = CombatContext.new()
	context.judgement_whole_timeline = p.timeline
	context.judgements_individual_cards[1] = p.card

	var cell: TimelineCell = TimelineCell.new()
	cell.card_reference = CardData.new()
	cell.card_reference.timeline_id = 1

	assert_eq(TIMELINE_50_PLUS.is_met(context, cell), p.expected, p.name)
