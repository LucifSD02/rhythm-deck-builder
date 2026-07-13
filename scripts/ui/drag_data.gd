class_name DragData
extends RefCounted

var origin_slot: PanelContainer
var item_node: Label

func _init(p_origin_slot: PanelContainer, p_item_node: Label) -> void:
	origin_slot = p_origin_slot
	item_node = p_item_node
