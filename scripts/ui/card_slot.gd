class_name CardSlot
extends PanelContainer

var timeline_ui: TimelineUi
var current_item: Card
var contains_other_card: bool = false
var timeline_id: int
var column: int
var row: int
var occupancy: OccupancyBlock = null


func _ready() -> void:
	timeline_ui = get_parent() as TimelineUi


func is_occupied() -> OccupancyBlock:
	return occupancy


func _get_drag_data(_at_position: Vector2) -> Variant:
	print("drag started")

	if current_item == null:
		print("no item here")
		return null

	var drag_data: DragData = DragData.new(self, current_item)
	print("dragged item: ", self.current_item.stats.name)

	var preview: Card = current_item.duplicate()
	var current_coord: Vector2i = Vector2i(column, row)

	# Safe type verification handles the removal loop without fragile string-name matching
	if get_parent() is TimelineUi:
		timeline_ui.clear_card_from_grid(current_coord, current_item)

	set_preview(preview, _at_position)
	clear_visual_state()
	return drag_data


func set_preview(preview: Card, _position: Vector2) -> void:
	var control: Control = Control.new()
	control.add_child(preview)
	preview.position = Vector2.ZERO - _position
	set_drag_preview(control)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is DragData


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var drag_data: DragData = data
	var dragged_item: Card = drag_data.item_node
	var target_coord: Vector2i = Vector2i(column, row)
	var origin_slot: CardSlot = drag_data.origin_slot

	if origin_slot == self:
		return
	
	if check_occupancy(dragged_item.stats, target_coord) == false:
		return
	# If the drop location has an item
	if current_item != null:
		# Replace the ORIGIN'S Slot with the target item first
		replace_origin_with_target_card(current_item, origin_slot)
	else: #If the drop location is empty
		# Just set the origin slot to NULL
		origin_slot.current_item = null

	# Set the card in the target slot to the card in DragData
	set_target_slot_card(dragged_item)

	if get_parent() is TimelineUi:
		timeline_ui.place_card_in_grid(target_coord, dragged_item)


func set_target_slot_card(dragged_item: Card) -> void:
	dragged_item.reparent(self)
	current_item = dragged_item


func replace_origin_with_target_card(target: Card, origin: CardSlot) -> void:
	target.reparent(origin)
	origin.current_item = target


func clear_visual_state() -> void:
	occupancy = null
	self.mouse_filter = Control.MOUSE_FILTER_STOP


func check_occupancy(card_stats: CardBase, target_coords: Vector2i) -> bool:
	var shape: Array[Vector2i] = card_stats.grid_shape



	for coords in shape:
		var check_pos: Vector2i = target_coords + coords

		# 4x2 matrix guard rail check (4 columns, 2 rows)
		if check_pos.x < 0 or check_pos.x >= 4 or check_pos.y < 0 or check_pos.y >= 2:
			return false
		var slot: CardSlot = timeline_ui.get_slot_at_coord(check_pos)
		# Reject placement if the target block cell is occupied by any card element

		if slot == null or slot.occupancy != null:
			print("collision detected at: ", check_pos)
			return false

	print("no collisions")
	return true


func display_card_visual(card: Card) -> void:
	card.reparent(self)
	current_item = card

	# Restore standard alpha mouse tracking parameters on the target anchor panel box
	self.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	self.modulate = Color(1.0, 1.0, 1.0, 1.0)
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	print("Anchor slot locked at: ", column, ", ", row)


func convert_to_ghost_slot() -> void:
	# Hide panel borders completely so multi-slot graphics span downward uninterrupted
	self.self_modulate = Color(0.353, 0.353, 0.353, 0.596)
	self.modulate = Color(0.2, 0.5, 1.0, 0.3)

	# Pass clicks straight through the ghost space to hit the card floating over it
	self.mouse_filter = Control.MOUSE_FILTER_PASS


func _on_child_entered_tree(node: Node) -> void:
	print("added child ", node)
	if get_child_count() > 0:
		var first_child: Node = get_child(0)
		if first_child is Card:
			current_item = first_child
