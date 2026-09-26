@icon("res://addons/at-icons/node/hammer.svg")
class_name SequenceCreator
extends Node

signal miss_window_elapsed
signal key1_pressed
signal key2_pressed
signal key3_pressed
signal key4_pressed
signal key5_pressed
signal key6_pressed
signal key7_pressed
signal key8_pressed
signal rhythm_special_pressed

const MISS_CHECK_INTERVAL_SECONDS: float = 0.5

var miss_check_timer: float = 0
var all_notes: Array[NoteEvent] = []
var timeline: Timeline
var cards: Array[CardData]

@onready var rhythm_state: StateBase = %RhythmState


func _process(delta: float) -> void:
	miss_check_timer += delta
	if miss_check_timer > MISS_CHECK_INTERVAL_SECONDS:
		miss_window_elapsed.emit()
		miss_check_timer = 0


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	for i in range(1, 9):
		var action_name: String = "key" + str(i)
		if event.is_action_pressed(action_name, false):
			var signal_name: String = action_name + "_pressed"
			emit_signal(signal_name, RhythmClock.get_current_beat(true))
	if event.is_action_pressed("rhythm_special", false):
		rhythm_special_pressed.emit(RhythmClock.get_current_beat(true))


func convert_to_sequence(p_timeline: Timeline, is_enemy_sequence: bool) -> void:
	all_notes = []
	timeline = p_timeline
	cards = timeline.cards
	for i in range(cards.size()):
		var card_data: CardData = cards[i]
		card_data.timeline_id = i
		gather_all_notes(card_data)
	spawn_all_notes(is_enemy_sequence)


func gather_all_notes(card_data: CardData) -> void:
	var notes: Array[NoteEvent] = card_data.melody_notes
	for j in range(notes.size()):
		apply_starting_offset(notes[j])
		notes[j].related_card_id = card_data.timeline_id
		if j == notes.size() - 1:
			notes[j].is_last_note_of_card = true
		all_notes.append(notes[j])


func spawn_all_notes(is_enemy_sequence: bool) -> void:
	print("sequencing: starting_beat is ", timeline.starting_beat, ", current beat ", RhythmClock.get_current_beat(false))
	all_notes.sort_custom(func(a: NoteEvent, b: NoteEvent) -> bool: return a.time < b.time)
	var current_beat: float = RhythmClock.get_current_beat(false)
	var notes_offset: float = timeline.starting_beat - current_beat
	for i in range(all_notes.size()):
		var note_event: NoteEvent = all_notes[i]
		var is_last: bool = (i == all_notes.size() - 1)
		var note: Note = spawn_note(note_event, note_event.related_card_id, is_last, is_enemy_sequence)
		@warning_ignore("integer_division")
		note.position.y = ((note_event.time + notes_offset) * -75) + (1250 * timeline.starting_beat / 16)
		if is_enemy_sequence:
			note.label.text += " - enemy"
			note.position.x += 200


func apply_starting_offset(note_event: NoteEvent) -> void:
	note_event.time += timeline.starting_beat


func spawn_note(note_event: NoteEvent, card_id: int, is_last_note: bool, is_enemy_sequence: bool) -> Note:
	var note: Note = Note.create(note_event, card_id, is_last_note)
	note.is_last_note_of_card = note_event.is_last_note_of_card
	note.set_label()
	if is_last_note:
		print("made last note: ", note.note_event.time)
	connect_signals(note, is_enemy_sequence)
	add_child(note)
	return note


func connect_signals(note: Note, is_enemy_sequence: bool) -> void:
	if not is_enemy_sequence:
		match_key_presses(note)
		miss_window_elapsed.connect(note.on_miss_window_elapsed)
		note.note_hit.connect(rhythm_state.on_note_hit)
	note.last_note_reached.connect(rhythm_state.on_last_note_reached)
	note.card_last_note_reached.connect(rhythm_state.on_card_last_note_reached)


func match_key_presses(new_note: Note) -> void:
	var signal_name: String = new_note.note_event.action_to_hit + "_pressed"
	connect(signal_name, new_note.activate)
