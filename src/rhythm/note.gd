class_name Note
extends Control

@export var note_event: NoteEvent: 
	set(value): 
		note_event = value
	

func _ready() -> void:
	print(note_event.time)

func activate(hit_beat: float) -> void:
	var hit_deviation = hit_beat - note_event.time
	if abs(hit_deviation) > 0.40:
		return
	else:
		print("Hit: ", name, " | Target Beat: ", note_event.time, " | Deviation: ", hit_deviation, " ", get_hit_judgement(hit_deviation))
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
