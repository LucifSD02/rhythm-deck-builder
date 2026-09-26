class_name PlacementGrid
extends RefCounted

var columns: int
var rows: int
var grid_occupancy: Dictionary[Vector2i, OccupancyBlock] = { }


func setup(p_columns: int, p_rows: int) -> void:
	columns = p_columns
	rows = p_rows
	grid_occupancy.clear()
	for row in range(rows):
		for column in range(columns):
			grid_occupancy[Vector2i(column, row)] = null


func get_occupancy_at(coord: Vector2i) -> OccupancyBlock:
	return grid_occupancy.get(coord, null)


func is_in_bounds(coord: Vector2i) -> bool:
	return coord.x >= 0 and coord.x < columns and coord.y >= 0 and coord.y < rows


func can_place_card_at(card_data: CardData, anchor_coord: Vector2i, ignore_card: CardData = null) -> bool:
	var shape: Array[Vector2i] = card_data.grid_shape
	var anchor_occupancy: OccupancyBlock = get_occupancy_at(anchor_coord)

	if anchor_occupancy != null:
		if ignore_card != null and anchor_occupancy.card_reference != ignore_card:
			var occupying_card: CardData = anchor_occupancy.card_reference
			if occupying_card and occupying_card.grid_shape == shape:
				return true

	for offset: Vector2i in shape:
		var global_cell: Vector2i = anchor_coord + offset

		if not is_in_bounds(global_cell):
			return false

		if not grid_occupancy.has(global_cell):
			return false

		var occupancy: OccupancyBlock = grid_occupancy[global_cell]
		if occupancy != null:
			if occupancy.card_reference == ignore_card:
				continue
			return false

	return true


func place_card(anchor_coord: Vector2i, card_data: CardData) -> void:
	for offset: Vector2i in card_data.grid_shape:
		var global_cell: Vector2i = anchor_coord + offset
		if not is_in_bounds(global_cell):
			continue

		var block: OccupancyBlock = OccupancyBlock.new()
		block.card_reference = card_data
		block.local_offset = offset
		block.is_anchor = (offset == Vector2i.ZERO)
		grid_occupancy[global_cell] = block


func clear_card(anchor_coord: Vector2i, card_data: CardData) -> void:
	for offset: Vector2i in card_data.grid_shape:
		var global_cell: Vector2i = anchor_coord + offset
		if grid_occupancy.has(global_cell):
			grid_occupancy[global_cell] = null
