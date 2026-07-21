class_name TimelineUi
extends GridContainer

@export var rows: int = 2

const SLOT_SCENE: PackedScene = preload("res://scenes/cards/card_slot.tscn")
const CARD_SCENE: PackedScene = preload("res://scenes/cards/card.tscn")
const SILENCE = preload("uid://d1ykg17wc4e62")

var coordinate_to_slot_map: Dictionary[Vector2i, CardSlot] = {}
var grid_occupancy: Dictionary[Vector2i, OccupancyBlock] = {}


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


func place_card_in_grid(anchor_coord: Vector2i, card: Card) -> void:
	for cell in card.stats.grid_shape:
		var global_cell: Vector2i = anchor_coord + cell
		
		# Boundary safety check to completely prevent unmapped dictionary insertions
		if global_cell.x < 0 or global_cell.x >= 4 or global_cell.y < 0 or global_cell.y >= rows:
			push_error("Attempted to assign occupancy out of grid limits at: ", global_cell)
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
	for offset in card.stats.grid_shape:
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
	var cards: Array[CardBase] = []
	for child_index in range(get_child_count()):
		var child_card_slot: CardSlot = get_child(child_index) as CardSlot
		if not child_card_slot:
			continue
			
		if child_card_slot.get_child_count() == 0:
			cards.append(SILENCE)
			continue
			
		var child_card: Card = child_card_slot.get_child(0) as Card
		if child_card == null:
			continue
			
		cards.append(child_card.stats.duplicate(true))
	return cards


func get_slot_by_id(id: int) -> CardSlot:
	var slots: Array[Node] = get_children()
	for slot in slots:
		var card_slot: CardSlot = slot
		if card_slot and card_slot.timeline_id == id:
			return card_slot
	return null
