class_name TimelineUi
extends GridContainer

@export var rows: int = 2

const SLOT_SCENE: PackedScene = preload("res://scenes/cards/card_slot.tscn")
const CARD_SCENE: PackedScene = preload("res://scenes/cards/card.tscn")
const SILENCE: Resource = preload("uid://d1ykg17wc4e62")

var coordinate_to_slot_map: Dictionary[Vector2i, CardSlot] = { }
var grid_occupancy: Dictionary[Vector2i, OccupancyBlock] = { }


func _ready() -> void:
	columns = 4
	generate_grid(8)


func generate_grid(slot_count: int) -> void:
	coordinate_to_slot_map.clear()
	grid_occupancy.clear()
	for i: int in range(slot_count):
		add_child(instantiate_slot(i))


func instantiate_slot(i: int) -> CardSlot:
	var slot_instance: CardSlot = SLOT_SCENE.instantiate() as CardSlot
	slot_instance.accessibility_name = "slot " + str(i)
	slot_instance.timeline_id = i
	slot_instance.column = i % 4
	slot_instance.row = i / 4

	var coord: Vector2i = Vector2i(slot_instance.column, slot_instance.row)
	coordinate_to_slot_map[coord] = slot_instance
	grid_occupancy[coord] = null
	return slot_instance


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	# Purely tests the data type payload as intended by the engine. Zero processing here.
	return data is DragData


func find_hovered_slot(local_mouse_pos: Vector2) -> CardSlot:
	for slot: CardSlot in coordinate_to_slot_map.values():
		if slot.get_rect().has_point(local_mouse_pos):
			return slot
	return null


func check_occupancy(card_stats: CardBase, target_coords: Vector2i, origin_slot: CardSlot) -> bool:
	var shape: Array[Vector2i] = card_stats.grid_shape
	var target_slot: CardSlot = get_slot_at_coord(target_coords)


	if target_slot and target_slot.occupancy != null:
		if not origin_slot or target_slot.occupancy.card_reference != origin_slot.current_item:
			var occupying_card_stats: CardBase = target_slot.occupancy.card_reference.stats
			if occupying_card_stats and occupying_card_stats.grid_shape == shape:
				return true

	for coords: Vector2i in shape:
		var check_pos: Vector2i = target_coords + coords

		if check_pos.x < 0 or check_pos.x >= 4 or check_pos.y < 0 or check_pos.y >= 2:
			return false

		var slot: CardSlot = get_slot_at_coord(check_pos)
		if slot == null:
			return false

		if slot.occupancy != null:
			if origin_slot and slot.occupancy.card_reference == origin_slot.current_item:
				continue
			return false

	return true


func set_target_slot_card(dragged_item: Card, target_slot: CardSlot) -> void:
	dragged_item.reparent(target_slot)
	target_slot.current_item = dragged_item


func replace_origin_with_target_card(target: Card, origin: CardSlot) -> void:
	target.reparent(origin)
	origin.current_item = target


func place_card_in_grid(anchor_coord: Vector2i, card: Card) -> void:
	for cell: Vector2i in card.stats.grid_shape:
		var global_cell: Vector2i = anchor_coord + cell

		if global_cell.x < 0 or global_cell.x >= 4 or global_cell.y < 0 or global_cell.y >= rows:
			continue

		var block: OccupancyBlock = OccupancyBlock.new()
		block.card_reference = card
		block.local_offset = cell
		block.is_anchor = (cell == Vector2i(0, 0))
		grid_occupancy[global_cell] = block

		var physical_slot: CardSlot = get_slot_at_coord(global_cell)
		if physical_slot:
			physical_slot.occupancy = block
			if block.is_anchor:
				physical_slot.display_card_visual(card)
			else:
				physical_slot.convert_to_ghost_slot()


func clear_card_from_grid(anchor_coord: Vector2i, card: Card) -> void:
	for offset: Vector2i in card.stats.grid_shape:
		var global_cell: Vector2i = anchor_coord + offset

		if grid_occupancy.has(global_cell):
			grid_occupancy[global_cell] = null

		var physical_slot: CardSlot = get_slot_at_coord(global_cell)
		if physical_slot:
			physical_slot.clear_visual_state()


func get_slot_at_coord(coordinate: Vector2i) -> CardSlot:
	if coordinate_to_slot_map.has(coordinate):
		return coordinate_to_slot_map[coordinate]
	return null


func get_cards_from_timeline_ui() -> Array[CardBase]:
	var cards_array: Array[CardBase] = []
	for child_index: int in range(get_child_count()):
		var child_card_slot: CardSlot = get_child(child_index) as CardSlot
		if not child_card_slot:
			continue

		if child_card_slot.get_child_count() == 0:
			cards_array.append(SILENCE as CardBase)
			continue

		var child_card: Card = child_card_slot.get_child(0) as Card
		if child_card == null:
			continue

		cards_array.append(child_card.stats.duplicate(true) as CardBase)
	return cards_array


func get_slot_by_id(id: int) -> CardSlot:
	var slots: Array[Node] = get_children()
	for slot: Node in slots:
		var card_slot: CardSlot = slot as CardSlot
		if card_slot and card_slot.timeline_id == id:
			return card_slot
	return null
