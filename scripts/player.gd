extends Node2D
## 챕터 1 현실 파트 플레이어 — 그리드 단위 4방향 이동 (키보드 방향키 전용).
## DESIGN.md §6: 부드러운 자유이동이 아니라 타일 단위 이동이어야 한다.
## 스프라이트는 `assets/sprites/characters/player/`(pc001 시트에서 잘라낸
## 4방향 그림)을 쓴다. `facing`에 따라 `Sprite2D.texture`를 바꾼다.

const TILE_SIZE := 32.0
const TILE_MOVE_SECONDS := 0.12
const MOVE_SPEED := TILE_SIZE / TILE_MOVE_SECONDS

@export var play_area: Rect2 = Rect2(0.0, 0.0, 1280.0, 720.0)

var facing := Vector2.DOWN

var _target_position: Vector2
var _moving := false
var _collision_map: Node

var _tex_down: Texture2D = preload("res://assets/sprites/characters/player/player_down.png")
var _tex_left: Texture2D = preload("res://assets/sprites/characters/player/player_left.png")
var _tex_right: Texture2D = preload("res://assets/sprites/characters/player/player_right.png")
var _tex_up: Texture2D = preload("res://assets/sprites/characters/player/player_up.png")

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
			_sprite.texture = _tex_left
			_sprite.flip_h = false
		Vector2.RIGHT:
			_sprite.texture = _tex_right
			_sprite.flip_h = false
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
