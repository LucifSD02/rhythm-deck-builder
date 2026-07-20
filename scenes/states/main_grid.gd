extends GridContainer

const SLOT_SCENE: PackedScene = preload("res://scenes/cards/card_slot.tscn")
const CARD_SCENE: PackedScene = preload("res://scenes/cards/card.tscn")
const ROUND = preload("uid://but8r0yq3f17o")
const PHOTO_2023_03_17_22_45_25 = preload("uid://do6fgi7frdxex")
const PHOTO_2024_07_23_23_06_26 = preload("uid://b0yot5704cdib")
const SCREENSHOT_2 = preload("uid://clng4fggbmgfw")
var imgs: Array[Texture] = [PHOTO_2023_03_17_22_45_25, PHOTO_2024_07_23_23_06_26, SCREENSHOT_2]

func _ready() -> void:
	columns = 4
	generate_grid(8)

func generate_grid(slot_count: int) -> void:
	for i: int in range(slot_count):
		var slot_instance: PanelContainer = SLOT_SCENE.instantiate() as PanelContainer
		add_child(slot_instance)
		if i < 3:
			var card_instance: Card = CARD_SCENE.instantiate() as Card
			slot_instance.add_child(card_instance)
			var texture_rect: TextureRect = card_instance.get_node("TextureRect") as TextureRect
			var ri: int = randi() % 3
			texture_rect.texture = imgs[ri]
			texture_rect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			var label: Label = card_instance.get_node("Label") as Label
			label.text = "Item " + str(i + 1)
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card_instance.mouse_filter = Control.MOUSE_FILTER_IGNORE
