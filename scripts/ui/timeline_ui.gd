class_name TimelineUi
extends GridContainer

@export var rows: int = 2

const SLOT_SCENE: PackedScene = preload("res://scenes/cards/card_slot.tscn")
const CARD_SCENE: PackedScene = preload("res://scenes/cards/card.tscn")
const SILENCE: Resource = preload("uid://d1ykg17wc4e62")

var coordinate_to_slot_map: Dictionary[Vector2i, CardSlot] = { }
var placement_grid: PlacementGrid = PlacementGrid.new()


func _ready() -> void:
	columns = 4
	generate_grid(8)


func generate_grid(slot_count: int) -> void:
	coordinate_to_slot_map.clear()
	placement_grid.setup(columns, rows)
	for i: int in range(slot_count):
		add_child(instantiate_slot(i))


func instantiate_slot(i: int) -> CardSlot:
	var slot_instance: CardSlot = SLOT_SCENE.instantiate() as CardSlot
	slot_instance.accessibility_name = "slot " + str(i)
	slot_instance.timeline_id = i
	slot_instance.column = i % 4
	@warning_ignore("integer_division")
	slot_instance.row = i / 4

	var coord: Vector2i = Vector2i(slot_instance.column, slot_instance.row)
	coordinate_to_slot_map[coord] = slot_instance
	return slot_instance


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is DragData


func find_hovered_slot(local_mouse_pos: Vector2) -> CardSlot:
	for slot: CardSlot in coordinate_to_slot_map.values():
		if slot.get_rect().has_point(local_mouse_pos):
			return slot
	return null


func is_unoccupied_at(card_stats: CardBase, target_coords: Vector2i, origin_slot: CardSlot) -> bool:
	var ignore_card: CardBase = null
	if origin_slot and origin_slot.current_item:
		ignore_card = origin_slot.current_item.card_base
	return placement_grid.is_unoccupied_at(card_stats, target_coords, ignore_card)


func set_target_slot_card(dragged_item: Card, target_slot: CardSlot) -> void:
	dragged_item.reparent(target_slot)
	target_slot.current_item = dragged_item


func replace_origin_with_target_card(target: Card, origin: CardSlot) -> void:
	target.reparent(origin)
	origin.current_item = target


func place_card_in_grid(anchor_coord: Vector2i, card: Card) -> void:
	placement_grid.place_card(anchor_coord, card.card_base)
	for cell: Vector2i in card.card_base.grid_shape:
		var global_cell: Vector2i = anchor_coord + cell
		var physical_slot: CardSlot = get_slot_at_coord(global_cell)
		if physical_slot:
			physical_slot.occupancy = placement_grid.get_occupancy_at(global_cell)
			if physical_slot.occupancy.is_anchor:
				physical_slot.display_card_visual(card)
			else:
				physical_slot.convert_to_ghost_slot()


func clear_card_from_grid(anchor_coord: Vector2i, card: Card) -> void:
	placement_grid.clear_card(anchor_coord, card.card_base)
	for offset: Vector2i in card.card_base.grid_shape:
		var global_cell: Vector2i = anchor_coord + offset
		var physical_slot: CardSlot = get_slot_at_coord(global_cell)
		if physical_slot:
			physical_slot.clear_visual_state()


func get_slot_at_coord(coordinate: Vector2i) -> CardSlot:
	if coordinate_to_slot_map.has(coordinate):
		return coordinate_to_slot_map[coordinate]
	return null

func populate_timeline_from_grid(timeline: Timeline) -> void:
	timeline.columns = columns
	var duplicated_cards: Dictionary[CardBase, CardBase] = {}
	var cards_array: Array[CardBase] = []
	var cells_array: Array[TimelineCell] = []

	for row: int in range(rows):
		for column: int in range(columns):
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


func get_slot_by_id(id: int) -> CardSlot:
	var slots: Array[Node] = get_children()
	for slot: Node in slots:
		var card_slot: CardSlot = slot as CardSlot
		if card_slot and card_slot.timeline_id == id:
			return card_slot
	return null


func clear_timeline() -> void:
	var child_count: int =  self.get_child_count() 
	var last_child_index: int = child_count - 1
	for i in range(last_child_index, -1, -1):
		var slot: CardSlot = self.get_child(i)
		slot.free()
	generate_grid(8)
