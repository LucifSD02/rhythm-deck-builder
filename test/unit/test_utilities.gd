extends GutTest

func test_next_multiple_of_4_after_5_is_8() -> void:
	var result: int = Utilities.find_next_multiple_of_x(5, 4)
	assert_eq(result, 8)

func test_next_multiple_of_4_after_8_is_12() -> void:
	var result: int = Utilities.find_next_multiple_of_x(8, 4)
	assert_eq(result, 12)

func test_next_multiple_of_4_after_0_is_4() -> void:
	var result: int = Utilities.find_next_multiple_of_x(0, 4)
	assert_eq(result, 4)

func test_next_multiple_of_0_after_5_is_() -> void:
	var result: int = Utilities.find_next_multiple_of_x(5, 0)
	assert_push_error("invalid")
	assert_eq(result, -1)
