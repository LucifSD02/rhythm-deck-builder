@icon("res://addons/at-icons/node/wrench.svg")
class_name TimelineManager
extends Node

@onready var sequence_creator: SequenceCreator = $"../SequenceCreator"
@onready var music_player: MusicPlayer = RhythmClock.music_player
@onready var beats_per_bar: int = music_player.time_signature()
@onready var timeline: Timeline
@onready var note_hits: Array[NoteHit] = []
var cards: Array[CardBase]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func construct_timeline() -> Timeline:
	clear_timeline()
	timeline.beats_per_bar = music_player.time_signature()
	timeline.length_in_bars = 8
	for card: CardBase in cards:
		timeline.cards.append(card)
	return timeline

class NoteHit:
	var card_id: int
	var score: float
	func _init(_card_id: int, _score:float) -> void:
		self.card_id = _card_id
		self.score = _score

func log_note_hits(id: int, judgement: float) -> void:
	var new_hit: NoteHit = NoteHit.new(id, judgement)
	note_hits.append(new_hit)
	print(id, " " , judgement)

func sequence_complete() -> void:
	print("Sequence complete")
	var timeline_accuracy: float = get_accuracy_for_timeline(note_hits)
	print("Accuracy of timeline: ", timeline_accuracy)
	for card in range(timeline.cards.size()):
		var card_accuracy: float = get_accuracy_for_card(note_hits, card)
		print("Accuracy of card ", card, ": ", card_accuracy)
		pass

func get_accuracy_for_timeline(_note_hits: Array[NoteHit]) -> float:
	var total_timeline_score: float = 0
	var total_note_hits: int = _note_hits.size()
	
	for note_hit in note_hits:
		total_timeline_score += note_hit.score
	
	return total_timeline_score / total_note_hits

func get_accuracy_for_card(_note_hits: Array[NoteHit], card_id: int) -> float:
	var total_card_score: float = 0
	var total_note_hits: int = 0
	
	for note_hit in _note_hits:
		if note_hit.card_id == card_id:
			total_card_score += note_hit.score
			total_note_hits += 1
	
	return total_card_score / total_note_hits

func clear_timeline() -> void:
	timeline = Timeline.new()
