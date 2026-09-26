extends GutTest


func test_same_seed_same_result() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var saved_state: int = rng.state
	var a: float = EnemyPerformer.calculate_press_beat(5, 0.5, 0, rng)
	rng.state = saved_state
	var b: float = EnemyPerformer.calculate_press_beat(5, 0.5, 0, rng)
	assert_eq(a, b)
