extends GutTest

const RhythmClockScript: GDScript = preload("res://scripts/autoload/rhythm_clock.gd")

var start_beat_cases: Array[Dictionary] = [
	{"name": "normal case rounds up to next slot", "current": 10.0, "slot_size": 16, "min_lead": 4.0, "expected": 16},
	{"name": "start exactly min lead away is allowed", "current": 12.0, "slot_size": 16, "min_lead": 4.0, "expected": 16},
	{"name": "start closer than min lead moves to next slot", "current": 12.5, "slot_size": 16, "min_lead": 4.0, "expected": 32},
	{"name": "start of the song", "current": 0.0, "slot_size": 16, "min_lead": 4.0, "expected": 16},
	{"name": "works with other slot sizes", "current": 4.0, "slot_size": 8, "min_lead": 2.0, "expected": 8},
	{"name": "negative slot size is invalid", "current": 10.0, "slot_size": -16, "min_lead": 4.0, "expected": -1, "expected_error": "invalid"},
]


func test_calculate_timeline_start_beat(p: Dictionary = use_parameters(start_beat_cases)) -> void:
	var start_beat: int = RhythmClockScript.calculate_timeline_start_beat(p.current, p.slot_size, p.min_lead)

	var expected_error: String = p.get("expected_error", "")
	if expected_error != "":
		assert_push_error(expected_error, p.name)

	assert_eq(start_beat, p.expected, p.name)
