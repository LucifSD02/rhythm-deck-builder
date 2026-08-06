extends Node

var card_inventory: Array[CardBase]
var strike_card: CardBase = ResourceLoader.load("res://data/cards/test_strike.tres")
var shield_card: CardBase = ResourceLoader.load("res://data/cards/test_block.tres")
var shield_card_big: CardBase = ResourceLoader.load("res://data/cards/test_block_big.tres")
var two_x_mult_right: CardBase = ResourceLoader.load("res://data/cards/two_x_multiplier_to_the_right.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_inventory = [strike_card, strike_card, strike_card, strike_card, shield_card, two_x_mult_right, two_x_mult_right, shield_card, shield_card_big, shield_card_big]
