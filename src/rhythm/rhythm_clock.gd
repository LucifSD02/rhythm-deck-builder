extends Node

#Timeline (all notes) -> Next four -> Active queue -> Target note
#After a note is removed from the Next 4, replace it
@onready var music_player: MusicPlayer = $MusicPlayer
@onready var test_melody_card: CardBase = ResourceLoader.load("res://data/cards/test_strike.tres")
@onready var song_bpm: float
@export var manual_calibration_offset: float = -0.08
var ten_hit_offsets: Array[float]
var accumulated_time: float = 0.0
var seconds_per_beat: float = 0
var note_events: Array[NoteEvent]
var next_four_note_events: Array[NoteEvent]
var active_queue: Array[NoteEvent]

func _ready() -> void:
	song_bpm = current_song.bpm
	seconds_per_beat = 60.0 / song_bpm
	note_events = load_melody_card()
	if note_events.size() >= 4:
		for x in 4:
			next_four_note_events.append(note_events[x])
	else:
		for x in note_events.size():
			next_four_note_events.append(note_events[x])

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
		
		# Calibration Logging (Stays active)
		var calibration_beat = round(current_hit)
		var calibration_true_distance = current_hit - calibration_beat
		ten_hit_offsets.append(calibration_true_distance)
		print("Calibration Hit - Bar: " + str(get_current_bar()) + " | Beat: " + str(current_hit))

		if active_queue.size() > 0:
			var target_beat = active_queue[0].time
			var hit_deviation = current_hit - target_beat
			print(get_hit_judgement(hit_deviation))
			active_queue.remove_at(0)
			print("Target note is too far away to hit")
		else:
			print("Queue is completely empty")

	if ten_hit_offsets.size() > 9:
		var average_offset = calculate_average_offset(ten_hit_offsets)
		print("Average offset distance: " + str(average_offset) + " beats, which is " + str(average_offset * seconds_per_beat) + " seconds")
		ten_hit_offsets.remove_at(0)

	for x in range((next_four_note_events.size() - 1 ), -1, -1):
		if (next_four_note_events[x].time - (accumulated_time / seconds_per_beat)) <= 0.40:
			var current_hit = get_current_beat(false)
			print("Upcoming note - Bar: " + str(get_current_bar()) + " | Beat: " + str(current_hit + 1) + " at beat " + str(next_four_note_events[x].time + 1))
			active_queue.append(next_four_note_events[x])
			next_four_note_events.remove_at(x)

	for x in range((active_queue.size() - 1 ), -1, -1):
		if active_queue.size() == 0:
			break
		if accumulated_time / seconds_per_beat > active_queue[x].time + 0.30:
			print("Missed")
			active_queue.remove_at(x)


func get_current_beat(with_latency: bool) -> float:
	var true_time = accumulated_time - current_song.first_beat
	if with_latency:
		var audible_time = true_time - AudioServer.get_output_latency() + manual_calibration_offset
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

func load_melody_card() -> Array[NoteEvent]:
	for x in test_melody_card.melody_notes.size():
		note_events.append(test_melody_card.melody_notes[x])
	return note_events

func get_hit_judgement(hit_deviation: float) -> String:
	if hit_deviation < 0:
		hit_deviation = hit_deviation * -1

	if hit_deviation <= 0.05:
		return "Perfect"
	elif hit_deviation <= 0.12:
		return "Great"
	elif hit_deviation <= 0.22:
		return "Okay"
	else:
		return "Miss"
