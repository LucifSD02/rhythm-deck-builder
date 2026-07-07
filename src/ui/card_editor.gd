extends Control

var card_resource_files: Array[Resource]
@onready var loaded_cards: Array[CardBase] = load_all_cards()
var card_index: int
var keys: Array[String] = ["key1", "key2", "key3", "key4", "key5", "key6", "key7", "key8"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for key in keys:
		$KeysDropdown.add_item(key)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_existing_card_dropdown_item_selected(index: int) -> void:
	print(loaded_cards[index].card_name)
	$CardNameBox.text = loaded_cards[index].card_name
	$KeysSpinBox.value = loaded_cards[index].key_amount
	$BarsSpinBox.value = loaded_cards[index].bar_amount
	card_index = index
	populate_rich_text_label()


func load_all_cards() -> Array[CardBase]:
	$ExistingCardDropdown.clear()
	card_resource_files = Utilities.load_resources_in_folder("res://data/cards/")
	var all_cards: Array[CardBase] = []
	for file in range(card_resource_files.size()):
		var loaded_card: CardBase = card_resource_files[file]
		$ExistingCardDropdown.add_item(loaded_card.card_name)
		all_cards.append(loaded_card)
	return all_cards


func populate_rich_text_label() -> void:
	$NoteEventList.clear()
	var current_beat: float = 0
	var loaded_card: CardBase = loaded_cards[card_index]
	var melody_notes: Array[NoteEvent] = loaded_card.melody_notes
	melody_notes.sort_custom(func(a: NoteEvent, b: NoteEvent) -> bool: return a.time < b.time)
	loaded_card.melody_notes = melody_notes
	for note_index in range(melody_notes.size()):
		var note: NoteEvent = melody_notes[note_index]
		var new_line: String = str(note.time) + " " + note.action_to_hit + "| "
		if current_beat != note.time:
			$NoteEventList.newline()
			current_beat = note.time
		$NoteEventList.append_text(new_line)


func _on_add_note_event_button_button_down() -> void:
	var loaded_card: CardBase = loaded_cards[card_index]
	var note_event_key: String = $KeysDropdown.text
	$KeysDropdown/BeatSpinBox.apply()
	var note_event_beat: int = $KeysDropdown/BeatSpinBox.value
	var melody_notes: Array[NoteEvent] = loaded_card.melody_notes
	var new_note_event: NoteEvent = NoteEvent.new()
	new_note_event.time = note_event_beat
	new_note_event.action_to_hit = note_event_key
	melody_notes.append(new_note_event)
	melody_notes.sort_custom(func(a: NoteEvent, b: NoteEvent) -> bool: return a.time < b.time)
	loaded_card.melody_notes = melody_notes
	populate_rich_text_label()


func _on_save_card_button_button_down() -> void:
	var card_to_save: CardBase = loaded_cards[card_index]
	$CardNameBox.apply_ime()
	$KeysSpinBox.apply()
	card_to_save.card_name = $CardNameBox.text
	card_to_save.key_amount = $KeysSpinBox.value
	ResourceSaver.save(card_to_save)
	load_all_cards()
	
