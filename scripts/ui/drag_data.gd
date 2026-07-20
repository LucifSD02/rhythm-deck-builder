class_name DragData
extends RefCounted

var origin_slot: PanelContainer
var item_node: Card

func _init(_origin_slot: PanelContainer, _item_node: Card) -> void:
	origin_slot = _origin_slot
	item_node = _item_node
