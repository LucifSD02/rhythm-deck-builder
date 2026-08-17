class_name CombatantBase
extends Node

const GRID_COLUMNS: int = 4
const GRID_ROWS: int = 2
const TIMELINE_LENGTH_IN_BARS: int = 8
const SILENCE: Resource = preload("uid://d1ykg17wc4e62")

var instrument: InstrumentBase
var card_inventory: Array[CardData] = []
var armour: int
var stagger_threshold: int
var status_effects: Array = [] # TODO: needs its own design pass
var max_energy: int
var current_energy: int
var placement_grid: PlacementGrid = PlacementGrid.new()


func _ready() -> void:
	reset_grid()


func reset_grid() -> void:
	placement_grid.setup(GRID_COLUMNS, GRID_ROWS)


func populate_inventory_from(source: Array[CardData]) -> void:
	card_inventory = source.duplicate()


func can_afford(card_data: CardData) -> bool:
	return current_energy >= card_data.energy_cost


func spend_energy(card_data: CardData) -> void:
	current_energy -= card_data.energy_cost


func reset_energy() -> void:
	current_energy = max_energy


func build_timeline(starting_bar: int) -> Timeline:
	var timeline: Timeline = Timeline.new()
	timeline.columns = GRID_COLUMNS
	timeline.length_in_bars = TIMELINE_LENGTH_IN_BARS
	timeline.beats_per_bar = RhythmClock.music_player.time_signature()
	timeline.starting_bar = starting_bar
	populate_cells(timeline)
	apply_relative_note_timings(timeline)
	return timeline


func populate_cells(timeline: Timeline) -> void:
	var placement_cards: Dictionary[Vector2i, CardData] = { }
	var cards_array: Array[CardData] = []
	var cells_array: Array[TimelineCell] = []

	for row: int in range(GRID_ROWS):
		for column: int in range(GRID_COLUMNS):
			var coord: Vector2i = Vector2i(column, row)
			var occupancy_block: OccupancyBlock = placement_grid.get_occupancy_at(coord)
			var timeline_cell: TimelineCell = TimelineCell.new()
			timeline_cell.column = column
			timeline_cell.row = row

			if occupancy_block != null and occupancy_block.card_reference != null:
				var anchor_coord: Vector2i = coord - occupancy_block.local_offset
				if not placement_cards.has(anchor_coord):
					placement_cards[anchor_coord] = occupancy_block.card_reference.duplicate(true) as CardData
				timeline_cell.card_reference = placement_cards[anchor_coord]
				timeline_cell.is_anchor = occupancy_block.is_anchor
				timeline_cell.local_offset = occupancy_block.local_offset
			else:
				timeline_cell.card_reference = SILENCE.duplicate(true) as CardData
				timeline_cell.is_anchor = true
				timeline_cell.local_offset = Vector2i.ZERO

			cells_array.append(timeline_cell)
			if timeline_cell.is_anchor and timeline_cell.card_reference.name != "Silence":
				cards_array.append(timeline_cell.card_reference)

	timeline.cards = cards_array
	timeline.flattened_cells = cells_array


func apply_relative_note_timings(timeline: Timeline) -> void:
	for i in range(timeline.flattened_cells.size()):
		var cell: TimelineCell = timeline.flattened_cells[i]
		if not cell.is_anchor:
			continue
		for note in cell.card_reference.melody_notes:
			note.time += i * timeline.beats_per_bar
			print("cell ", i, " -> ", cell.card_reference.name, " id ", cell.card_reference.get_instance_id())
