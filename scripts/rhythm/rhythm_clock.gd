@icon("res://addons/at-icons/node/stopwatch.svg")
extends Node

@onready var music_player: MusicPlayer = $MusicPlayer
@onready var song_bpm: float
@onready var output_latency_seconds: float = AudioServer.get_output_latency() / 1000 
@export var manual_calibration_offset_seconds: float = -0.18
var ten_hit_offsets: Array[float]
var accumulated_time_seconds: float = 0.0
var seconds_per_beat: float = 0


func _ready() -> void:
	song_bpm = music_player.bpm()
	seconds_per_beat = 60.0 / song_bpm


func _process(delta: float) -> void:
	if music_player.is_playing():
		accumulated_time_seconds += delta

		var physical_audio_time: float = music_player.get_playback_position()
		var clock_error: float = abs(accumulated_time_seconds - physical_audio_time)
		if clock_error > 0.02:
			accumulated_time_seconds = physical_audio_time
			print("Bar: " + str(get_current_bar()) + " | Beat: " + str(get_current_beat(false)) + ", clock adjusted")

	if ten_hit_offsets.size() > 9:
		var average_offset: float = calculate_average_offset(ten_hit_offsets)
		print("Average offset distance: " + str(average_offset) + " beats, which is " + str(average_offset * seconds_per_beat) + " seconds")
		ten_hit_offsets.remove_at(0)

func get_current_beat(with_latency: bool) -> float:
	var true_time: float = accumulated_time_seconds - music_player.first_beat()
	
	if with_latency:
		var audible_time: float = true_time - output_latency_seconds + manual_calibration_offset_seconds
		return audible_time / seconds_per_beat
	return true_time / seconds_per_beat

func get_current_bar() -> int:
	return int(floor(get_current_beat(false) / music_player.time_signature())) + 1

func calculate_average_offset(offsets: Array[float]) -> float:
	var average_offset: float = 0
	var total_offset: float = 0
	for x in offsets.size():
		total_offset += offsets[x]
	
	average_offset = total_offset / offsets.size()
	return average_offset

func _input(space: InputEvent) -> void: #Calibration hits registration
	if space.is_action_pressed("rhythm_special", true):
		print (get_time_until_suitable_timeline_start())
		var target: float = round(get_current_beat(false))
		var actual: float = get_current_beat(true)
		ten_hit_offsets.append(actual-target)
		print("Calibration hit, deviation is ", str(actual-target))

func get_time_until_next_bar(current_bar: int) -> float:
	var current_beat: float = get_current_beat(false) + 1
	var target_beat: float = current_bar * (music_player.time_signature())
	var time_until_next_bar: float = target_beat - current_beat
	return time_until_next_bar

func get_time_until_suitable_timeline_start() -> float:
	var current_beat: float = get_current_beat(true)
	var current_bar: int = get_current_bar()
	var target_bar: int = Utilities.find_next_multiple_of_x(current_bar, 4)
	var target_beat: int = target_bar * music_player.time_signature()
	return (target_beat) - current_beat

func get_next_suitable_starting_bar(multiple_of: int) -> int:
	var current_bar: int = get_current_bar()
	var target_bar: int = Utilities.find_next_multiple_of_x(current_bar, multiple_of)
	if target_bar - current_bar >= 2:
		return target_bar
	return target_bar + multiple_of
