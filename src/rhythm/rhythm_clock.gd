extends Node

@onready var music_player: MusicPlayer = $MusicPlayer
@onready var song_bpm: float
@export var manual_calibration_offset: float = -0.11
var ten_hit_offsets: Array[float]
var accumulated_time: float = 0.0
var seconds_per_beat: float = 0

func _ready() -> void:
	song_bpm = music_player.bpm()
	seconds_per_beat = 60.0 / song_bpm

func _process(delta: float) -> void:
	if music_player.is_playing():
		accumulated_time += delta
		var physical_audio_time = music_player.get_playback_position()
		var clock_error = abs(accumulated_time - physical_audio_time)
		if clock_error > 0.02:
			accumulated_time = physical_audio_time
			print("Bar: " + str(get_current_bar()) + " | Beat: " + str(get_current_beat(false)) + ", clock adjusted")

	if ten_hit_offsets.size() > 9:
		var average_offset = calculate_average_offset(ten_hit_offsets)
		print("Average offset distance: " + str(average_offset) + " beats, which is " + str(average_offset * seconds_per_beat) + " seconds")
		ten_hit_offsets.remove_at(0)

func get_current_beat(with_latency: bool) -> float:
	var true_time = accumulated_time - music_player.first_beat()
	if with_latency:
		var audible_time = true_time - AudioServer.get_output_latency() + manual_calibration_offset
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
		var target = round(get_current_beat(false))
		var actual = get_current_beat(true)
		ten_hit_offsets.append(target-actual)
		print("Calibration hit, deviation is ", str(target-actual))

func get_time_until_next_bar(current_bar) -> float:
	var current_beat: float = get_current_beat(false) + 1
	var target_beat: float = current_bar * (music_player.time_signature())
	var time_until_next_bar: float = target_beat - current_beat
	return time_until_next_bar

func get_time_until_suitable_timeline_start() -> float:
	var current_beat: float = get_current_beat(true)
	var current_bar: int = get_current_bar()
	var target_bar: int = find_next_multiple_of_four(current_bar)
	var target_beat = target_bar * music_player.time_signature()
	return (target_beat) - current_beat

func find_next_multiple_of_four(current_bar) -> int:
	var starting_bar = current_bar
	var next_multiple_of_four: int
	while starting_bar % 4 != 0:
		starting_bar += 1
	next_multiple_of_four = starting_bar
	return next_multiple_of_four
