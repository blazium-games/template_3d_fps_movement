extends AutoworkTest

const Rules = preload("res://scripts/rules.gd")

func test_planar_step() -> void:
	var rules = Rules.new()
	var step := rules.planar_step(Vector2(1, 0), false)
	assert_almost_eq(step.x, 6.0, 0.01, "ground rate")
	var sprint := rules.planar_step(Vector2(0, 1), true)
	assert_almost_eq(sprint.y, 9.6, 0.01, "sprint scale")

func test_leap_when_grounded() -> void:
	var rules = Rules.new()
	assert_almost_eq(rules.leap_push(0.0, true), 4.5, 0.01, "ground leap")
	assert_almost_eq(rules.leap_push(1.0, false), 1.0, 0.01, "air keeps vertical")

func test_gaze_range() -> void:
	var rules = Rules.new()
	assert_false(rules.gaze_accepted(0.01), "too low")
	assert_false(rules.gaze_accepted(4.0), "too high")
	assert_true(rules.gaze_accepted(0.2), "in range")

func test_ramp_gate() -> void:
	var rules = Rules.new()
	assert_false(rules.may_ramp(true), "airborne")
	assert_true(rules.may_ramp(false), "grounded")
	rules.release_gaze()
	assert_true(rules.gaze_freed, "mouse released")
	assert_true(load("res://scenes/ramp.tscn") != null, "ramp loads")

func test_crouch_height() -> void:
	var rules = Rules.new()
	assert_false(rules.crouch_height(true), "airborne crouch")
	assert_true(rules.crouch_height(false), "grounded crouch")
