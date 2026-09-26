class_name CellFlag
extends RefCounted

var category_weights: Array[CategoryWeight] = []
var enemy: Enemy


func _init(p_enemy: Enemy) -> void:
	enemy = p_enemy


func add_entry(category: EffectResult.Category, magnitude: float) -> void:
	var weight: CategoryWeight = CategoryWeight.new(category, magnitude)
	category_weights.append(weight)


func get_magnitude_for(card_data: CardData) -> float:
	var magnitude: float = 1
	var effects: Array[EffectBase] = card_data.get_effects()
	for effect in effects:
		for weight in category_weights:
			if effect.category == weight.category:
				magnitude *= weight.magnitude
	return magnitude


func matches_any_category(card_data: CardData) -> bool:
	for weight in category_weights:
		if enemy.card_has_category(card_data, weight.category):
			return true
	return false


class CategoryWeight:
	var category: EffectResult.Category
	var magnitude: float


	func _init(p_category: EffectResult.Category, p_magnitude: float) -> void:
		category = p_category
		magnitude = p_magnitude
