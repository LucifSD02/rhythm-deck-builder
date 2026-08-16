class_name Enemy
extends Combatant

var enemy_data: EnemyData
var timeline: Timeline
var timeline_manager: TimelineManager = TimelineManager.new()
var placement_grid: PlacementGrid = PlacementGrid.new()
var cell_flags: Dictionary[Vector2i, CellFlag] = { }

const GRID_COLUMNS: int = 4
const GRID_ROWS: int = 2
const SILENCE: Resource = preload("uid://d1ykg17wc4e62")

func _ready() -> void:
	var test_enemy_data: EnemyData = ResourceLoader.load("res://data/enemies/test_dummy.tres")
	generate_placement(test_enemy_data, test_enemy_data.difficulty)

func populate_timeline_from_grid() -> void:
	timeline.columns = GRID_COLUMNS
	var duplicated_cards: Dictionary[CardBase, CardBase] = {}
	var cards_array: Array[CardBase] = []
	var cells_array: Array[TimelineCell] = []

	for row: int in range(GRID_ROWS):
		for column: int in range(GRID_COLUMNS):
			var coord: Vector2i = Vector2i(column, row)
			var occupancy_block: OccupancyBlock = placement_grid.get_occupancy_at(coord)
			var timeline_cell: TimelineCell = TimelineCell.new()
			timeline_cell.column = column
			timeline_cell.row = row

			if occupancy_block != null and occupancy_block.card_reference != null:
				var card_base: CardBase = occupancy_block.card_reference
				if not duplicated_cards.has(card_base):
					duplicated_cards[card_base] = card_base.duplicate(true) as CardBase
				timeline_cell.card_reference = duplicated_cards[card_base]
				timeline_cell.is_anchor = occupancy_block.is_anchor
				timeline_cell.local_offset = occupancy_block.local_offset
			else:
				timeline_cell.card_reference = SILENCE.duplicate(true) as CardBase
				timeline_cell.is_anchor = true
				timeline_cell.local_offset = Vector2i.ZERO

			cells_array.append(timeline_cell)
			if timeline_cell.is_anchor and timeline_cell.card_reference.name != "Silence":
				cards_array.append(timeline_cell.card_reference)

	timeline.cards = cards_array
	timeline.flattened_cells = cells_array

func generate_placement(_enemy_data: EnemyData, difficulty: float) -> void:
	enemy_data = _enemy_data
	populate_inventory_from(enemy_data.card_inventory)
	instrument = enemy_data.instrument
	max_energy = enemy_data.max_energy
	current_energy = max_energy
	cell_flags.clear()
	placement_grid.setup(GRID_COLUMNS, GRID_ROWS)

	var remaining_cards: Array[CardBase] = card_inventory.duplicate()

	while not remaining_cards.is_empty():
		var placement: Variant = find_weighted_placement(remaining_cards, difficulty)

		if placement == null:
			print("No valid placements remaining")
			return
		
		placement_grid.place_card(placement.coord, placement.card)
		update_cell_flags(placement.card, placement.coord)
		spend_energy(placement.card)
		print("Spent ", placement.card.energy_cost, " energy, ", current_energy, " remaining")
		remaining_cards.erase(placement.card)
		print("Placed: ", placement.card.name, " at ", placement.coord)


func find_random_valid_coord(card: CardBase) -> Variant:
	var candidates: Array[Vector2i] = []
	for row in range(GRID_ROWS):
		for column in range(GRID_COLUMNS):
			var coord: Vector2i = Vector2i(column, row)
			if placement_grid.is_unoccupied_at(card, coord):
				candidates.append(coord)
	if candidates.is_empty():
		return null
	return candidates.pick_random()

func find_weighted_placement(remaining_cards: Array[CardBase], difficulty: float) -> Variant:
	var candidates: Array[WeightedPlacement] = []

	for card in remaining_cards:
		if card.energy_cost > current_energy:
			continue
		for row in range(GRID_ROWS):
			for column in range(GRID_COLUMNS):
				var coord: Vector2i = Vector2i(column, row)
				if placement_grid.is_unoccupied_at(card, coord):
					var weight: float = get_placement_weight(card, coord, difficulty)
					print("Candidate added, card ", card.name, ", coord ", coord, ", weight ", weight)
					candidates.append(WeightedPlacement.new(card, coord, weight))

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
		print("Progress is ", progress, ", target is ", roll, ", skipping ", candidate.card.name)
		if progress > roll:
			print("Found match")
			return candidate
	return candidates[-1]

