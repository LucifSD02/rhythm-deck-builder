extends Node

const TEST_RUN = preload("uid://bd6kdl3txpog2")

var data: RunData = RunData.new()

func _ready() -> void:
	pass

func get_run() -> RunData:
	data = TEST_RUN
	return data
