class_name CardData
extends Resource

@export var name: String
@export var key_amount: int
@export var bar_amount: int
@export var flavour_text: String
@export var melody_notes: Array[NoteEvent]
@export var effects: Array[EffectPlacement]
@export var texture: Texture2D
@export var grid_shape: Array[Vector2i] = [Vector2i(0, 0)]
@export var energy_cost: int

var timeline_id: int
var starting_bar: int


func get_effects() -> Array[EffectBase]:
	var effect_list: Array[EffectBase]
	for placement in effects:
		effect_list.append(placement.effect)
	return effect_list
