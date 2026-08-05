class_name CombatContext
extends Resource

@export var player_card_pool: Array[CardBase]
@export var bpm: float
@export var timeline: Timeline
@export var judements_individual_cards: Dictionary[int,float]
@export var judgement_whole_timeline: float

var run_inventory: RunInventory
