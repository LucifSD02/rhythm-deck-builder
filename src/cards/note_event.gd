class_name NoteEvent
extends Resource

@export var time : float:
	get:
		return time - 1
@export var keys_pressed : Array[int]
@export var space_pressed: bool
