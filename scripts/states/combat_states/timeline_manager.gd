@icon("res://addons/at-icons/node/wrench.svg")
class_name TimelineManager
extends Node

@onready var sequence_creator: SequenceCreator = $"../SequenceCreator"
@onready var music_player: MusicPlayer = RhythmClock.music_player
@onready var beats_per_bar: int = music_player.time_signature()
@onready var timeline: Timeline


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func construct_timeline() -> Timeline:
	clear_timeline()
	timeline.starting_bar = RhythmClock.get_next_suitable_starting_bar(4)
	timeline.beats_per_bar = music_player.time_signature()
	timeline.length_in_bars = 8
	return timeline


func set_all_relative_note_event_timings() -> void:
	for i in range(timeline.cards.size()):
		var notes: Array[NoteEvent] = timeline.cards[i].melody_notes
		for note in notes:
			note.time += i * timeline.beats_per_bar


func clear_timeline() -> void:
	timeline = Timeline.new()
