class_name EnemyPerformer
extends RefCounted


static func calculate_press_beat(target_beat: float, spread_beats: float, offset_beats: float, rng: RandomNumberGenerator) -> float:
	return target_beat + rng.randfn(offset_beats, spread_beats)
