class_name Note
extends Control

@onready var timeline_manager: TimelineManager = TimelineManager.new()
@export var card_id: int
@export var note_event: NoteEvent: 
	set(value): 
		note_event = value

signal note_hit

func _ready() -> void:
	connect("note_hit", timeline_manager.log_note_hits)
	print(note_event.time)

func activate(hit_beat: float) -> void:
	var hit_deviation = hit_beat - note_event.time - RhythmClock.manual_calibration_offset
	if abs(hit_deviation) > 0.40:
		return
	else:
		print("Hit: ", name, " | Target Beat: ", note_event.time, " | Deviation: ", hit_deviation)
		emit_signal("note_hit", card_id, get_hit_judgement(hit_deviation))
		queue_free()

func get_hit_judgement(hit_deviation: float) -> String:
	if hit_deviation < 0:
		hit_deviation = hit_deviation * -1
	if hit_deviation <= 0.05:
		return "Perfect"
	elif hit_deviation <= 0.12:
		return "Great"
	elif hit_deviation <= 0.22:
		return "Okay"
	else:
		return "Miss"
