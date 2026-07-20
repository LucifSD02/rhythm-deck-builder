class_name TimelineUi
extends GridContainer

const SLOT_SCENE: PackedScene = preload("res://scenes/cards/card_slot.tscn")
const CARD_SCENE: PackedScene = preload("res://scenes/cards/card.tscn")

func _ready() -> void:
	columns = 4
	generate_grid(8)

func generate_grid(slot_count: int) -> void:
	for i: int in range(slot_count):
		var slot_instance: PanelContainer = SLOT_SCENE.instantiate() as PanelContainer
		slot_instance.accessibility_name = "slot " + str(i)
		add_child(slot_instance)

func get_timeline() -> Array[CardBase]:
	var cards: Array[CardBase]
	for child_index in range(self.get_child_count()):
		var child_card_slot: PanelContainer = get_child(child_index)
		if child_card_slot.get_child_count() == 0:
			continue
		var child_card: Card = child_card_slot.get_child(0)
		if child_card == null:
			continue
		cards.append(child_card.stats)
	return cards
