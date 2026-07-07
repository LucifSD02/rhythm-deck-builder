class_name Note
extends Control

@export var card_id: int
@export var is_last_note: bool
@export var note_blueprint: PackedScene = preload("res://src/rhythm/note.tscn")
@export var note_event: NoteEvent

signal note_hit
signal last_note

func _ready() -> void:
	pass
	#print(note_event.time)

func check_too_late() -> void:
	var current_beat: float = RhythmClock.get_current_beat(false)
	if note_event.time - current_beat < -0.5:
		emit_signal("note_hit", card_id, 0)
		if is_last_note:
			print("last note!")
			emit_signal("last_note")
		queue_free() 

func activate(hit_beat: float) -> void:
	var hit_deviation: float = hit_beat - note_event.time - RhythmClock.manual_calibration_offset
	if abs(hit_deviation) > 0.40:
		return
	else:
		print("Hit: ", name, " | Target Beat: ", note_event.time, " | Deviation: ", hit_deviation)
		emit_signal("note_hit", card_id, get_hit_judgement(hit_deviation))
		if is_last_note:
			print("last note!")
			emit_signal("last_note")
		queue_free()

func build_note(event: NoteEvent, starting_bar: int, _card_id: int, _is_last_note: bool) -> Note:
	var new_note: Note = note_blueprint.instantiate()
	new_note.note_event = event.duplicate()
	var beat_time: int = int(new_note.note_event.time)
	new_note.note_event.time = (4 * starting_bar) + beat_time
	print(new_note.note_event.time)
	new_note.card_id = _card_id
	new_note.is_last_note = _is_last_note
	return new_note

func get_hit_judgement(hit_deviation: float) -> float:
	hit_deviation = abs(hit_deviation)
	if hit_deviation <= 0.0258:
		return 1
	elif hit_deviation <= 0.0600:
		return 0.75
	elif hit_deviation <= 0.1100:
		return 0.5
	elif hit_deviation <= 0.1800:
		return 0.25
	else:
		return 0
