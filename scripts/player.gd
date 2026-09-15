extends Node2D
## 챕터 1 현실 파트 플레이어 — 그리드 단위 4방향 이동 (키보드 방향키 전용).
## DESIGN.md §6: 부드러운 자유이동이 아니라 타일 단위 이동이어야 한다.
##
## 스프라이트는 `assets/sprites/characters/player_placeholder/`의 placeholder
## 이미지를 쓴다(2026-09-15 사람 확인: "기능부터 만들고 내용은 나중에
## 붙인다" — `pipeline_test.tscn`에서 검증해둔 방향별 텍스처 교체 방식을
## 실제 Player에 적용, 최종 캐릭터 디자인이 아직 확정 전이라 그 폴더의
## README 대로 나중에 파일만 교체하면 됨). 왼쪽/오른쪽은 같은 이미지를
## `flip_h`로 반전해서 재사용한다.

const TILE_SIZE := 32.0
const TILE_MOVE_SECONDS := 0.12
const MOVE_SPEED := TILE_SIZE / TILE_MOVE_SECONDS

@export var play_area: Rect2 = Rect2(0.0, 0.0, 1280.0, 720.0)

var facing := Vector2.DOWN

var _target_position: Vector2
var _moving := false
var _collision_map: Node

var _tex_down: Texture2D = preload("res://assets/sprites/characters/player_placeholder/player_down.png")
var _tex_side: Texture2D = preload("res://assets/sprites/characters/player_placeholder/player_side.png")
var _tex_up: Texture2D = preload("res://assets/sprites/characters/player_placeholder/player_up.png")

@onready var _sprite: Sprite2D = $Sprite

func _ready() -> void:
	add_to_group("player")
	_target_position = position
	_update_sprite()

func _update_sprite() -> void:
	match facing:
		Vector2.UP:
			_sprite.texture = _tex_up
			_sprite.flip_h = false
		Vector2.LEFT:
			_sprite.texture = _tex_side
			_sprite.flip_h = false
		Vector2.RIGHT:
			_sprite.texture = _tex_side
			_sprite.flip_h = true
		_:
			_sprite.texture = _tex_down
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
	_update_sprite()
	_target_position = next_position
	_moving = true
