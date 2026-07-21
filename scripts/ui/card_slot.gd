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
	if get_parent() is TimelineUi:
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

	var preview: Card = current_item.duplicate() as Card
	set_preview(preview, _at_position)
	
	# FIXED: Do NOT scrub variables or grids here! Just hide the item visually
	# so it stays safely anchored if the player aborts the drag move.
	current_item.visible = false
	
	return drag_data


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not data is DragData:
		return false
		
	var drag_data: DragData = data as DragData
	if not drag_data or not drag_data.item_node:
		return false
		
	# If we are testing a landing inside the Timeline, run shape calculations
	if get_parent() is TimelineUi and timeline_ui:
		var target_coord: Vector2i = Vector2i(column, row)
		
		# EXCEPTION RULE: If the card is testing its own starting position during an abort/re-drop,
		# ignore the collision so it is allowed to land back in its original home slot box!
		if drag_data.origin_slot == self:
			return true
			
		return timeline_ui.check_occupancy(drag_data.item_node.stats, target_coord, drag_data.origin_slot)
		
	return current_item == null


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var drag_data: DragData = data as DragData
	if not drag_data:
		return
		
	var dragged_item: Card = drag_data.item_node as Card
	var origin_slot: CardSlot = drag_data.origin_slot as CardSlot
	if not dragged_item or not origin_slot or origin_slot == self:
		return

	var target_coord: Vector2i = Vector2i(column, row)
	var origin_coord: Vector2i = Vector2i(origin_slot.column, origin_slot.row)
	
	# THE FIX: Dynamically identify the true container types at runtime!
	var target_parent: Node = get_parent()
	var origin_parent: Node = origin_slot.get_parent()
	
	var is_target_timeline: bool = target_parent is TimelineUi
	var is_origin_timeline: bool = origin_parent is TimelineUi

	# 1. Placement Validation Gate
	if is_target_timeline:
		var target_timeline: TimelineUi = target_parent as TimelineUi
		if not target_timeline.check_occupancy(dragged_item.stats, target_coord, origin_slot):
			print("Drop rejected: Matrix collision or boundary break.")
			return

	# 2. Clear Grid Matrix Ledgers Safely Using the True Parents
	if is_origin_timeline:
		var origin_timeline: TimelineUi = origin_parent as TimelineUi
		origin_timeline.clear_card_from_grid(origin_coord, dragged_item)
		
	if is_target_timeline and current_item:
		var target_timeline: TimelineUi = target_parent as TimelineUi
		target_timeline.clear_card_from_grid(target_coord, current_item)

	# 3. Cache the Target Card reference before isolating node trees
	var target_item: Card = current_item

	# 4. Physical Tree Detachment (Prevents frame-overlap glitches inside _on_child_entered_tree)
	origin_slot.remove_child(dragged_item)
	if target_item:
		remove_child(target_item)

	# 5. Execute Node Swapping Handshake
	if target_item:
		origin_slot.add_child(target_item)
		origin_slot.current_item = target_item
		if is_origin_timeline:
			var origin_timeline: TimelineUi = origin_parent as TimelineUi
			origin_timeline.place_card_in_grid(origin_coord, target_item)
	else:
		# If the slot was completely empty, safely scrub the old visual states
		origin_slot.clear_visual_state()
		origin_slot.current_item = null

	# 6. Finalize Landing Assignment
	add_child(dragged_item)
	current_item = dragged_item
	
	if is_target_timeline:
		var target_timeline: TimelineUi = target_parent as TimelineUi
		target_timeline.place_card_in_grid(target_coord, dragged_item)


func clear_visual_state() -> void:
	occupancy = null
	# REMOVED: current_item = null (Let _drop_data manage this reference swap!)
	self.mouse_filter = Control.MOUSE_FILTER_STOP

	self.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	self.modulate = Color(1.0, 1.0, 1.0, 1.0)
	self.mouse_filter = Control.MOUSE_FILTER_STOP


func set_preview(preview: Card, _position: Vector2) -> void:
	var control: Control = Control.new()
	control.add_child(preview)
	preview.position = Vector2.ZERO - _position
	set_drag_preview(control)


func set_target_slot_card(dragged_item: Card) -> void:
	dragged_item.reparent(self)
	current_item = dragged_item


func replace_origin_with_target_card(target: Card, origin: CardSlot) -> void:
	target.visible = true
	target.reparent(origin)
	origin.current_item = target


func display_card_visual(card: Card) -> void:
	card.reparent(self)
	current_item = card
	card.visible = true

	self.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	self.modulate = Color(1.0, 1.0, 1.0, 1.0)
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	print("Anchor slot locked at: ", column, ", ", row)


func convert_to_ghost_slot() -> void:
	self.self_modulate = Color(0.353, 0.353, 0.353, 0.596)
	self.modulate = Color(0.2, 0.5, 1.0, 0.3)
	self.mouse_filter = Control.MOUSE_FILTER_PASS

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		if current_item and not current_item.visible:
			current_item.visible = true
			if get_parent() is TimelineUi and timeline_ui:
				var current_coord: Vector2i = Vector2i(column, row)
				timeline_ui.place_card_in_grid(current_coord, current_item)


func _on_child_entered_tree(node: Node) -> void:
	if get_child_count() > 0:
		var first_child: Node = get_child(0)
		if first_child is Card:
			current_item = first_child
