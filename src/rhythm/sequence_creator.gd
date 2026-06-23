class_name SequenceCreator
extends Node

@export var note_blueprint: PackedScene
@onready var music_player: MusicPlayer = RhythmClock.music_player
var miss_check: float = 0

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

func convert_to_sequence(timeline: Timeline):
	for i in range(timeline.cards.size()):
		var card = timeline.cards[i]
		card.starting_bar = i 
		card.timeline_id = i
		for note_event in card.melody_notes:
			create_note(note_event, card.starting_bar, card.timeline_id)

func create_note(note_event: NoteEvent, starting_bar: int, card_id) -> Note:
	var new_note: Note = note_blueprint.instantiate()
	new_note.note_event = note_event.duplicate()
	new_note.note_event.time += starting_bar * 4
	new_note.card_id = card_id
	add_child(new_note)
	match_key_presses(new_note)
	connect("check_missed_notes", new_note.check_too_late)
	print(new_note)
	return new_note

func check_missed():
	emit_signal("check_missed_notes")

func match_key_presses(new_note: Note):
	var signal_name: String = new_note.note_event.action_to_hit + "_pressed"
	self.connect(signal_name, new_note.activate)

func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	for i in range(1, 9):
		var action_name = "key" + str(i)
		if event.is_action_pressed(action_name, false):
			var signal_name = action_name + "_pressed"
			emit_signal(signal_name, RhythmClock.get_current_beat(true))
		if event.is_action_pressed("rhythm_special", false):
			emit_signal("rhythm_special_pressed", RhythmClock.get_current_beat(true))
