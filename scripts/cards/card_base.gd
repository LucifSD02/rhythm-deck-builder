class_name CardBase
extends Resource

var timeline_id: int
var starting_bar: int
@export var name: String
@export var key_amount: int
@export var bar_amount: int
@export var flavour_text: String
@export var melody_notes: Array[NoteEvent]
@export var effects: Array[Resource]
@export var texture: Texture2D
@export var grid_shape: Array[Vector2i] = [ Vector2i(0, 0) ]
