class_name PlacementGrid
extends RefCounted

var columns: int
var rows: int
var grid_occupancy: Dictionary[Vector2i, OccupancyBlock] = { }


func setup(_columns: int, _rows: int) -> void:
	columns = _columns
	rows = _rows
	grid_occupancy.clear()
	for row in range(rows):
		for column in range(columns):
			grid_occupancy[Vector2i(column, row)] = null


func get_occupancy_at(coord: Vector2i) -> OccupancyBlock:
	return grid_occupancy.get(coord, null)


func is_unoccupied_at(card_stats: CardData, target_coords: Vector2i, ignore_card: CardData = null) -> bool:
	var shape: Array[Vector2i] = card_stats.grid_shape
	var target_occupancy: OccupancyBlock = get_occupancy_at(target_coords)

	if target_occupancy != null:
		if ignore_card != null and target_occupancy.card_reference != ignore_card:
			var occupying_card_stats: CardData = target_occupancy.card_reference
			if occupying_card_stats and occupying_card_stats.grid_shape == shape:
				return true

	for coords: Vector2i in shape:
		var check_pos: Vector2i = target_coords + coords

		if check_pos.x < 0 or check_pos.x >= columns or check_pos.y < 0 or check_pos.y >= rows:
			return false

		if not grid_occupancy.has(check_pos):
			return false

		var occupancy: OccupancyBlock = grid_occupancy[check_pos]
		if occupancy != null:
			if occupancy.card_reference == ignore_card:
				continue
			return false

	return true


func place_card(anchor_coord: Vector2i, card_stats: CardData) -> void:
	for cell: Vector2i in card_stats.grid_shape:
		var global_cell: Vector2i = anchor_coord + cell
		if global_cell.x < 0 or global_cell.x >= columns or global_cell.y < 0 or global_cell.y >= rows:
			continue

		var block: OccupancyBlock = OccupancyBlock.new()
		block.card_reference = card_stats
		block.local_offset = cell
		block.is_anchor = (cell == Vector2i(0, 0))
		grid_occupancy[global_cell] = block


func clear_card(anchor_coord: Vector2i, card_stats: CardData) -> void:
	for offset: Vector2i in card_stats.grid_shape:
		var global_cell: Vector2i = anchor_coord + offset
		if grid_occupancy.has(global_cell):
			grid_occupancy[global_cell] = null
