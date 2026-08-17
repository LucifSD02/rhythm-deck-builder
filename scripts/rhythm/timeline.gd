class_name Timeline
extends Resource

var cards: Array[CardData]
var length_in_bars: int
var beats_per_bar: int
var starting_bar: int
var columns: int
var flattened_cells: Array[TimelineCell] = []


func get_cell_at(coord: Vector2i) -> TimelineCell:
	if coord.x < 0 or coord.x >= columns:
		print("tried to get cell at out of bounds position: ", coord)
		return null
	var index: int = coord.y * columns + coord.x
	if index < 0 or index >= flattened_cells.size():
		print("tried to get cell at out of bounds index : ", index)
		return null
	return flattened_cells[index]
