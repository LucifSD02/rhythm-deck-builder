@icon("res://addons/at-icons/control/dagger.svg")
extends Node

@onready var timeline_manager: TimelineManager = $TimelineManager
@onready var sequence_creator: SequenceCreator = $SequenceCreator
var timeline: Timeline

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_confirm_timeline_button_button_up() -> void:
	timeline = timeline_manager.construct_timeline()
	sequence_creator.convert_to_sequence(timeline)
