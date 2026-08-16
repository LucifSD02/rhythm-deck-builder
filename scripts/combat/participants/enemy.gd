class_name Enemy
extends Combatant

var enemy_data: EnemyData
var enemy_timeline: Timeline
var placement_grid: PlacementGrid = PlacementGrid.new()

const GRID_COLUMNS: int = 4
const GRID_ROWS: int = 2


func generate_placement(_enemy_data: EnemyData) -> void:
	enemy_data = _enemy_data
	populate_inventory_from(enemy_data.card_inventory)
	instrument = enemy_data.instrument
	max_energy = enemy_data.max_energy
	current_energy = max_energy
	placement_grid.setup(GRID_COLUMNS, GRID_ROWS)

	var remaining_cards: Array[CardBase] = card_inventory.duplicate()
	remaining_cards.shuffle()

	while not remaining_cards.is_empty():
		var card: CardBase = remaining_cards.pop_front()
		var coord: Variant = find_random_valid_coord(card)

		if coord == null:
			continue

		placement_grid.place_card(coord, card)


func find_random_valid_coord(card: CardBase) -> Variant:
	var candidates: Array[Vector2i] = []

	for row in range(GRID_ROWS):
		for column in range(GRID_COLUMNS):
			var coord: Vector2i = Vector2i(column, row)
			if placement_grid.check_occupancy(card, coord):
				candidates.append(coord)

	if candidates.is_empty():
		return null

	return candidates.pick_random()
