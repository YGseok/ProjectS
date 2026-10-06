extends Node2D
## 챕터 1 현실 파트 플레이어 — 그리드 단위 4방향 이동 (키보드 방향키 전용).
## DESIGN.md §6: 부드러운 자유이동이 아니라 타일 단위 이동이어야 한다.
## 스프라이트는 `assets/sprites/characters/player/`(pc001 시트에서 잘라낸
## 4방향 × 3프레임)을 쓴다. `facing`에 따라 `Sprite2D.texture`를 바꾸고,
## 한 칸 이동하는 동안 앞 절반은 보폭 프레임(걸음마다 왼발/오른발 번갈아),
## 뒤 절반은 정지 프레임을 보여줘서 걷기 애니메이션이 된다.

const TILE_SIZE := 32.0
const TILE_MOVE_SECONDS := 0.12
const MOVE_SPEED := TILE_SIZE / TILE_MOVE_SECONDS

@export var play_area: Rect2 = Rect2(0.0, 0.0, 1280.0, 720.0)

var facing := Vector2.DOWN

var _target_position: Vector2
var _moving := false
var _collision_map: Node

const _SPRITE_DIR := "res://assets/sprites/characters/player/"

## 방향별 [정지, walk1, walk2]
var _frames := {
	Vector2.DOWN: _load_frames("down"),
	Vector2.LEFT: _load_frames("left"),
	Vector2.RIGHT: _load_frames("right"),
	Vector2.UP: _load_frames("up"),
}
## 걸음마다 1/2를 번갈아 써서 왼발·오른발이 교대로 나오게 한다.
var _stride_foot := 1

@onready var _sprite: Sprite2D = $Sprite

func _ready() -> void:
	add_to_group("player")
	_target_position = position
	_update_sprite()

static func _load_frames(dir_name: String) -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	for suffix in ["", "_walk1", "_walk2"]:
		frames.append(load(_SPRITE_DIR + "player_%s%s.png" % [dir_name, suffix]))
	return frames

func _update_sprite(frame: int = 0) -> void:
	var frames: Array[Texture2D] = _frames.get(facing, _frames[Vector2.DOWN])
	_sprite.texture = frames[frame]
	_sprite.flip_h = false
	_sprite.offset = Vector2(0, -_sprite.texture.get_height() / 2.0 + TILE_SIZE / 2.0)

func _process(delta: float) -> void:
	if _collision_map == null:
		_collision_map = get_tree().get_first_node_in_group("collision_map")
	if _moving:
		position = position.move_toward(_target_position, MOVE_SPEED * delta)
		if position.is_equal_approx(_target_position):
			position = _target_position
			_moving = false
			_update_sprite()
		elif position.distance_to(_target_position) < TILE_SIZE / 2.0:
			_update_sprite()
		return

	if DialogueSystem.is_active() or ItemPopup.is_active() or ChapterTitleCard.is_active():
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
	if _collision_map and _collision_map.is_blocked(next_position):
		facing = dir
		_update_sprite()
		return

	facing = dir
	_stride_foot = 3 - _stride_foot
	_update_sprite(_stride_foot)
	_target_position = next_position
	_moving = true
