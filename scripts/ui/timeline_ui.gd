class_name TimelineUi
extends GridContainer

const SLOT_SCENE: PackedScene = preload("res://scenes/cards/card_slot.tscn")
const CARD_SCENE: PackedScene = preload("res://scenes/cards/card.tscn")

@onready var player: Player = %Player

var coordinate_to_slot_map: Dictionary[Vector2i, CardSlot] = { }


func _ready() -> void:
	columns = Combatant.GRID_COLUMNS
	generate_grid(Combatant.GRID_COLUMNS * Combatant.GRID_ROWS)


func generate_grid(slot_count: int) -> void:
	coordinate_to_slot_map.clear()
	for i: int in range(slot_count):
		add_child(instantiate_slot(i))


func instantiate_slot(i: int) -> CardSlot:
	var slot_instance: CardSlot = SLOT_SCENE.instantiate() as CardSlot
	slot_instance.accessibility_name = "slot " + str(i)
	slot_instance.timeline_id = i
	slot_instance.column = i % Combatant.GRID_COLUMNS
	@warning_ignore("integer_division")
	slot_instance.row = i / Combatant.GRID_COLUMNS

	coordinate_to_slot_map[Vector2i(slot_instance.column, slot_instance.row)] = slot_instance
	return slot_instance


func is_unoccupied_at(card_stats: CardBase, target_coords: Vector2i, origin_slot: CardSlot) -> bool:
	var ignore_card: CardBase = null
	if origin_slot and origin_slot.current_item:
		ignore_card = origin_slot.current_item.card_base
	return player.placement_grid.is_unoccupied_at(card_stats, target_coords, ignore_card)


func place_card_in_grid(anchor_coord: Vector2i, card: Card) -> void:
	player.placement_grid.place_card(anchor_coord, card.card_base)
	for cell: Vector2i in card.card_base.grid_shape:
		var global_cell: Vector2i = anchor_coord + cell
		var physical_slot: CardSlot = get_slot_at_coord(global_cell)
		if physical_slot:
			physical_slot.occupancy = player.placement_grid.get_occupancy_at(global_cell)
			if physical_slot.occupancy.is_anchor:
				physical_slot.display_card_visual(card)
			else:
				physical_slot.convert_to_ghost_slot()


func clear_card_from_grid(anchor_coord: Vector2i, card: Card) -> void:
	player.placement_grid.clear_card(anchor_coord, card.card_base)
	for offset: Vector2i in card.card_base.grid_shape:
		var physical_slot: CardSlot = get_slot_at_coord(anchor_coord + offset)
		if physical_slot:
			physical_slot.clear_visual_state()


func clear_timeline() -> void:
	for i in range(get_child_count() - 1, -1, -1):
		get_child(i).free()
	generate_grid(Combatant.GRID_COLUMNS * Combatant.GRID_ROWS)

func get_slot_at_coord(coordinate: Vector2i) -> CardSlot:
	if coordinate_to_slot_map.has(coordinate):
		return coordinate_to_slot_map[coordinate]
	return null
