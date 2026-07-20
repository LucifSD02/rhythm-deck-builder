class_name DragData
extends RefCounted

var origin_slot: PanelContainer
var item_node: Card

func _init(p_origin_slot: PanelContainer, p_item_node: Card) -> void:
	origin_slot = p_origin_slot
	item_node = p_item_node
