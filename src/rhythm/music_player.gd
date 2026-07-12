@icon("res://addons/at-icons/node/note_double.svg")
class_name MusicPlayer
extends Node

@onready var music_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var current_song: SongResource = ResourceLoader.load("res://data/songs/minim.tres")
@onready var music: AudioStream = current_song.audio


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_player.set_stream(music) 
	play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func get_playback_position() -> float:
	return music_player.get_playback_position() + AudioServer.get_time_since_last_mix()

func play() -> void:
	music_player.play()

func bpm() -> float:
	return current_song.bpm

func is_playing() -> bool:
	return music_player.playing

func first_beat() -> float:
	return current_song.first_beat

func time_signature() -> int:
	return current_song.time_signature
