extends Node2D
## 챕터 1 현실 파트 플레이어 — 그리드 단위 4방향 이동 (키보드 방향키 전용).
## DESIGN.md §3: 부드러운 자유이동이 아니라 타일 단위 이동이어야 한다.

const TILE_SIZE := 32.0
const TILE_MOVE_SECONDS := 0.12
const MOVE_SPEED := TILE_SIZE / TILE_MOVE_SECONDS

@export var play_area: Rect2 = Rect2(0.0, 0.0, 1280.0, 720.0)

var facing := Vector2.DOWN

var _target_position: Vector2
var _moving := false

func _ready() -> void:
	add_to_group("player")
	_target_position = position

func _process(delta: float) -> void:
	if _moving:
		position = position.move_toward(_target_position, MOVE_SPEED * delta)
		if position.is_equal_approx(_target_position):
			position = _target_position
			_moving = false
		return

	if DialogueSystem.is_active():
		return

	var dir := Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		dir = Vector2.RIGHT
	elif Input.is_action_pressed("ui_left"):
		dir = Vector2.LEFT
	elif Input.is_action_pressed("ui_down"):
		dir = Vector2.DOWN
	elif Input.is_action_pressed("ui_up"):
		dir = Vector2.UP

	if dir == Vector2.ZERO:
		return

	var next_position := position + dir * TILE_SIZE
	if not play_area.has_point(next_position):
		return

	facing = dir
	$FacingIndicator.position = dir * (TILE_SIZE * 0.5)
	_target_position = next_position
	_moving = true
