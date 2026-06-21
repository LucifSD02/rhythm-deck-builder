class_name MusicPlayer
extends Node

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var current_song: SongResource = ResourceLoader.load("res://data/songs/minim.tres")
@onready var music: AudioStream = current_song.audio


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_stream_player.set_stream(music) 
	play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func sync_to_rhythm_clock() -> float:
	return audio_stream_player.get_playback_position() + AudioServer.get_time_since_last_mix()

func play():

	audio_stream_player.play()
