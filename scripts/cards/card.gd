class_name Card
extends Control

@export var card_data: CardData

@onready var label: Label
@onready var texture_rect: TextureRect = get_node("TextureRect")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
