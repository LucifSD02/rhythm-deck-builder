class_name InventoryUi
extends GridContainer

const SLOT_SCENE: PackedScene = preload("res://scenes/cards/card_slot.tscn")
const CARD_SCENE: PackedScene = preload("res://scenes/cards/card.tscn")

@onready var player: Player = %Player
@onready var cards: Array[CardData]


func _ready() -> void:
	columns = 4
	generate_grid(12)


func generate_grid(slot_count: int) -> void:
	cards = player.card_inventory
	for i: int in range(slot_count - max(0, (self.get_children().size() - 1))):
		var slot_instance: CardSlot = SLOT_SCENE.instantiate() as CardSlot
		add_child(slot_instance)
		if i >= cards.size():
			return
		add_card_to_grid(slot_instance, i)


func add_card_to_grid(slot_instance: CardSlot, i: int) -> void:
	var card_instance: Card = CARD_SCENE.instantiate() as Card
	card_instance.card_base = cards[i]
	slot_instance.add_child(card_instance)
	set_card_data(card_instance, i)


func set_card_data(card_instance: Card, i: int) -> void:
	var texture_rect: TextureRect = card_instance.get_node("TextureRect")
	texture_rect.texture = cards[i].texture
	texture_rect.custom_minimum_size = Vector2(125, 200)

	var label: Label = card_instance.get_node("Label") as Label
	label.text = cards[i].name

	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_instance.mouse_filter = Control.MOUSE_FILTER_IGNORE


func reload_inventory() -> void:
	for i in range(self.get_children().size() - 1):
		var slot: CardSlot = self.get_child(i)
		var child_count: int = slot.get_child_count()
		if child_count != 0:
			var child: Card = slot.get_child(0)
			child.free()
		add_card_to_grid(slot, i)
