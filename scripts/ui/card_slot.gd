extends PanelContainer

var current_item: Card

func _ready() -> void:
	pass

func _get_drag_data(_at_position: Vector2) -> Variant:
	print("drag started")
	
	if not current_item:
		print("no item here")
		return
	
	var data: DragData = DragData.new(self, current_item)
	print("dragged item: ", self.current_item.stats.name, ", origin slot: ", accessibility_name)
	var preview: Card = current_item.duplicate()
	preview.custom_maximum_size = current_item.size
	preview.position = -size / 2
	set_drag_preview(preview)
	return data

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is DragData

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var drag_data: DragData = data
	var origin_slot: PanelContainer = drag_data.origin_slot
	var dragged_item: Card = drag_data.item_node
	
	if origin_slot == self:
		return

	if current_item != null:
		var target_item: Card = current_item
		target_item.reparent(origin_slot)
		origin_slot.current_item = target_item
	else:
		origin_slot.current_item = null

	dragged_item.reparent(self)
	current_item = dragged_item

func _on_child_entered_tree(node: Node) -> void:
	print("added child ", node)
	if get_child_count() > 0:
		var first_child: Node = get_child(0)
		if first_child is Card:
			current_item = first_child