func find_lowest_card_energy_cost(remaining_cards: Array[CardBase], _card: CardBase) -> int:
	var costs: Array[int]
	var all_cards: Array[CardBase] = remaining_cards.duplicate()
	all_cards.append(_card)
	for card in all_cards:
		costs.append(card.energy_cost)
	return costs.min()


func get_modifiers(card: CardBase) -> Array[Modifier]:
	var effects: Array[BaseEffect] = card.get_effects()
	var modifiers: Array[Modifier]
	for effect in effects:
		if effect.category == EffectResult.Category.MODIFIER:
			modifiers.append(effect)
	return modifiers


func is_modifier_card(card: CardBase) -> bool:
	return not get_modifiers(card).is_empty()


func is_multi_cell_card(card: CardBase) -> bool:
	return card.grid_shape.size() > 1


func card_has_category(card: CardBase, category: EffectResult.Category) -> bool:
	var effects: Array[BaseEffect] = card.get_effects()
	for effect in effects:
		if effect.category == category:
			return true
	return false


func get_affected_coords(card: CardBase, anchor: Vector2i) -> Array[Vector2i]:
	var affected_coords: Array[Vector2i] = []
	for modifier in get_modifiers(card):
		for offset in modifier.cell_offsets:
			affected_coords.append(anchor + offset)
	return affected_coords


func has_out_of_bounds_target(card: CardBase, coord: Vector2i) -> bool:
	var affected_coords: Array[Vector2i] = get_affected_coords(card, coord)
	for affected_coord in affected_coords:
		if affected_coord.x < 0 or affected_coord.x >= GRID_COLUMNS or affected_coord.y < 0 or affected_coord.y >= GRID_ROWS:
			return true
	return false


func update_cell_flags(card: CardBase, anchor: Vector2i) -> void:
	for modifier in get_modifiers(card):
		for offset in modifier.cell_offsets:
			var coord: Vector2i = anchor + offset
			var cell_flag: CellFlag = cell_flags.get(coord)
			if cell_flag == null:
				cell_flag = CellFlag.new(self)
			cell_flag.add_entry(modifier.modifies_category, modifier.modifier_magnitude)
			print("Added a new CellFlag at ", coord, " -> category: ", modifier.modifier_magnitude, ", magnitude: ", modifier.modifier_magnitude)
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


func get_occupant_match_multiplier(card: CardBase, coord: Vector2i, eased_difficulty: float) -> float:
	if not is_modifier_card(card):
		return 1.0

	var multiplier: float = 1.0
	var affected_coords: Array[Vector2i] = get_affected_coords(card, coord)

	for modifier in get_modifiers(card):
		for affected_coord in affected_coords:
			var match_result: Variant = get_occupant_match(affected_coord, modifier.modifies_category)
			if match_result == true:
				multiplier *= 1 + (modifier.modifier_magnitude - 1) * eased_difficulty
			elif match_result == false:
				multiplier *= 1 - (0.7 * eased_difficulty)

	return multiplier


func get_placement_weight(card: CardBase, coord: Vector2i, difficulty: float) -> float:
	var eased_difficulty: float = get_eased_difficulty(difficulty)
	var weight: float = 1.0

	if is_multi_cell_card(card):
		weight *= 1.0 + (0.15 * card.grid_shape.size())

	var flag: CellFlag = cell_flags.get(coord)
	if flag != null:
		weight *= 1 + (flag.get_magnitude_for(card) - 1) * eased_difficulty
		if flag.matches_none(card):
			weight *= 1 - (0.7 * eased_difficulty)

	if is_modifier_card(card) and has_out_of_bounds_target(card, coord):
		weight *= 1 - (0.9 * eased_difficulty)

	if is_modifier_card(card):
		weight *= 1 + (0.8 * eased_difficulty)

	weight *= get_occupant_match_multiplier(card, coord, eased_difficulty)

	return weight

class WeightedPlacement:
	var card: CardBase
	var coord: Vector2i
	var weight: float

	func _init(_card: CardBase, _coord: Vector2i, _weight: float) -> void:
		card = _card
		coord = _coord
		weight = _weight
