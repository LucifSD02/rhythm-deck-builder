class_name Card
extends Control

@onready var label: Label
@onready var texture_rect: TextureRect = get_node("TextureRect")
@export var stats: CardBase


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
