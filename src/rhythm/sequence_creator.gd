class_name SequenceCreator
extends Node

@onready var test_melody_card: CardBase = ResourceLoader.load("res://data/cards/test_strike.tres")
@export var note_blueprint: PackedScene = ResourceLoader.load("res://src/rhythm/note.tscn")

signal key1_pressed
signal key2_pressed
signal key3_pressed
signal key4_pressed
signal key5_pressed
signal key6_pressed
signal key7_pressed
signal key8_pressed
signal rhythm_special_pressed
var note_events: Array[NoteEvent]

func _ready() -> void:
	for event in test_melody_card.melody_notes:
		note_events.append(event)
		var new_note: Note = create_note(event)
		print(event)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_note(note_event: NoteEvent) -> Note:
	var new_note: Note = note_blueprint.instantiate()
	new_note.note_event = note_event
	get_tree().current_scene.add_child.call_deferred(new_note)
	match_key_presses(new_note)
	print(new_note)
	return new_note


func match_key_presses(new_note: Note):
	match new_note.note_event:
		"key1": 
			self.connect("key1_pressed", new_note.activate)
		"key2": 
			self.connect("key2_pressed", new_note.activate)
		"key3": 
			self.connect("key3_pressed", new_note.activate)
		"key4": 
			self.connect("key4_pressed", new_note.activate)
		"key5": 
			self.connect("key5_pressed", new_note.activate)
		"key6": 
			self.connect("key6_pressed", new_note.activate)
		"key7": 
			self.connect("key7_pressed", new_note.activate)
		"key8": 
			self.connect("key8_pressed", new_note.activate)
		"rhythm_special": 
			self.connect("rhythm_special_pressed", new_note.activate)
			

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
