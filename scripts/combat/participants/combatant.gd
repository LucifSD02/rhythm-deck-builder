class_name Combatant
extends Node

var instrument: BaseInstrument
var card_inventory: Array[CardBase] = []
var armour: int
var stagger_threshold: int
var status_effects: Array = []  # TODO: needs its own design pass
var max_energy: int
var current_energy: int


func populate_inventory_from(source: Array[CardBase]) -> void:
	card_inventory = source.duplicate()


func can_afford(card: CardBase) -> bool:
	return current_energy >= card.energy_cost


func spend_energy(card: CardBase) -> void:
	current_energy -= card.energy_cost

func reset_energy() -> void:
	current_energy = max_energy
