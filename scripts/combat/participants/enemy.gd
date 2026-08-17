class_name Enemy
extends CombatantBase

var enemy_data: EnemyData
var cell_flags: Dictionary[Vector2i, CellFlag] = { }


func _ready() -> void:
	super()
	enemy_data = ResourceLoader.load("res://data/enemies/test_dummy.tres")
	populate_inventory_from(enemy_data.card_inventory)
	instrument = enemy_data.instrument
	max_energy = enemy_data.max_energy


func plan_turn() -> void:
	cell_flags.clear()
	var remaining_cards: Array[CardData] = card_inventory.duplicate()

	while not remaining_cards.is_empty():
		var placement: Variant = find_weighted_placement(remaining_cards, enemy_data.difficulty)
		if placement == null:
			print("No valid placements remaining")
			return
		placement_grid.place_card(placement.coord, placement.card_data)
		update_cell_flags(placement.card_data, placement.coord)
		spend_energy(placement.card_data)
		remaining_cards.erase(placement.card_data)
		print("Placed: ", placement.card_data.name, " at ", placement.coord)


func find_weighted_placement(remaining_cards: Array[CardData], difficulty: float) -> Variant:
	var candidates: Array[WeightedPlacement] = []

	for card_data in remaining_cards:
		if card_data.energy_cost > current_energy:
			continue
		for row in range(GRID_ROWS):
			for column in range(GRID_COLUMNS):
				var coord: Vector2i = Vector2i(column, row)
				if placement_grid.is_unoccupied_at(card_data, coord):
					var weight: float = get_placement_weight(card_data, coord, difficulty)
					print("Candidate added, card_data ", card_data.name, ", coord ", coord, ", weight ", weight)
					candidates.append(WeightedPlacement.new(card_data, coord, weight))

	print("All candidates added, ", candidates.size(), " total options")

	if candidates.is_empty():
		return null

	var total_weight: float = 0.0
	for candidate in candidates:
		total_weight += candidate.weight

	var roll: float = randf() * total_weight
	print("Rolled ", roll, ", total is ", total_weight)
	var progress: float = 0.0
	for candidate in candidates:
		progress += candidate.weight
		print("Progress is ", progress, ", target is ", roll, ", skipping ", candidate.card_data.name)
		if progress > roll:
			print("Found match")
			return candidate
	return candidates[-1]


func get_modifiers(card_data: CardData) -> Array[Modifier]:
	var effects: Array[EffectBase] = card_data.get_effects()
	var modifiers: Array[Modifier]
	for effect in effects:
		if effect.category == EffectResult.Category.MODIFIER:
			modifiers.append(effect)
	return modifiers


func is_modifier_card(card_data: CardData) -> bool:
	return not get_modifiers(card_data).is_empty()


func is_multi_cell_card(card_data: CardData) -> bool:
	return card_data.grid_shape.size() > 1


func card_has_category(card_data: CardData, category: EffectResult.Category) -> bool:
	var effects: Array[EffectBase] = card_data.get_effects()
	for effect in effects:
		if effect.category == category:
			return true
	return false


func get_affected_coords(card_data: CardData, anchor: Vector2i) -> Array[Vector2i]:
	var affected_coords: Array[Vector2i] = []
	for modifier in get_modifiers(card_data):
		for offset in modifier.cell_offsets:
			affected_coords.append(anchor + offset)
	return affected_coords


func has_out_of_bounds_target(card_data: CardData, coord: Vector2i) -> bool:
	var affected_coords: Array[Vector2i] = get_affected_coords(card_data, coord)
	for affected_coord in affected_coords:
		if affected_coord.x < 0 or affected_coord.x >= GRID_COLUMNS or affected_coord.y < 0 or affected_coord.y >= GRID_ROWS:
			return true
	return false


func update_cell_flags(card_data: CardData, anchor: Vector2i) -> void:
	for modifier in get_modifiers(card_data):
		for offset in modifier.cell_offsets:
			var coord: Vector2i = anchor + offset
			var cell_flag: CellFlag = cell_flags.get(coord)
			if cell_flag == null:
				cell_flag = CellFlag.new(self)
			cell_flag.add_entry(modifier.modifies_category, modifier.magnitude)
			print("Added a new CellFlag at ", coord, " -> category: ", modifier.magnitude, ", magnitude: ", modifier.magnitude)
			cell_flags[coord] = cell_flag


func get_eased_difficulty(difficulty: float) -> float:
	return smoothstep(0.0, 1.0, difficulty)


func get_occupant_match(coord: Vector2i, category: EffectResult.Category) -> Variant:
	var occupant: OccupancyBlock = placement_grid.get_occupancy_at(coord)
	if occupant == null:
		return null
	if card_has_category(occupant.card_reference, category):
		return true
	return false


func get_occupant_match_multiplier(card_data: CardData, coord: Vector2i, eased_difficulty: float) -> float:
	if not is_modifier_card(card_data):
		return 1.0

	var multiplier: float = 1.0
	var affected_coords: Array[Vector2i] = get_affected_coords(card_data, coord)

	for modifier in get_modifiers(card_data):
		for affected_coord in affected_coords:
			var match_result: Variant = get_occupant_match(affected_coord, modifier.modifies_category)
			if match_result == true:
				multiplier *= 1 + (modifier.magnitude - 1) * eased_difficulty
			elif match_result == false:
				multiplier *= 1 - (0.7 * eased_difficulty)

	return multiplier


func get_placement_weight(card_data: CardData, coord: Vector2i, difficulty: float) -> float:
	var eased_difficulty: float = get_eased_difficulty(difficulty)
	var weight: float = 1.0

	if is_multi_cell_card(card_data):
		weight *= 1.0 + (0.15 * card_data.grid_shape.size())

	var flag: CellFlag = cell_flags.get(coord)
	if flag != null:
		weight *= 1 + (flag.get_magnitude_for(card_data) - 1) * eased_difficulty
		if flag.matches_none(card_data):
			weight *= 1 - (0.7 * eased_difficulty)

	if is_modifier_card(card_data) and has_out_of_bounds_target(card_data, coord):
		weight *= 1 - (0.9 * eased_difficulty)

	if is_modifier_card(card_data):
		weight *= 1 + (0.8 * eased_difficulty)

	weight *= get_occupant_match_multiplier(card_data, coord, eased_difficulty)

	return weight


class WeightedPlacement:
	var card_data: CardData
	var coord: Vector2i
	var weight: float


	func _init(_card: CardData, _coord: Vector2i, _weight: float) -> void:
		card_data = _card
		coord = _coord
		weight = _weight
