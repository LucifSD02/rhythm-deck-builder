class_name Note
extends Control

## Reference to the individual data file assigned to this physical note node
@export var note_event: NoteEvent

## This function will be triggered by your SequenceCreator's wires!
func activate(hit_beat: float) -> void:
	
	# Clean Optimization: Instead of querying the RhythmClock singleton again, 
	# use the high-precision hit_beat parameter passed right into your hands!
	var hit_deviation = hit_beat - note_event.time
	
	if abs(hit_deviation) > 0.40:
		print("Way too early")
		return
	else:
		print("Hit: ", name, " | Target Beat: ", note_event.time, " | Deviation: ", hit_deviation, " ", get_hit_judgement(hit_deviation))
		queue_free()

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
