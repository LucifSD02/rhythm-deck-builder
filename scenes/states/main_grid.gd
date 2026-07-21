class_name TimelineUi
extends GridContainer

const SLOT_SCENE: PackedScene = preload("res://scenes/cards/card_slot.tscn")
const CARD_SCENE: PackedScene = preload("res://scenes/cards/card.tscn")
const SILENCE = preload("uid://d1ykg17wc4e62")

func _ready() -> void:
	columns = 4
	generate_grid(8)

func generate_grid(slot_count: int) -> void:
	for i: int in range(slot_count):
		var slot_instance: CardSlot = SLOT_SCENE.instantiate() as CardSlot
		slot_instance.accessibility_name = "slot " + str(i)
		slot_instance.timeline_id = i
		add_child(slot_instance)

func get_cards_from_timeline_ui() -> Array[CardBase]:
	var cards: Array[CardBase]
	for child_index in range(self.get_child_count()):
		var child_card_slot: CardSlot = get_child(child_index)
		if child_card_slot.get_child_count() == 0:
			cards.append(SILENCE)
			continue
		var child_card: Card = child_card_slot.get_child(0)
		if child_card == null:
			continue
		cards.append(child_card.stats.duplicate(true))
	return cards

func get_slot_by_id(id: int) -> CardSlot:
	var slots: Array[Node] = get_children()
	for slot in slots:
		if slot.timeline_id == id:
			return slot
	return null
