class_name TimelineManager
extends Node

@onready var sequence_creator: SequenceCreator = $"../SequenceCreator"
@onready var strike_card: CardBase = ResourceLoader.load("res://data/cards/test_strike.tres")
@onready var shield_card: CardBase = ResourceLoader.load("res://data/cards/test_block.tres")
@onready var music_player: MusicPlayer = RhythmClock.music_player
@onready var beats_per_bar: int = music_player.time_signature()
@onready var timeline: Timeline = Timeline.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timeline = construct_timeline()
	sequence_creator.convert_to_sequence(timeline)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func construct_timeline() -> Timeline:
	timeline.beats_per_bar = music_player.time_signature()
	timeline.length_in_bars = 8
	timeline.cards.append(strike_card)
	timeline.cards.append(strike_card)
	timeline.cards.append(shield_card)
	timeline.cards.append(strike_card)
	timeline.cards.append(shield_card)
	timeline.cards.append(strike_card)
	timeline.cards.append(shield_card)
	timeline.cards.append(strike_card)
	return timeline
