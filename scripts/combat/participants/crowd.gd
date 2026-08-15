class_name Crowd
extends Node

var score: float = 50:
	set(new_value):
		score = clamp(new_value, 0, 125)
var target_score: float = 100


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func receive_hype(change: float) -> void:
	score += change
