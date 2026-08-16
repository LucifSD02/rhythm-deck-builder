class_name CellFlag
extends RefCounted


var category_weights: Array[CategoryWeight] = []
var enemy: Enemy

func _init(_enemy: Enemy) -> void:
	enemy = _enemy

func add_entry(category: EffectResult.Category, magnitude: float) -> void:
	var weight: CategoryWeight = CategoryWeight.new(category, magnitude)
	category_weights.append(weight)
	


func get_magnitude_for(card: CardBase) -> float:
	var magnitude: float = 1
	var effects: Array[BaseEffect] = card.get_effects()
	for effect in effects:
		for weight in category_weights:
			if effect.category == weight.category:
				magnitude *= weight.magnitude
	return magnitude


func matches_none(card: CardBase) -> bool:
	var verdict: bool = true
	for weight in category_weights:
		if enemy.card_has_category(card, weight.category):
			verdict = false
	return verdict

class CategoryWeight:
	var category: EffectResult.Category
	var magnitude: float

	func _init(_category: EffectResult.Category, _magnitude: float) -> void:
		category = _category
		magnitude = _magnitude
