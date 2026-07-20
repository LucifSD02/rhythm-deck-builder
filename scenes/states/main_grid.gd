extends GridContainer

const SLOT_SCENE: PackedScene = preload("res://scenes/cards/card_slot.tscn")
const CARD_SCENE: PackedScene = preload("res://scenes/cards/card.tscn")

func _ready() -> void:
	columns = 4
	generate_grid(8)

func generate_grid(slot_count: int) -> void:
	for i: int in range(slot_count):
		var slot_instance: PanelContainer = SLOT_SCENE.instantiate() as PanelContainer
		add_child(slot_instance)
