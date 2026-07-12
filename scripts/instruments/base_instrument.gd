class_name BaseInstrument
extends Resource

enum InstrumentCategory { GUITAR, DRUMS, BASS, VOCALS, PIANO }
@export var name : String
@export var category: InstrumentCategory
@export var flavour_text: String
@export var key_amount: int
@export var starting_cards: Array[CardBase] = []
