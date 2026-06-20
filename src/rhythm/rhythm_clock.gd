extends Node

@onready var current_song: SongResource = preload("res://data/songs/all_is_well_in_the_end.tres")
@onready var song_bpm: float = 90
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var music: AudioStream = current_song.audio
@export var manual_calibration_offset: float = 0.08
var ten_hit_offsets: Array[float]
var accumulated_time: float = 0.0
var seconds_per_beat: float = 0

func _ready() -> void:
	seconds_per_beat = 60.0 / song_bpm
	audio_stream_player.set_stream(music) 
	audio_stream_player.play()

func _process(delta: float) -> void:
	if audio_stream_player.playing:
		accumulated_time += delta
		var physical_audio_time = audio_stream_player.get_playback_position() + AudioServer.get_time_since_last_mix()
		var clock_error = abs(accumulated_time - physical_audio_time)
		if clock_error > 0.02:
			accumulated_time = physical_audio_time
			print("Bar: " + str(get_current_bar()) + " | Beat: " + str(get_current_beat(false)) + ", clock adjusted")

	if Input.is_action_just_pressed("rhythm_special"):
		var current_hit = get_current_beat(true)
		var target_beat = round(current_hit)
		var true_distance = current_hit - target_beat
		ten_hit_offsets.append(true_distance)
		print("Bar: " + str(get_current_bar()) + " | Beat: " + str(current_hit))

	if ten_hit_offsets.size() > 9:
		var average_offset = calculate_average_offset(ten_hit_offsets)
		print("Average offset distance: " + str(average_offset) + " beats, which is " + str(average_offset * seconds_per_beat) + " seconds")
		ten_hit_offsets.remove_at(0)

func get_current_beat(with_latency: bool) -> float:
	var true_time = accumulated_time - current_song.first_beat
	if with_latency:
		var audible_time = true_time - AudioServer.get_output_latency() - manual_calibration_offset
		return audible_time / seconds_per_beat
	return true_time / seconds_per_beat

func get_current_bar() -> int:
	return int(floor(get_current_beat(false) / current_song.time_signature)) + 1

func calculate_average_offset(offsets: Array[float]) -> float:
	var average_offset: float = 0
	var total_offset: float = 0
	for x in offsets.size():
		total_offset += offsets[x]
	
	average_offset = total_offset / offsets.size()
	return average_offset
