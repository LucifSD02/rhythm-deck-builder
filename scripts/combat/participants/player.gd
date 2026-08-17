class_name Player
extends Combatant


func _ready() -> void:
	super()
	populate_inventory_from(RunLoader.data.card_inventory)
	instrument = RunLoader.data.instrument
	max_energy = 40
