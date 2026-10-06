extends RefCounted

const GROUND_RATE := 6.0
const SPRINT_SCALE := 1.6
const LEAP_PUSH := 4.5
const GAZE_LOW := 0.05
const GAZE_HIGH := 3.0

func planar_step(wish: Vector2, sprinting: bool) -> Vector2:
	if wish.length() < 0.001:
		return Vector2.ZERO
	var scale := SPRINT_SCALE if sprinting else 1.0
	return wish.normalized() * GROUND_RATE * scale

func leap_push(vertical: float, grounded: bool) -> float:
	if not grounded:
		return vertical
	return LEAP_PUSH

func gaze_accepted(amount: float) -> bool:
	return amount >= GAZE_LOW and amount <= GAZE_HIGH

var gaze_freed := false

func release_gaze() -> void:
	gaze_freed = true

func crouch_height(airborne: bool) -> bool:
	return not airborne

func may_ramp(airborne: bool) -> bool:
	return not airborne
