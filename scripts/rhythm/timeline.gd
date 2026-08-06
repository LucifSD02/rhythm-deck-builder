class_name Timeline
extends Resource

var cards: Array[CardBase]
var length_in_bars: int
var beats_per_bar: int
var starting_bar: int
var flattened_cells: Array[TimelineCell] = []
var coordinate_to_slot_map: Dictionary[Vector2i, CardSlot] = {}
var grid_occupancy: Dictionary[Vector2i, OccupancyBlock] = {}
