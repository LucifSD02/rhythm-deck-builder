extends GridContainer

@onready var timeline_manager: TimelineManager = $"../../CombatStateMachine/TimelineManager"
@onready var cards: Array[CardBase] = timeline_manager.cards
const SLOT_SCENE: PackedScene = preload("res://scenes/cards/card_slot.tscn")
const CARD_SCENE: PackedScene = preload("res://scenes/cards/card.tscn")

func _ready() -> void:
	columns = 4
	generate_grid(12)
	

func generate_grid(slot_count: int) -> void:
	for i: int in range(slot_count):
		var slot_instance: PanelContainer = SLOT_SCENE.instantiate() as PanelContainer
		add_child(slot_instance)
		if i < cards.size():
			var card_instance: Card = CARD_SCENE.instantiate() as Card
			var texture_rect: TextureRect = card_instance.get_node("TextureRect")
			texture_rect.texture = cards[i].texture
			texture_rect.custom_minimum_size = Vector2(125, 200)
			card_instance.stats = cards[i]
			slot_instance.add_child(card_instance)
			var label: Label = card_instance.get_node("Label") as Label
			label.text = cards[i].name
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card_instance.mouse_filter = Control.MOUSE_FILTER_IGNORE
