@icon("res://addons/at-icons/control/pencil.svg")
@tool
extends Control

var card_resource_files: Array[Resource]
var card_index: int
var card_template: CardBase
const cards_path: String = "res://data/cards/"
@onready var name_box: LineEdit = $CardNameBox
@onready var keys_spin_box: SpinBox = $KeysSpinBox
@onready var bars_spin_box: SpinBox = $BarsSpinBox
@onready var existing_card_dropdown: OptionButton = $ExistingCardDropdown
@onready var keys_dropdown: OptionButton = $KeysDropdown
@onready var beat_spin_box: SpinBox = %BeatSpinBox
@onready var add_note_event_button: Button = %AddNoteEventButton
@onready var save_card_button: Button = $SaveCardButton
@onready var create_card_button: Button = %CreateCardButton
@onready var loaded_cards: Array[CardBase] = load_all_cards()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	save_card_button.disabled = true
	existing_card_dropdown.select(-1)
	existing_card_dropdown.text = "Select a card"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_existing_card_dropdown_item_selected(index: int) -> void:
	card_template = loaded_cards[index]
	print(card_template.name)
	apply_all_inputs()
	
	card_index = index
	populate_rich_text_label()
	save_card_button.disabled = false


func load_all_cards() -> Array[CardBase]:
	existing_card_dropdown.clear()
	card_resource_files = Utilities.load_resources_in_folder("res://data/cards/")
	var all_cards: Array[CardBase] = []
	for file in range(card_resource_files.size()):
		var loaded_card: CardBase = card_resource_files[file]
		existing_card_dropdown.add_item(loaded_card.name)
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
	var note_event_key: String = keys_dropdown.text
	beat_spin_box.apply()
	var note_event_beat: int = beat_spin_box.value
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
	apply_all_inputs()
	card_to_save.name = name_box.text
	card_to_save.bar_amount = bars_spin_box.value
	card_to_save.key_amount = keys_spin_box.value
	ResourceSaver.save(card_to_save)
	load_all_cards()


func _on_create_card_button_button_down() -> void:
	var new_card_resource: CardBase = CardBase.new()
	apply_all_inputs()
	new_card_resource.name = name_box.text
	new_card_resource.bar_amount = bars_spin_box.value
	new_card_resource.key_amount = keys_spin_box.value
	if card_template.melody_notes.size() != 0:
		new_card_resource.melody_notes = card_template.melody_notes
	var file_name: String = Utilities.format_string(name_box.text)
	var error: Error = ResourceSaver.save(new_card_resource, cards_path + file_name + ".tres")
	if error:
		print("error code: ", error)
	Utilities.force_editor_file_refresh(cards_path)

func apply_all_inputs() -> void:
	name_box.apply_ime()
	bars_spin_box.apply()
	keys_spin_box.apply()
