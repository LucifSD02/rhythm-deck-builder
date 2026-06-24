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
	var running_timeline_bar: int = 0
	
	for i in range(timeline.cards.size()):
		var card = timeline.cards[i]
		card.timeline_id = i

		for j in range(card.melody_notes.size()):
			var note_event: NoteEvent = card.melody_notes[j]
			if not note_event:
				continue

			var is_last_note = (i == timeline.cards.size() - 1) && (j == card.melody_notes.size() - 1)
			if is_last_note:
				create_note(note_event, running_timeline_bar, card.timeline_id, true)
				print("made last note") 
			else:
				create_note(note_event, running_timeline_bar, card.timeline_id, false)

		running_timeline_bar += card.bar_amount



func create_note(note_event: NoteEvent, starting_bar: int, card_id, is_last_note) -> Note:
	var physical_manager: TimelineManager = get_node("../TimelineManager")
	var new_note: Note = note_blueprint.instantiate()
	new_note.connect("note_hit", physical_manager.log_note_hits)
	new_note.connect("last_note", physical_manager.sequence_complete)
	new_note.note_event = note_event.duplicate()
	var beat_time: int = int(new_note.note_event.time)
	#print(new_note.note_event.time)
	new_note.note_event.time = (4 * starting_bar) + beat_time
	print(new_note.note_event.time)
	new_note.card_id = card_id
	new_note.is_last_note = is_last_note
	add_child(new_note)
	match_key_presses(new_note)
	connect("check_missed_notes", new_note.check_too_late)
	#print(new_note)
	return new_note

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
