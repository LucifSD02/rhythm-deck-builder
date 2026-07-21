@icon("res://addons/at-icons/node/hammer.svg")
class_name SequenceCreator
extends Node

@onready var music_player: MusicPlayer = RhythmClock.music_player
@onready var timeline: Timeline
@onready var cards: Array[CardBase]
@onready var timeline_manager: TimelineManager = get_node("../TimelineManager")
var miss_check: float = 0
var all_notes: Array[NoteEvent] = []

signal check_missed_notes
signal key1_pressed
signal key2_pressed
signal key3_pressed
signal key4_pressed
signal key5_pressed
signal key6_pressed
signal key7_pressed
signal key8_pressed
signal rhythm_special_pressed


func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	miss_check += delta
	if miss_check > 0.5:
		emit_signal("check_missed_notes")
		miss_check = 0


func convert_to_sequence(_timeline: Timeline) -> void:
	all_notes = []
	timeline = _timeline
	cards = timeline.cards
	for i in range(cards.size() - 1, -1, -1):
		remove_silence_card(i)
	for i in range(cards.size()):
		var card: CardBase = cards[i]
		card.timeline_id = i
		gather_all_notes(card)
	create_all_notes() 

func remove_silence_card(index: int) -> void:
	var card: CardBase = cards[index]
	if card.name == "Silence":
		cards.remove_at(index)

func gather_all_notes(card: CardBase) -> void:
	var notes: Array[NoteEvent] = card.melody_notes
	for j in range(notes.size()):
		adjust_note_events(notes[j])
		notes[j].related_card_id = card.timeline_id
		all_notes.append(notes[j])

func create_all_notes() -> void:
	all_notes.sort_custom(func(a: NoteEvent, b: NoteEvent) -> bool: return a.time < b.time)
	for i in range(all_notes.size()):
		var note_event: NoteEvent = all_notes[i]
		var is_last: bool = (i == all_notes.size() - 1)
		var note: Note = create_note(note_event, note_event.related_card_id, is_last)


func adjust_note_events(_note: NoteEvent) -> void:
	var note_event: NoteEvent = _note
	note_event.time += timeline.starting_bar * timeline.beats_per_bar


func create_note(note_event: NoteEvent, card_id: int, is_last_note: bool) -> Note:
	var note_instance: Note = Note.new()
	var built_note: Note = note_instance.build_note(note_event, card_id, is_last_note)
	built_note.card_id = card_id
	built_note.set_label()
	connect_signals(built_note)
	add_child(built_note)
	move_child(built_note, 0 - int(built_note.note_event.time))
	return built_note


func connect_signals(note: Note) -> void:
	match_key_presses(note)
	connect("check_missed_notes", note.check_too_late)
	note.connect("note_hit", timeline_manager.log_note_hits)
	note.connect("last_note", timeline_manager.sequence_complete)


func match_key_presses(new_note: Note) -> void:
	var signal_name: String = new_note.note_event.action_to_hit + "_pressed"
	self.connect(signal_name, new_note.activate)


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	for i in range(1, 9):
		var action_name: String = "key" + str(i)
		if event.is_action_pressed(action_name, false):
			var signal_name: String = action_name + "_pressed"
			emit_signal(signal_name, RhythmClock.get_current_beat(true))
		if event.is_action_pressed("rhythm_special", false):
			emit_signal("rhythm_special_pressed", RhythmClock.get_current_beat(true))


func convert_to_sequence_old(timeline: Timeline) -> void:
	var running_timeline_bar: int = 0
	running_timeline_bar += (RhythmClock.get_current_bar() / 4) * 4

	for i in range(timeline.cards.size()):
		var card: CardBase = timeline.cards[i]
		card.timeline_id = i

		if card.bar_amount <= 0:
			push_error("Resource isse, Card ", card.card_name, "has a bar_amount of 0 or lower, defaulting to 1")
			card.bar_amount = 1

		for j in range(card.melody_notes.size()):
			var note_event: NoteEvent = card.melody_notes[j]
			if not note_event:
				push_error("Resource issue, Card ", card.card_name, " has a missing NoteEvent at index ", j)
				continue

			var is_last_note: bool = (i == timeline.cards.size() - 1) && (j == card.melody_notes.size() - 1)
			if is_last_note:
				create_note_old(note_event, running_timeline_bar, card.timeline_id, true)
				print("made last note")
			else:
				create_note_old(note_event, running_timeline_bar, card.timeline_id, false)

		running_timeline_bar += card.bar_amount

func create_note_old(note_event: NoteEvent, starting_bar: int, card_id: int, is_last_note: bool) -> Note:
	var note_instance: Note = Note.new()
	var built_note: Note = note_instance.build_note_old(note_event, starting_bar, card_id, is_last_note)
	built_note.set_label()
	match_key_presses(built_note)
	connect("check_missed_notes", built_note.check_too_late)
	built_note.connect("note_hit", timeline_manager.log_note_hits)
	built_note.connect("last_note", timeline_manager.sequence_complete)
	add_child(built_note)
	move_child(built_note, 0 - int(built_note.note_event.time))
	return built_note
