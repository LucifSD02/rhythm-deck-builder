class_name CardSlot
extends PanelContainer

var current_item: Card
var contains_other_card: bool = false
var timeline_id: int


func _ready() -> void:
	pass


# When a drag is started, save the item in a DragData object
func _get_drag_data(_at_position: Vector2) -> Variant:
	print("drag started")
	
	if current_item == null:
		print("no item here")
		return
	
	var drag_data: DragData = DragData.new(self, current_item)
	print("dragged item: ", self.current_item.stats.name)
	
	var preview: Card = current_item.duplicate()
	set_preview(preview, _at_position)
	return drag_data

func set_preview(preview: Card, _position: Vector2) -> void:
	var control: Control = Control.new()
	control.add_child(preview)
	preview.position = Vector2.ZERO - _position
	set_drag_preview(control)

# Check if item can be dropped
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is DragData

# Initiated when item is dropped
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var drag_data: DragData = data
	var origin_slot: CardSlot = drag_data.origin_slot
	var dragged_item: Card = drag_data.item_node
	
	# When dropped on itself, nothing happens
	if origin_slot == self:
		return
	
	if contains_other_card == true:
		print("This slot is taken by another card")
		return
	
	# If the drop location has an item
	if current_item != null:
		# Replace the ORIGIN'S Slot with the target item first
		replace_origin_with_target_card(current_item, origin_slot)
	else: #If the drop location is empty
		# Just set the origin slot to NULL
		origin_slot.current_item = null
	
	# Set the card in the target slot to the card in DragData
	set_target_slot_card(dragged_item, origin_slot)


func replace_origin_with_target_card(target: Card, origin: CardSlot) -> void:
	target.reparent(origin)
	origin.current_item = target


func set_target_slot_card(dragged_item: Card, origin: CardSlot) -> void:
	var parent: Control = get_parent()
	if parent.name != "Timeline":
		return
	if set_contains_other_card(dragged_item) == false:
		print("move failed, clashing cards")
		origin.current_item = dragged_item
		return
	dragged_item.reparent(self)
	current_item = dragged_item


func set_contains_other_card(dragged_item: Card) -> bool:
	var timeline_ui: TimelineUi = get_parent() as TimelineUi
	var stats: CardBase = dragged_item.stats
	var bars: int = stats.bar_amount
	var current_card_bar: int = timeline_id
	if bars == 1:
		return true
	for i in bars:
		if i == 0:
			continue
		var changed_card_slot: CardSlot = CardSlot.new()
		changed_card_slot = timeline_ui.get_slot_by_id(current_card_bar + i)
		if changed_card_slot.current_item != null:
			return false
		changed_card_slot.contains_other_card = true
	return true


func _on_child_entered_tree(node: Node) -> void:
	print("added child ", node)
	if get_child_count() > 0:
		var first_child: Node = get_child(0)
		if first_child is Card:
			current_item = first_child
