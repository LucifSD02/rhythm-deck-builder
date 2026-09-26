@icon("res://addons/at-icons/node/note.svg")
class_name Note
extends Control

signal note_hit
signal last_note_reached
signal card_last_note_reached

const HIT_WINDOW_BEATS: float = 0.4
const MISS_AFTER_BEATS: float = 0.5
const NOTE_SCENE: PackedScene = preload("res://scenes/rhythm/note.tscn")

@export var is_last_note: bool
@export var is_last_note_of_card: bool
@export var note_event: NoteEvent

var card_id: int
var label: Label


func _process(_delta: float) -> void:
	position.y += 0.54


func on_miss_window_elapsed() -> void:
	var current_beat: float = RhythmClock.get_current_beat(false)
	if current_beat - note_event.time > MISS_AFTER_BEATS:
		finish(0)


func activate(hit_beat: float) -> void:
	var hit_deviation: float = hit_beat - note_event.time
	if abs(hit_deviation) > HIT_WINDOW_BEATS:
		return
	print("Hit: ", name, " | Target Beat: ", note_event.time, " | Deviation: ", hit_deviation)
	finish(get_hit_judgement(hit_deviation))


func finish(judgement: float) -> void:
	note_hit.emit(card_id, judgement)
	if is_last_note_of_card:
		card_last_note_reached.emit(card_id)
	if is_last_note:
		print("last note!")
		last_note_reached.emit()
	queue_free()


static func create(event: NoteEvent, source_card_id: int, is_last_in_sequence: bool) -> Note:
	var new_note: Note = NOTE_SCENE.instantiate()
	new_note.note_event = event.duplicate()
	new_note.card_id = source_card_id
	new_note.is_last_note = is_last_in_sequence
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


func set_label() -> void:
	label = $ColorRect/Label
	label.text = str(note_event.time) + ", " + str(note_event.action_to_hit)
	print("Spawned note: ", label.text)
