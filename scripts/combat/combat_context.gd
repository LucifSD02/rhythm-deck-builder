class_name CombatContext
extends Resource

@export var player_card_pool: Array[CardBase]
@export var timeline: Timeline
@export var companions: Array
@export var modifiers: Array
var judgements_individual_cards: Dictionary[int, float]
var judgement_whole_timeline: float


var run_inventory: RunInventory
